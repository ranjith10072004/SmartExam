const router = require("express").Router();
const Exam = require("../models/exam");
const Result = require("../models/result");
const Attendance = require("../models/attendance");
const auth = require("../middleware/auth");

const multer = require("multer");
const fs = require("fs");
const path = require("path");

// -----------------------------------------------------
// Ensure uploads directory exists (absolute path)
// -----------------------------------------------------
const uploadDir = path.join(__dirname, "..", "uploads");

if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
  console.log("Created uploads directory:", uploadDir);
}

// -----------------------------------------------------
// MULTER STORAGE CONFIG
// -----------------------------------------------------
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir); // absolute path → prevents ENOENT errors
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
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
      examEndTime: { $gte: now },
    }).select("title description examStartTime examEndTime duration");

    return res.json({ success: true, exams });
  } catch (error) {
    return res.status(500).json({ success: false, msg: error.message });
  }
});

// -----------------------------------------------------
// 1. STUDENT — Verify Proctor Code
// -----------------------------------------------------
router.post("/verify-proctor/:examId", auth(["student"]), async (req, res) => {
  try {
    const { proctorCode } = req.body;

    if (!proctorCode)
      return res
        .status(400)
        .json({ success: false, msg: "Proctor code required" });

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
// 2. STUDENT — Fetch Questions (after proctor verification)
// -----------------------------------------------------
router.get("/exam/:examId", auth(["student"]), async (req, res) => {
  try {
    const examId = req.params.examId;
    const { proctorCode } = req.query;

    const exam = await Exam.findById(examId).lean();
    if (!exam)
      return res.status(404).json({ success: false, msg: "Exam not found" });

    if (!proctorCode || exam.proctorCode !== proctorCode)
      return res
        .status(403)
        .json({ success: false, msg: "Invalid or missing proctor code" });

    const now = new Date();
    if (now < exam.examStartTime)
      return res.status(403).json({ success: false, msg: "Exam not started" });

    if (now > exam.examEndTime)
      return res.status(403).json({ success: false, msg: "Exam over" });

    // Hide answers from student
    exam.questions = exam.questions.map((q) => ({
      _id: q._id,
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
// 3. STUDENT — Upload Scanned Image / PDF
// -----------------------------------------------------
router.post(
  "/upload-answer/:examId/:questionId",
  auth(["student"]),
  upload.single("file"), // Flutter sends field name "file"
  async (req, res) => {
    try {
      const { questionId } = req.params;

      if (!questionId)
        return res
          .status(400)
          .json({ success: false, msg: "Missing questionId" });

      if (!req.file)
        return res
          .status(400)
          .json({ success: false, msg: "No file uploaded" });

      const fileUrl = "/uploads/" + req.file.filename;

      return res.status(200).json({
        success: true,
        msg: "File uploaded successfully",
        fileUrl,
      });
    } catch (err) {
      console.error("UPLOAD ERROR:", err);
      return res.status(500).json({
        success: false,
        msg: "Upload failed",
        error: err.message,
      });
    }
  }
);

// -----------------------------------------------------
// 4. STUDENT — Submit Exam (One-time submission)
// -----------------------------------------------------
router.post("/submit/:examId", auth(["student"]), async (req, res) => {
  try {
    const { answers } = req.body;
    const examId = req.params.examId;

    if (!answers || !Array.isArray(answers)) {
      return res
        .status(400)
        .json({ success: false, msg: "Answers must be an array" });
    }

    const exam = await Exam.findById(examId);

    if (!exam)
      return res.status(404).json({ success: false, msg: "Exam not found" });

    const now = new Date();
    if (now < exam.examStartTime)
      return res
        .status(403)
        .json({ success: false, msg: "Exam not started yet" });

    if (now > exam.examEndTime)
      return res.status(403).json({ success: false, msg: "Exam time is over" });

    // Prevent multiple submissions
    const existing = await Result.findOne({
      examId,
      studentId: req.user.id,
    });

    if (existing)
      return res.status(400).json({
        success: false,
        msg: "You have already submitted this exam",
      });

    const formattedAnswers = answers.map((ans) => {
      const uploads = typeof ans.fileUrl === "string" ? [ans.fileUrl] : [];

      return {
        questionId: ans.questionId,
        writtenAnswer: ans.writtenAnswer || "",
        fileUploads: uploads,
        evaluatorScore: 0,
      };
    });

    const result = await Result.create({
      examId,
      studentId: req.user.id,
      answers: formattedAnswers,
      totalMarks: exam.questions.length,
      status: "pending",
    });

    return res.json({
      success: true,
      msg: "Exam submitted successfully. Awaiting evaluation.",
      resultId: result._id,
    });
  } catch (error) {
    console.error("SUBMIT ERROR:", error);
    return res.status(500).json({ success: false, msg: error.message });
  }
});




module.exports = router;
