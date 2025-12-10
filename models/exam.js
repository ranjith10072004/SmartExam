const mongoose = require("mongoose");

// --------------------------------------------------
// QUESTION SCHEMA
// --------------------------------------------------
const QuestionSchema = new mongoose.Schema({
  questionText: { type: String, required: true },

  // Question type can be subjective or optional MCQ if needed
  type: {
    type: String,
    enum: ["subjective", "mcq"],
    default: "subjective",
  },

  // Used only if type = mcq
  options: [{ type: String }],

  // Correct answer for objective questions only
  correctAnswer: { type: mongoose.Schema.Types.Mixed, default: null },

  // For subjective exams
  allowWrittenAnswer: { type: Boolean, default: true },

  // Allow file upload (pdf/jpg/png)
  allowFileUpload: { type: Boolean, default: true },

  // Optional marks weight
  maxMarks: { type: Number, default: 10 },
});

// --------------------------------------------------
// EXAM SCHEMA
// --------------------------------------------------
const ExamSchema = new mongoose.Schema({
  title: { type: String, required: true },
  description: String,

  examStartTime: { type: Date, required: true },
  examEndTime: { type: Date, required: true },

  duration: { type: Number, required: true }, // minutes
  proctorCode: { type: String, required: true },
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

// Export model
module.exports = mongoose.model("Exam", ExamSchema);
