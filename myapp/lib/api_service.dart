import 'package: myapp/config.dart';
import 'dart:convert';

class ApiService {
  final client = HttpClient();

  Future<void> fetchData() async {
    // The BASE_URL is dynamically set here
    final url = Uri.parse('${Config.BASE_URL}/api/data');
    final request = await client.getUrl(url);
    final response = await request.close();
    // ... handle response
  }
}