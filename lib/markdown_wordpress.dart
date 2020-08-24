import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as Http;

import 'markdown_blogger.dart';

class WordpressPost {
  final int id;
  final int siteId;
  final String title;
  final String content;
  final String featuredImage;

  WordpressPost(
      this.id, this.siteId, this.title, this.content, this.featuredImage);
}

// wpAuthToken -
Future<Map<String, dynamic>> wpAuthToken() async {
  // Source configuration from environment
  String clientID = Platform.environment['WORDPRESS_CLIENT_ID'];
  if (clientID == null) {
    throw new Exception(["WORDPRESS_CLIENT_ID is required"]);
  }
  String clientSecret = Platform.environment['WORDPRESS_CLIENT_SECRET'];
  if (clientSecret == null) {
    throw new Exception(["WORDPRESS_CLIENT_SECRET is required"]);
  }
  String accountUsername = Platform.environment['WORDPRESS_USERNAME'];
  if (accountUsername == null) {
    throw new Exception(["WORDPRESS_USERNAME is required"]);
  }
  String accountPassword = Platform.environment['WORDPRESS_PASSWORD'];
  if (accountPassword == null) {
    throw new Exception(["WORDPRESS_PASSWORD is required"]);
  }

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

  if (response.statusCode != 200) {
    print('wpAuthToken - status: ${response.statusCode}');
    print('wpAuthToken - body: ${response.body}');
    return null;
  }

  Map<String, dynamic> authResponseData = jsonDecode(response.body);

  return authResponseData;
}

// wpCreate -
Future<Map<String, dynamic>> wpCreate(
    Map<String, dynamic> authTokenData, LocalArticle article) async {
  // Access token
  String accessToken = authTokenData["access_token"];

  String articleTitle = article.articleTitle();
  String articleContent = article.articleContent();

  // Post request data
  Map requestData = {
    'title': articleTitle,
    'content': articleContent,
    'context': 'html',
    'format': 'image',
    'status': 'publish',
  };

  // Site
  String site = Platform.environment['WORDPRESS_SITE'];
  if (site.length == 0) {
    throw new Exception(["WORDPRESS_SITE is required"]);
  }

  String url =
      "https://public-api.wordpress.com/rest/v1.2/sites/$site/posts/new";

  Map<String, String> headers = new HashMap();
  headers['Accept'] = 'application/json';
  headers['Content-type'] = 'application/x-www-form-urlencoded; charset=UTF-8';
  headers['Authorization'] = 'Bearer $accessToken';

  Http.Response response = await Http.post(
    url,
    headers: headers,
    body: requestData,
    encoding: Encoding.getByName('utf-8'),
  );

  if (response.statusCode != 200) {
    print('wpCreate - status: ${response.statusCode}');
    print('wpCreate - body: ${response.body}');
    return null;
  }

  Map<String, dynamic> responseData = jsonDecode(response.body);

  return responseData;
}

// wpCreate -
Future<Map<String, dynamic>> wpUpdate(
    Map<String, dynamic> authTokenData, LocalArticle article) async {
  // Access token
  String accessToken = authTokenData["access_token"];

  String articleTitle = article.articleTitle();
  String articleContent = article.articleContent();

  // Post request data
  Map requestData = {
    'title': articleTitle,
    'content': articleContent,
    'context': 'html',
    'format': 'image',
    'status': 'publish',
  };

  int siteId = article.metaSiteId();
  int postId = article.metaPostId();

  String url =
      "https://public-api.wordpress.com/rest/v1.2/sites/$siteId/posts/$postId";

  Map<String, String> headers = new HashMap();
  headers['Accept'] = 'application/json';
  headers['Content-type'] = 'application/x-www-form-urlencoded; charset=UTF-8';
  headers['Authorization'] = 'Bearer $accessToken';

  Http.Response response = await Http.post(
    url,
    headers: headers,
    body: requestData,
    encoding: Encoding.getByName('utf-8'),
  );

  if (response.statusCode != 200) {
    print('wpUpdate - status: ${response.statusCode}');
    print('wpUpdate - body: ${response.body}');
    return null;
  }

  Map<String, dynamic> responseData = jsonDecode(response.body);

  return responseData;
}

// wpDeleteAll - delete all posts
void wpDeleteAll(Map<String, dynamic> authTokenData) async {
  // Get all posts
  List<WordpressPost> wpPosts = await wpGetAll(authTokenData);
  if (wpPosts.length == 0) {
    print("wpDeleteAll - No posts to delete");
    return;
  }

  // NOTE: forEach does not look at the return value to if we want
  // to iterate over this loop syncronously we need to use a for loop
  for (WordpressPost wpPost in wpPosts) {
    print("wpDeleteAll - Deleting post ID ${wpPost.id}");
    await wpDelete(authTokenData, wpPost);
  }
}

// wpDelete - delete a post
Future<Map<String, dynamic>> wpDelete(
    Map<String, dynamic> authTokenData, WordpressPost post) async {
  // Access token
  String accessToken = authTokenData["access_token"];

  // Site
  String site = Platform.environment['WORDPRESS_SITE'];
  if (site.length == 0) {
    print("wpDelete - WORDPRESS_SITE not defined");
    return null;
  }

  // Post ID
  int postId = post.id;
  if (postId == null) {
    print("wpDelete - post ID not defined");
    return null;
  }

  // Site ID
  int siteId = post.siteId;
  if (siteId == null) {
    print("wpDelete - site ID not defined");
    return null;
  }

  String url =
      "https://public-api.wordpress.com/rest/v1.1/sites/$siteId/posts/$postId/delete";

  Map<String, String> headers = new HashMap();
  headers['Accept'] = 'application/json';
  headers['Content-type'] = 'application/x-www-form-urlencoded; charset=UTF-8';
  headers['Authorization'] = 'Bearer $accessToken';

  var client = Http.Client();
  Http.Response response;
  try {
    response = await client.post(
      url,
      headers: headers,
    );
  } finally {
    client.close();
  }

  if (response.statusCode != 200) {
    print('wpDelete - status: ${response.statusCode}');
    print('wpDelete - body: ${response.body}');
    return null;
  }

  Map<String, dynamic> responseData = jsonDecode(response.body);

  return responseData;
}

// wpGetAll - returns all posts for a site
Future<List<WordpressPost>> wpGetAll(Map<String, dynamic> authTokenData) async {
  // Access token
  String accessToken = authTokenData["access_token"];

  // Site
  String site = Platform.environment['WORDPRESS_SITE'];
  if (site.length == 0) {
    throw new Exception(["WORDPRESS_SITE is required"]);
  }

  String url = "https://public-api.wordpress.com/rest/v1.2/sites/$site/posts/";

  Map<String, String> headers = new HashMap();
  headers['Accept'] = 'application/json';
  headers['Content-type'] = 'application/x-www-form-urlencoded; charset=UTF-8';
  headers['Authorization'] = 'Bearer $accessToken';

  Http.Response response = await Http.get(
    url,
    headers: headers,
  );

  if (response.statusCode != 200) {
    print('wpGetAll - Response status: ${response.statusCode}');
    print('wpGetAll - Response body: ${response.body}');
    return null;
  }

  Map<String, dynamic> responseData = jsonDecode(response.body);
  List<dynamic> posts = responseData['posts'];
  List<WordpressPost> wpPosts = new List<WordpressPost>();
  posts.forEach((post) {
    WordpressPost wpPost = new WordpressPost(
      post['ID'],
      post['site_ID'],
      post['title'],
      post['content'],
      post['featured_image'],
    );
    wpPosts.add(wpPost);
  });
  return wpPosts;
}
