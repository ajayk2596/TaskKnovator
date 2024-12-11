import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:task_knovator/models/posts/post_model.dart';

class PostApiController {

  Future<List<PostModel>> fetchAllPosts() async {
    try {
      final response = await http
          .get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => PostModel.fromJson(json)).toList();
      } else {
        print(
            'Error: Failed to fetch posts. Status Code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<PostModel?> fetchPostDetails(int id) async {
    try {
      final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/posts/$id'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PostModel.fromJson(data);
      } else {
        print(
            'Error: Failed to fetch post. Status Code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
