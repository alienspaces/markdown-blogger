import 'dart:io';

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
