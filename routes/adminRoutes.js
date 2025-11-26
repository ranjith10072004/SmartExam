const router = require("express").Router();
const Result = require("../models/result");
const auth = require("../middleware/auth");

// Evaluator manually sets score
router.post("/evaluate/:resultId", auth(["admin"]), async (req, res) => {
  try {
    const { resultId } = req.params;
    const { score } = req.body;

    const result = await Result.findById(resultId);
    if (!result) return res.status(404).json({ msg: "Result not found" });

    result.score = score;
    result.status = "evaluated";
    result.evaluatedBy = req.user.id;
    result.evaluatedAt = new Date();

    await result.save();

    res.json({
      msg: "Result evaluated successfully",
      score: result.score,
      studentId: result.studentId,
      examId: result.examId,
    });
  } catch (error) {
    res.status(500).json({ msg: "Error", error: error.message });
  }
});

module.exports = router;
