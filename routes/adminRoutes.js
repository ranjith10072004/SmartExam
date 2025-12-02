const router = require("express").Router();
const Result = require("../models/result");
const Exam = require("../models/exam");
const User = require("../models/user");
const auth = require("../middleware/auth");
const Attendance = require("../models/attendance");

// -----------------------------------------------------
// 1. CREATE EXAM (ADMIN)
// -----------------------------------------------------
router.post("/createexam", auth(["admin"]), async (req, res) => {
  try {
    const { title, description, examStartTime, examEndTime, questions } =
      req.body;

    if (
      !title ||
      !questions ||
      !Array.isArray(questions) ||
      questions.length === 0
    ) {
      return res
        .status(400)
        .json({ msg: "Missing fields: title and questions required." });
    }

    const start = new Date(examStartTime);
    const end = new Date(examEndTime);

    if (isNaN(start) || isNaN(end))
      return res.status(400).json({ msg: "Invalid date format" });

    if (end <= start)
      return res.status(400).json({ msg: "End time must be after start time" });

    const duration = Math.floor((end - start) / 60000);

    const exam = await Exam.create({
      title,
      description: description || "",
      examStartTime: start,
      examEndTime: end,
      duration,
      questions,
      createdBy: req.user.id,
    });

    res.json({ msg: "Exam Created Successfully", exam });
  } catch (error) {
    res.status(500).json({ msg: "Server Error", error: error.message });
  }
});

// GET all students for assignment
router.get("/students", auth(["admin"]), async (req, res) => {
  try {
    const students = await User.find({ role: "student" })
      .select("name email _id");

    res.json({ students });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// -----------------------------------------------------
// 2. GET ALL PENDING RESULTS
// -----------------------------------------------------
router.get("/pendingresults", auth(["admin"]), async (req, res) => {
  try {
    const results = await Result.find({ status: "pending" })
      .populate("studentId", "name email")
      .populate("examId", "title");

    res.json({ results });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// -----------------------------------------------------
// 3. GET SINGLE RESULT FOR EVALUATION
// -----------------------------------------------------
router.get("/evaluate/:resultId", auth(["admin"]), async (req, res) => {
  try {
    const result = await Result.findById(req.params.resultId)
      .populate("studentId", "name email")
      .populate("examId");

    if (!result) return res.status(404).json({ msg: "Result Not Found" });

    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});



// ADMIN — View attendance for an exam
router.get("/attendance/:examId", auth(["admin"]), async (req, res) => {
  try {
    const attendance = await Attendance.find({
      examId: req.params.examId,
    })
      .populate("studentId", "name email")
      .populate("examId", "title examStartTime examEndTime");

    res.json({ attendance });
  } catch (error) {
    res.status(500).json({ msg: "Error", error: error.message });
  }
});


// -----------------------------------------------------
// 4. SUBMIT EVALUATION SCORE
// -----------------------------------------------------
router.post("/evaluate/:resultId", auth(["admin"]), async (req, res) => {
  try {
    const { scores } = req.body;

    if (!Array.isArray(scores))
      return res.status(400).json({ msg: "Scores must be an array" });

    const result = await Result.findById(req.params.resultId);
    if (!result) return res.status(404).json({ msg: "Result Not Found" });

    const totalScore = scores.reduce((a, b) => Number(a) + Number(b), 0);

    result.score = totalScore;
    result.status = "evaluated";
    result.evaluatedBy = req.user.id;
    result.evaluatedAt = new Date();

    await result.save();

    res.json({
      msg: "Evaluation Completed",
      totalScore,
      resultId: result._id,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// -----------------------------------------------------
// 5. ASSIGN EXAM TO SELECTED STUDENTS
// -----------------------------------------------------
router.post("/assignexam/:examId", auth(["admin"]), async (req, res) => {
  try {
    const { studentIds } = req.body;

    if (!studentIds || !Array.isArray(studentIds) || studentIds.length === 0) {
      return res
        .status(400)
        .json({ msg: "studentIds must be a non-empty array" });
    }

    const exam = await Exam.findById(req.params.examId);
    if (!exam) return res.status(404).json({ msg: "Exam not found" });

    // Validate users exist & are students
    const validStudents = await User.find({
      _id: { $in: studentIds },
      role: "student",
    }).select("_id");

    exam.assignedTo = validStudents.map((s) => s._id);
    await exam.save();

    res.json({
      msg: "Exam assigned successfully",
      assignedTo: exam.assignedTo,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});


// 6. ADD MORE STUDENTS TO EXISTING EXAM

router.patch("/addstudents/:examId", auth(["admin"]), async (req, res) => {
  try {
    const { studentIds } = req.body;

    if (!Array.isArray(studentIds))
      return res.status(400).json({ msg: "studentIds must be an array" });

    const exam = await Exam.findById(req.params.examId);
    if (!exam) return res.status(404).json({ msg: "Exam not found" });

    const validStudents = await User.find({
      _id: { $in: studentIds },
      role: "student",
    }).select("_id");

    exam.assignedTo.push(...validStudents.map((s) => s._id));

    // Remove duplicates
    exam.assignedTo = [...new Set(exam.assignedTo.map((id) => id.toString()))];

    await exam.save();

    res.json({
      msg: "Students added successfully",
      assignedTo: exam.assignedTo,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get("/attendancereport/:examId", auth(["admin"]), async (req, res) => {
  try {
    const examId = req.params.examId;

    const exam = await Exam.findById(examId).populate(
      "assignedTo",
      "name email"
    );
    const attendance = await Attendance.find({ examId });

    const presentIds = attendance.map((a) => a.studentId.toString());

    const absentStudents = exam.assignedTo.filter(
      (s) => !presentIds.includes(s._id.toString())
    );

    res.json({
      present: attendance,
      absent: absentStudents,
    });
  } catch (error) {
    res.status(500).json({ msg: error.message });
  }
});


module.exports = router;
