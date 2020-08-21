import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as Http;

// getConfig - previously used for managing config in JSON
void getConfig() {
  final config = File("config.json");
  String content = config.readAsStringSync();
  print(jsonDecode(content));
}

// getArticles - returns a list of local articles for site
List<FileSystemEntity> getArticles() {
  // Articles directory for site
  var articleDir = new Directory("./articles");

  // Check the directory exists or return
  if (articleDir.existsSync() != true) {
    return null;
  }

  // List directory contents, recursing into sub-directories,
  // but not following symbolic links.
  List<FileSystemEntity> articles =
      articleDir.listSync(recursive: false, followLinks: false);

  return articles;
}

// createPost -
Future<Map<String, dynamic>> createPost(
    Map<String, dynamic> authTokenData) async {
  // Post request data
  Map postRequestData = {
    'title': 'Test Post Creation',
    'content': 'Test Post Content',
    'status': 'publish',
  };

  String accessToken = authTokenData["access_token"];

  String url =
      'https://public-api.wordpress.com/rest/v1.2/sites/alienspacesblog.wordpress.com/posts/new';

  Map<String, String> headers = new HashMap();
  headers['Accept'] = 'application/json';
  headers['Content-type'] = 'application/x-www-form-urlencoded; charset=UTF-8';
  headers['Authorization'] = 'Bearer $accessToken';

  Http.Response response = await Http.post(url,
      headers: headers,
      body: postRequestData,
      encoding: Encoding.getByName('utf-8'));

  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  Map<String, dynamic> postResponseData = jsonDecode(response.body);

  return postResponseData;
}

// getAuthToken -
Future<Map<String, dynamic>> getAuthToken() async {
  // Source configuration from environment
  String clientID = Platform.environment['WORDPRESS_CLIENT_ID'];
  String clientSecret = Platform.environment['WORDPRESS_CLIENT_SECRET'];
  String accountUsername = Platform.environment['WORDPRESS_ACCOUNT_USERNAME'];
  String accountPassword = Platform.environment['WORDPRESS_ACCOUNT_PASSWORD'];

  // Auth token request data
  Map authRequestData = {
    'client_id': clientID,
    'client_secret': clientSecret,
    'grant_type': 'password',
    'username': accountUsername,
    'password': accountPassword,
  };

  String url = 'https://public-api.wordpress.com/oauth2/token';
  Map<String, String> headers = new HashMap();
  headers['Accept'] = 'application/json';
  headers['Content-type'] = 'application/x-www-form-urlencoded; charset=UTF-8';

  Http.Response response = await Http.post(url,
      headers: headers,
      body: authRequestData,
      encoding: Encoding.getByName('utf-8'));

  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  Map<String, dynamic> authResponseData = jsonDecode(response.body);

  return authResponseData;
}
