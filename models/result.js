const mongoose = require("mongoose");

const ResultSchema = new mongoose.Schema({
  examId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Exam",
    required: true,
  },

  studentId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
  },

  // Raw answers student submitted
  answers: {
    type: Array,
    required: true,
  },

  // Evaluator/Teacher assigned score
  score: {
    type: Number,
    default: 0,
  },

  // Total questions in that exam
  totalMarks: {
    type: Number,
    required: true,
  },

  // Status of evaluation
  status: {
    type: String,
    enum: ["pending", "evaluated"],
    default: "pending",
  },

  // Which admin/evaluator graded this exam
  evaluatedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    default: null,
  },

  // When student submitted
  submittedAt: {
    type: Date,
    default: Date.now,
  },

  // When evaluator graded it
  evaluatedAt: {
    type: Date,
  },
});

module.exports = mongoose.model("Result", ResultSchema);
