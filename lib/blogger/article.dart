import 'dart:io';

import 'package:logging/logging.dart';
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
    // Logger
    final log = Logger('articleHTML');

    if (this.articleFile == null) {
      log.warning("articleHTML - error, articleFile is null");
      return null;
    }
    if (this._html == null) {
      this._html = markdownToHtml(this.articleFile.readAsStringSync());
    }
    return this._html;
  }

  String articleReplaceURL(String replaceURL, String withURL) {
    // Logger
    final log = Logger('articleReplaceURL');

    if (this._html == null) {
      this._html = markdownToHtml(this.articleFile.readAsStringSync());
    }

    log.fine("Replace $replaceURL");
    log.fine("With $withURL");

    var html = this.articleHTML();
    this._html = html.replaceAll(replaceURL, withURL);

    return this._html;
  }

  bool articleContainsURL(String containsURL) {
    // Logger
    final log = Logger('articleContainsURL');

    if (this._html == null) {
      this._html = markdownToHtml(this.articleFile.readAsStringSync());
    }

    var html = this.articleHTML();

    var contains = html.contains(containsURL);

    log.fine("Contains HTML $html URL $containsURL contains ${contains}");

    return contains;
  }

  String articleTitle() {
    // Logger
    final log = Logger('articleTitle');

    // Try to get title from <h1> title in content
    String articleTitle = this.articleTitleFromContent();
    if (articleTitle == null) {
      articleTitle = this.articleTitleFromFilename();
    }

    log.fine("$articleTitle");

    return articleTitle;
  }

  String articleTitleFromContent() {
    // Logger
    final log = Logger('articleTitleFromContent');

    String articleTitle;
    List<String> articleLines = this.articleHTML().split("\n");
    if (articleLines.first.startsWith('<h1>')) {
      articleTitle = articleLines.first.replaceAll('<h1>', '');
      articleTitle = articleTitle.replaceAll('</h1>', '');
      articleTitle = articleTitle.replaceAll('-', ' ');
      articleTitle = articleTitle.replaceAll('_', ' ');
      articleTitle = articleTitle.toUpperCase();
    }

    log.fine("$articleTitle");

    return articleTitle;
  }

  String articleTitleFromFilename() {
    // Logger
    final log = Logger('articleTitleFromFilename');

    if (this.articleFile == null) {
      log.warning("Error, articleFile is null");
      return null;
    }

    String articlePath = this.articleFile.path;
    String articleFilename = articlePath.split('/').last;
    String articleTitle = articleFilename.split('.').first;
    articleTitle = articleTitle.replaceAll('-', ' ');
    articleTitle = articleTitle.replaceAll('_', ' ');
    articleTitle = articleTitle.toUpperCase();

    log.fine("$articleTitle");

    return articleTitle;
  }

  String articleExcerpt() {
    // Logger
    final log = Logger('articleExcerpt');

    // Remove initial title if it exists
    List<String> htmlLines = this.articleHTML().split("\n");

    String articleExcerpt = "";
    bool collecting = false;
    for (var htmlLine in htmlLines) {
      log.fine("Checking HTML $htmlLine");
      if (collecting) {
        articleExcerpt = articleExcerpt + htmlLine;
      }
      // Find the first blockquote
      if (htmlLine.startsWith('<blockquote>')) {
        articleExcerpt = articleExcerpt + htmlLine;
        collecting = true;
      }
      // Find the closing blockquote
      if (collecting && htmlLine.endsWith('</blockquote>')) {
        articleExcerpt = articleExcerpt + htmlLine;
        collecting = false;
        break;
      }
    }

    // When no blockquotes to use are excerpt use the first paragraph.
    if (articleExcerpt == "") {
      for (var htmlLine in htmlLines) {
        log.fine("Checking HTML $htmlLine");
        // Find the first paragraph
        if (htmlLine.startsWith('<p>')) {
          articleExcerpt = htmlLine;
          break;
        }
      }
    }

    var match = RegExp(r"\<.*?\>");
    articleExcerpt = articleExcerpt.replaceAll(match, '');

    log.fine("Using HTML $articleExcerpt");

    return articleExcerpt;
  }

  String articleContent() {
    // Logger
    final log = Logger('articleContent');

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

    log.fine("$articleContent");

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
  // Logger
  final log = Logger('getArticles');

  // Articles directory for site
  var articleDir = new Directory("./articles");

  // Check the directory exists or return
  if (articleDir.existsSync() != true) {
    log.warning("getArticles - Missing articles directory");
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
