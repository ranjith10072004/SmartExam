const mongoose = require("mongoose");

const QuestionSchema = new mongoose.Schema({
  questionText: { type: String, required: true },

  // mcq, multiple, truefalse, short, long
  type: {
    type: String,
    enum: ["mcq", "multiple", "truefalse", "short", "long"],
    required: true,
  },

  options: [{ type: String }],

  // Correct answer stored but NEVER sent to student
  correctAnswer: mongoose.Schema.Types.Mixed,
});

const ExamSchema = new mongoose.Schema({
  title: { type: String, required: true },
  description: String,

  examStartTime: { type: Date, required: true },
  examEndTime: { type: Date, required: true },

  // 🔥 Missing in your schema — required for duration calculation
  duration: { type: Number, required: true },

  questions: [QuestionSchema],

  assignedTo: [
    {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
    },
  ],

  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
  },

  createdAt: { type: Date, default: Date.now },
});

// 🔥🔥🔥 REQUIRED: Export Model (You forgot this)
module.exports = mongoose.model("Exam", ExamSchema);
