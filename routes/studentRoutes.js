const router = require("express").Router();
const Exam = require("../models/exam");
const Result = require("../models/result");
const auth = require("../middleware/auth");

// ✅ 1. Student fetches exam (without correct answers)
router.get("/exam/:examId", auth(["student"]), async (req, res) => {
  try {
    const exam = await Exam.findById(req.params.examId).lean();

    if (!exam) return res.status(404).json({ msg: "Exam not found" });

    // ❗ Remove correctAnswer before sending to student
    exam.questions = exam.questions.map((q) => ({
      questionText: q.questionText,
      type: q.type,
      options: q.options,
      // correctAnswer removed intentionally
    }));

    res.json(exam);
  } catch (error) {
    res.status(500).json({ msg: "Error", error: error.message });
  }
});

// ✅ 2. Student submits exam answers → status = pending
router.post("/submit/:examId", auth(["student"]), async (req, res) => {
  try {
    const { examId } = req.params;
    const { answers } = req.body;

    const exam = await Exam.findById(examId);
    if (!exam) return res.status(404).json({ msg: "Exam not found" });

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

module.exports = router;
