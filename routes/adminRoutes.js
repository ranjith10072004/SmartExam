const router = require("express").Router();
const Result = require("../models/result");
const Exam = require("../models/exam");
const User = require("../models/user");
const Attendance = require("../models/attendance");
const auth = require("../middleware/auth");

// -----------------------------------------------------
// 1. CREATE EXAM (ADMIN)
// -----------------------------------------------------
router.post("/createexam", auth(["admin"]), async (req, res) => {
  try {
    const {
      title,
      description,
      examStartTime,
      examEndTime,
      questions,
      proctorCode,
    } = req.body;

    if (!title || !examStartTime || !examEndTime || !questions) {
      return res.status(400).json({ msg: "Missing required fields" });
    }

    if (!Array.isArray(questions) || questions.length === 0) {
      return res
        .status(400)
        .json({ msg: "Questions must be a non-empty array" });
    }

    if (!proctorCode) {
      return res.status(400).json({ msg: "Proctor Code is required" });
    }

    const start = new Date(examStartTime);
    const end = new Date(examEndTime);

    if (end <= start) {
      return res.status(400).json({ msg: "End time must be after start time" });
    }

    const duration = Math.floor((end - start) / 60000);

    const exam = await Exam.create({
      title,
      description,
      examStartTime: start,
      examEndTime: end,
      duration,
      proctorCode,
      questions,
      createdBy: req.user.id,
    });

    return res.json({ msg: "Exam Created Successfully", exam });
  } catch (error) {
    return res.status(500).json({ msg: "Server Error", error: error.message });
  }
});

// -----------------------------------------------------
// 2. UPDATE EXAM (ADMIN)
// -----------------------------------------------------
router.patch("/updateexam/:examId", auth(["admin"]), async (req, res) => {
  try {
    const exam = await Exam.findById(req.params.examId);

    if (!exam) {
      return res.status(404).json({ msg: "Exam not found" });
    }

    // Update allowed fields only
    const allowedFields = [
      "title",
      "description",
      "examStartTime",
      "examEndTime",
      "questions",
      "proctorCode",
      "assignedTo",
    ];

    Object.keys(req.body).forEach((key) => {
      if (allowedFields.includes(key)) {
        exam[key] = req.body[key];
      }
    });

    await exam.save();

    return res.json({ msg: "Exam updated successfully", exam });
  } catch (error) {
    return res.status(500).json({ msg: error.message });
  }
});

// -----------------------------------------------------
// 3. GET ALL EXAMS (ADMIN)
// -----------------------------------------------------
router.get("/exams", auth(["admin"]), async (req, res) => {
  try {
    const exams = await Exam.find().select(
      "title description examStartTime examEndTime duration createdAt"
    );

    return res.json({ exams });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
});

// -----------------------------------------------------
// 4. GET ALL STUDENTS (ADMIN)
// -----------------------------------------------------
router.get("/students", auth(["admin"]), async (req, res) => {
  try {
    const students = await User.find({ role: "student" }).select(
      "name email _id"
    );

    return res.json({ students });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
});

// -----------------------------------------------------
// 6. GET PENDING RESULTS (FOR EVALUATION)
// -----------------------------------------------------
router.get("/pendingresults", auth(["admin"]), async (req, res) => {
  try {
    const results = await Result.find({ status: "pending" })
      .populate("studentId", "name email")
      .populate("examId", "title");

    return res.json({ results });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
});

// -----------------------------------------------------
// 7. GET A SINGLE RESULT FOR EVALUATION
// -----------------------------------------------------
router.get("/evaluate/:resultId", auth(["admin"]), async (req, res) => {
  try {
    const result = await Result.findById(req.params.resultId)
      .populate("studentId", "name email")
      .populate("examId");

    if (!result) {
      return res.status(404).json({ msg: "Result not found" });
    }

    return res.json(result);
  } catch (error) {
    return res.status(500).json({ msg: error.message });
  }
});

// -----------------------------------------------------
// 8. SUBMIT MANUAL EVALUATION SCORE
// -----------------------------------------------------
router.post("/evaluate/:resultId", auth(["admin"]), async (req, res) => {
  try {
    const { scores } = req.body;

    if (!Array.isArray(scores) || scores.length === 0) {
      return res.status(400).json({ msg: "Scores must be a non-empty array" });
    }

    const result = await Result.findById(req.params.resultId);

    if (!result) {
      return res.status(404).json({ msg: "Result Not Found" });
    }

    const totalScore = scores.reduce((a, b) => Number(a) + Number(b), 0);

    result.score = totalScore;
    result.status = "evaluated";
    result.evaluatedBy = req.user.id;
    result.evaluatedAt = new Date();

    await result.save();

    return res.json({
      msg: "Evaluation Completed",
      totalScore,
      resultId: result._id,
    });
  } catch (error) {
    return res.status(500).json({ msg: error.message });
  }
});

// -----------------------------------------------------
// 9. VIEW ATTENDANCE FOR AN EXAM
// -----------------------------------------------------
router.get("/attendance/:examId", auth(["admin"]), async (req, res) => {
  try {
    const attendance = await Attendance.find({
      examId: req.params.examId,
    })
      .populate("studentId", "name email")
      .populate("examId", "title examStartTime examEndTime");

    return res.json({ attendance });
  } catch (error) {
    return res.status(500).json({ msg: error.message });
  }
});

// -----------------------------------------------------
// 10. ATTENDANCE REPORT (PRESENT + ABSENT LIST)
// -----------------------------------------------------
router.get("/attendancereport/:examId", auth(["admin"]), async (req, res) => {
  try {
    const exam = await Exam.findById(req.params.examId).populate(
      "assignedTo",
      "name email"
    );

    if (!exam) {
      return res.status(404).json({ msg: "Exam not found" });
    }

    const attendance = await Attendance.find({ examId: req.params.examId });

    const presentIds = attendance.map((a) => a.studentId.toString());

    const absentStudents = exam.assignedTo.filter(
      (s) => !presentIds.includes(s._id.toString())
    );

    return res.json({
      present: attendance,
      absent: absentStudents,
    });
  } catch (error) {
    return res.status(500).json({ msg: error.message });
  }
});

module.exports = router;
