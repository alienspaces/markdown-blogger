// Publish articles to monsterweekly.com
import 'dart:io';

import 'package:args/args.dart';

import 'package:markdown_blogger/markdown_blogger.dart';

const argDelete = 'delete';

// main
Future<void> main(List<String> arguments) async {
  int exitCode = 0;
  // Arguments
  final parser = ArgParser()..addFlag(argDelete, negatable: false);

  ArgResults argResults = parser.parse(arguments);

  // Delete all remote posts
  if (argResults[argDelete]) {
    // Delete all wordpress posts
    await wpDeleteAll();
    exit(exitCode);
  }

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
