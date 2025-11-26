const mongoose = require("mongoose");

const ResultSchema = new mongoose.Schema({
  examId: { type: mongoose.Schema.Types.ObjectId, ref: "Exam", required: true },
  studentId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
  },

  answers: Array, // student's raw answers

  score: { type: Number, default: 0 },
  totalMarks: Number,

  status: {
    type: String,
    enum: ["pending", "evaluated"],
    default: "pending",
  },

  evaluatedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    default: null,
  },

  submittedAt: { type: Date, default: Date.now },
  evaluatedAt: { type: Date },
});

module.exports = mongoose.model("Result", ResultSchema);
