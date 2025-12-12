class Config {
  // Change only this when ngrok refreshes
  static const String baseUrl =
      "https://unamusing-hypodermically-candice.ngrok-free.dev";

  // AUTH Endpoints (correct paths)
  static const String loginUrl = "$baseUrl/auth/login";
  static const String registerUrl = "$baseUrl/auth/register";
  static const String createexamUrl = "$baseUrl/admin/createexam";
  static const String studentexamUrl = "$baseUrl/student/exams";

  static String token = "";
}