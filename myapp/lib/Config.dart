class Config {
  // Change only this when ngrok refreshes
  static const String ngrokBase =
      "https://unamusing-hypodermically-candice.ngrok-free.dev";

  // AUTH Endpoints (correct paths)
  static const String loginUrl = "$ngrokBase/auth/login";
  static const String registerUrl = "$ngrokBase/auth/register";
  static const String createexamUrl = "$ngrokBase/admin/createexam";
  static const String studentexamUrl = "$ngrokBase/student/exam";

  static String token = "";
}
