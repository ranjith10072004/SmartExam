const router = require("express").Router();
const Result = require("../models/result");
const Exam = require("../models/exam");
const User = require("../models/user");
const auth = require("../middleware/auth");

// ----------------------------
// 1. ADMIN: Get all pending submissions
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
// ----------------------------
router.post("/evaluate/:resultId", auth(["admin"]), async (req, res) => {
  try {
    const { scores } = req.body;

    const result = await Result.findById(req.params.resultId);
    if (!result) return res.status(404).json({ msg: "Result Not Found" });

    // Total marks evaluator gave
    const totalScore = scores.reduce((a, b) => a + b, 0);

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
