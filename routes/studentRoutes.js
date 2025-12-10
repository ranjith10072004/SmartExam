const router = require("express").Router();
const Exam = require("../models/exam");
const Result = require("../models/result");
const Attendance = require("../models/attendance");
const auth = require("../middleware/auth");

const multer = require("multer");
const path = require("path");

// -----------------------------------------------------
// FILE UPLOAD SETUP (Store student scanned answer images)
// -----------------------------------------------------
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "uploads/"); // Save in uploads folder
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname)); // unique name
  },
});

const upload = multer({ storage });

// -----------------------------------------------------
// 0. STUDENT — Get all assigned & active exams
// -----------------------------------------------------
router.get("/exams", auth(["student"]), async (req, res) => {
  try {
    const now = new Date();

    const exams = await Exam.find({
      examEndTime: { $gte: now }, // show all upcoming & active exams
    }).select("title description examStartTime examEndTime duration");

    res.json({ success: true, exams });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

//student should enter proctor code before starts


router.post("/verify-proctor/:examId", auth(["student"]), async (req, res) => {
  try {
    const { proctorCode } = req.body;

    const exam = await Exam.findById(req.params.examId);

    if (!exam)
      return res.status(404).json({ success: false, msg: "Exam not found" });

    if (exam.proctorCode !== proctorCode)
      return res
        .status(400)
        .json({ success: false, msg: "Invalid Proctor Code" });

    return res.json({ success: true, msg: "Proctor Code Verified" });
  } catch (error) {
    return res.status(500).json({ success: false, msg: error.message });
  }
});
// -----------------------------------------------------
// 1. STUDENT — Fetch exam questions (Assigned Only) 
// -----------------------------------------------------
router.get("/exam/:examId", auth(["student"]), async (req, res) => {
  try {
    const examId = req.params.examId;
    const { proctorCode } = req.query;

    const exam = await Exam.findById(examId).lean();
    if (!exam)
      return res.status(404).json({ success: false, msg: "Exam not found" });

    // Match query param (Flutter will send ?proctorCode=xxxx)
    if (!proctorCode || exam.proctorCode !== proctorCode)
      return res
        .status(403)
        .json({ success: false, msg: "Invalid or missing proctor code" });

    const now = new Date();

    if (now < exam.examStartTime)
      return res.status(403).json({ success: false, msg: "Exam not started" });

    if (now > exam.examEndTime)
      return res.status(403).json({ success: false, msg: "Exam over" });

    exam.questions = exam.questions.map((q) => ({
      questionText: q.questionText,
      type: q.type,
      options: q.options,
    }));

    return res.json({ success: true, exam });
  } catch (err) {
    return res.status(500).json({ success: false, msg: err.message });
  }
});

// -----------------------------------------------------
// 2. STUDENT — Upload scanned images (camera/gallery)
// -----------------------------------------------------
router.post(
  "/upload-answer/:examId/:questionId",
  auth(["student"]),
  upload.array("files", 5), // allow multiple images
  async (req, res) => {
    try {
      if (!req.files || req.files.length === 0)
        return res.status(400).json({ msg: "No files uploaded" });

      const fileUrls = req.files.map((file) => "/uploads/" + file.filename);

      res.json({
        msg: "Files uploaded successfully",
        files: fileUrls,
      });
    } catch (error) {
      res.status(500).json({ msg: error.message });
    }
  }
);

// -----------------------------------------------------
// 3. STUDENT — Submit written answer + images (only once)
// -----------------------------------------------------
router.post("/submit/:examId", auth(["student"]), async (req, res) => {
  try {
    const { answers } = req.body; // Contains written answers + file URLs
    const examId = req.params.examId;

    if (!answers || !Array.isArray(answers)) {
      return res.status(400).json({ msg: "Answers must be an array" });
    }

    const exam = await Exam.findOne({
      _id: examId,
      assignedTo: req.user.id,
    });

    if (!exam)
      return res.status(404).json({ msg: "Exam not assigned or not found" });

    const now = new Date();
    if (now < exam.examStartTime)
      return res.status(403).json({ msg: "Exam not started yet" });

    if (now > exam.examEndTime)
      return res.status(403).json({ msg: "Exam time is over" });

    // Prevent multiple submissions
    const existing = await Result.findOne({
      examId,
      studentId: req.user.id,
    });

    if (existing)
      return res
        .status(400)
        .json({ msg: "You have already submitted this exam" });

    // Save submission
    const result = await Result.create({
      examId,
      studentId: req.user.id,
      answers, // written + image URLs
      totalMarks: exam.questions.length,
      status: "pending",
    });

    res.json({
      msg: "Exam submitted successfully. Awaiting evaluation.",
      resultId: result._id,
    });
  } catch (error) {
    res.status(500).json({ msg: error.message });
  }
});

// -----------------------------------------------------
// 4. STUDENT — Mark attendance
// -----------------------------------------------------
router.post("/attendance/:examId", auth(["student"]), async (req, res) => {
  try {
    const examId = req.params.examId;

    const exam = await Exam.findOne({
      _id: examId,
      assignedTo: req.user.id,
    });

    if (!exam) return res.status(404).json({ msg: "Exam not assigned" });

    const now = new Date();
    if (now < exam.examStartTime)
      return res.status(403).json({ msg: "Exam has not started yet" });

    if (now > exam.examEndTime)
      return res.status(403).json({ msg: "Exam time is over" });

    const existing = await Attendance.findOne({
      examId,
      studentId: req.user.id,
    });

    if (existing)
      return res.json({ msg: "Attendance already marked", existing });

    const attendance = await Attendance.create({
      examId,
      studentId: req.user.id,
      status: "present",
    });

    res.json({ msg: "Attendance marked successfully", attendance });
  } catch (error) {
    res.status(500).json({ msg: error.message });
  }
});

module.exports = router;
