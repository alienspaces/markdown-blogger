// Publish articles to monsterweekly.com
import 'dart:io';
import 'package:markdown_blogger/markdown_blogger.dart';

// main
Future<void> main() async {
  // Get an authorization token
  Map<String, dynamic> authTokenData = await getAuthToken();
  print("Main - authTokenData $authTokenData");

  // Get list of articles for site
  List<FileSystemEntity> articles = getArticles();

  // Check there are articles before processing them
  if (articles == null) {
    return;
  }

  articles.forEach((FileSystemEntity article) {
    // Article path
    String path = article.path;
    print("Article path - ${path}");
  });

  // await createPost(authTokenData);
  print("Main - Done");
}
