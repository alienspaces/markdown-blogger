import 'dart:io';

import 'package:markdown/markdown.dart';

// Article -
class Article {
  Directory articleDirectory;
  File articleFile;
  List<File> mediaFiles;
  File metaFile;
  int featuredImageId;
  String _html;

  String articleHTML() {
    if (this.articleFile == null) {
      print("articleHTML - error, articleFile is null");
      return null;
    }
    if (this._html == null) {
      this._html = markdownToHtml(this.articleFile.readAsStringSync());
    }
    return this._html;
  }

  String articleReplace(String replaceString, String withString) {
    if (this._html == null) {
      this._html = markdownToHtml(this.articleFile.readAsStringSync());
    }
    print("articleReplaceURL - replace $replaceString");
    print("articleReplaceURL - with $withString");
    this._html = this._html.replaceAll(replaceString, withString);
    return this._html;
  }

  String articleTitle() {
    // Try to get title from <h1> title in content
    String articleTitle = this.articleTitleFromContent();
    if (articleTitle == null) {
      articleTitle = this.articleTitleFromFilename();
    }

    return articleTitle;
  }

  String articleTitleFromContent() {
    String articleTitle;
    List<String> articleLines = this.articleHTML().split("\n");
    if (articleLines.first.startsWith('<h1>')) {
      articleTitle = articleLines.first.replaceAll('<h1>', '');
      articleTitle = articleTitle.replaceAll('</h1>', '');
      articleTitle = articleTitle.replaceAll('-', ' ');
      articleTitle = articleTitle.replaceAll('_', ' ');
      articleTitle = articleTitle.toUpperCase();
    }
    return articleTitle;
  }

  String articleTitleFromFilename() {
    if (this.articleFile == null) {
      print("articleTitleFromFilename - error, articleFile is null");
      return null;
    }

    String articlePath = this.articleFile.path;
    String articleFilename = articlePath.split('/').last;
    String articleTitle = articleFilename.split('.').first;
    articleTitle = articleTitle.replaceAll('-', ' ');
    articleTitle = articleTitle.replaceAll('_', ' ');
    articleTitle = articleTitle.toUpperCase();

    return articleTitle;
  }

  String articleContent() {
    // Remove initial title if it exists
    List<String> articleLines = this.articleHTML().split("\n");
    if (articleLines.first.startsWith('<h1>')) {
      articleLines.removeAt(0);
    }
    String articleContent = articleLines.join("\n");
    // Add a hard line break after all paragraphs
    articleContent = articleContent.replaceAll('</p>', "</p>\n");
    // Center all images
    articleContent = articleContent.replaceAll(
      '<p><img',
      '<p style="text-align:center"><img',
    );
    return articleContent;
  }

  // Constructor
  Article(Directory articleDirectory) {
    this.articleDirectory = articleDirectory;
    this.mediaFiles = [];

    List<FileSystemEntity> articleFiles =
        this.articleDirectory.listSync(recursive: false, followLinks: false);

    for (FileSystemEntity articleFile in articleFiles) {
      String filePath = (articleFile as File).path;
      if (filePath.endsWith(".md")) {
        this.articleFile = (articleFile as File);
      } else if (filePath.endsWith(".meta")) {
        this.metaFile = (articleFile as File);
      } else {
        this.mediaFiles.add((articleFile as File));
      }
    }

    // Create meta file if it doesn't exist.
    if (this.metaFile == null) {
      this.metaFile = new File(this.articleDirectory.path + '/.meta');
      this.metaFile.createSync(recursive: false);
    }
  }
}

// Static functions

// getArticles - returns a list of local articles for site
List<Article> getArticles() {
  // Articles directory for site
  var articleDir = new Directory("./articles");

  // Check the directory exists or return
  if (articleDir.existsSync() != true) {
    print("getArticles - Missing articles directory");
    return null;
  }

  List<Article> localArticles = [];

  // Article directories
  List<FileSystemEntity> articleDirectories =
      articleDir.listSync(recursive: false, followLinks: false);

  // Article directory files
  for (FileSystemEntity articleDirectory in articleDirectories) {
    var localArticle = new Article(articleDirectory);

    localArticles.add(localArticle);
  }

  return localArticles;
}
