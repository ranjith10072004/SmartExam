const router = require("express").Router();
const Result = require("../models/result");
const Exam = require("../models/exam");
const User = require("../models/user");
const auth = require("../middleware/auth");

// ----------------------------
// CREATE EXAM (ADMIN ONLY)
// POST /admin/create-exam
// ----------------------------
router.post("/createexam", auth(["admin"]), async (req, res) => {
  try {
    const { title, description, duration, questions } = req.body;

    if (!title || !questions || !Array.isArray(questions) || questions.length === 0) {
      return res.status(400).json({ msg: "Missing required fields: title and questions" });
    }

    const exam = await Exam.create({
      title,
      description: description || "",
      duration: Number(duration) || 0,
      questions,
      createdBy: req.user.id,
    });

    res.json({
      msg: "Exam Created Successfully",
      exam,
    });
  } catch (error) {
    res.status(500).json({ msg: "Server Error", error: error.message });
  }
});


// ----------------------------
// 1. ADMIN: Get all pending submissions
// GET /admin/pendingresults
// ----------------------------
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

// ----------------------------
// 2. ADMIN: Get a single submission for evaluation
// GET /admin/evaluate/:resultId
// ----------------------------
router.get("/evaluate/:resultId", auth(["admin"]), async (req, res) => {
  try {
    const result = await Result.findById(req.params.resultId)
      .populate("studentId", "name email")
      .populate("examId"); // contains full exam questions

    if (!result) return res.status(404).json({ msg: "Result Not Found" });

    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ----------------------------
// 3. ADMIN: Submit evaluated score
// POST /admin/evaluate/:resultId
// body: { scores: [number, ...] }
// ----------------------------
router.post("/evaluate/:resultId", auth(["admin"]), async (req, res) => {
  try {
    const { scores } = req.body;

    if (!Array.isArray(scores)) {
      return res.status(400).json({ msg: "Invalid request: scores must be an array" });
    }

    const result = await Result.findById(req.params.resultId);
    if (!result) return res.status(404).json({ msg: "Result Not Found" });

    // Total marks evaluator gave
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

module.exports = router;
