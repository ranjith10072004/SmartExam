const router = require("express").Router();
const Exam = require("../models/exam");
const Result = require("../models/result");
const Attendance = require("../models/attendance");
const auth = require("../middleware/auth");


// 0. STUDENT — Get all active & assigned exams

router.get("/exams", auth(["student"]), async (req, res) => {
  try {
    const now = new Date();

    const exams = await Exam.find({
      assignedTo: req.user.id,
      examEndTime: { $gte: now },
    }).select("title description examStartTime examEndTime duration");

    res.json({ exams });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});


// 1. STUDENT — Fetch exam questions (assigned only)

router.get("/exam/:examId", auth(["student"]), async (req, res) => {
  try {
    const exam = await Exam.findOne({
      _id: req.params.examId,
      assignedTo: req.user.id,
    }).lean();

    if (!exam)
      return res
        .status(404)
        .json({ success: false, msg: "Exam not found or not assigned to you" });

    const now = new Date();
    if (now < exam.examStartTime)
      return res
        .status(403)
        .json({ success: false, msg: "Exam has not started yet" });

    if (now > exam.examEndTime)
      return res.status(403).json({ success: false, msg: "Exam time is over" });

    // Remove answers
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



// 2. STUDENT — Submit answers (only once)
-
router.post("/submit/:examId", auth(["student"]), async (req, res) => {
  try {
    const { answers } = req.body;
    const examId = req.params.examId;

    if (!answers || !Array.isArray(answers)) {
      return res.status(400).json({ msg: "Answers must be an array" });
    }

    const exam = await Exam.findOne({
      _id: examId,
      assignedTo: req.user.id,
    });

    if (!exam) {
      return res.status(404).json({ msg: "Exam not assigned or not found" });
    }

    const now = new Date();

    if (now < exam.examStartTime) {
      return res.status(403).json({ msg: "Exam not started yet" });
    }

    if (now > exam.examEndTime) {
      return res.status(403).json({ msg: "Exam time is over" });
    }

    // Prevent multiple submissions
    const existing = await Result.findOne({
      examId,
      studentId: req.user.id,
    });

    if (existing) {
      return res
        .status(400)
        .json({ msg: "You have already submitted this exam" });
    }

    // Save submission
    const result = await Result.create({
      examId,
      studentId: req.user.id,
      answers,
      totalMarks: exam.questions.length,
      status: "pending",
    });

    res.json({
      msg: "Exam submitted successfully. Awaiting evaluation.",
      resultId: result._id,
    });
  } catch (error) {
    res.status(500).json({ msg: "Error", error: error.message });
  }
});

// ------------------------------------------------------
// 3. STUDENT — Mark attendance manually
// ------------------------------------------------------
router.post("/attendance/:examId", auth(["student"]), async (req, res) => {
  try {
    const examId = req.params.examId;

    const exam = await Exam.findOne({
      _id: examId,
      assignedTo: req.user.id,
    });

    if (!exam) {
      return res.status(404).json({ msg: "Exam not assigned" });
    }

    const now = new Date();

    if (now < exam.examStartTime) {
      return res.status(403).json({ msg: "Exam has not started yet" });
    }

    if (now > exam.examEndTime) {
      return res.status(403).json({ msg: "Exam time is over" });
    }

    // Check if attendance already marked
    const existing = await Attendance.findOne({
      examId,
      studentId: req.user.id,
    });

    if (existing) {
      return res.json({ msg: "Attendance already marked", existing });
    }

    const attendance = await Attendance.create({
      examId,
      studentId: req.user.id,
      status: "present",
    });

    res.json({ msg: "Attendance marked successfully", attendance });
  } catch (error) {
    res.status(500).json({ msg: "Error", error: error.message });
  }
});

module.exports = router;
