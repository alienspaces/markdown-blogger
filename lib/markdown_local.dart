import 'dart:convert';
import 'dart:io';

import 'package:markdown/markdown.dart';

// Meta -
class Meta {
  int Id;
  int siteId;
  String modified;
}

// LocalArticle -
class LocalArticle {
  final Directory articleDirectory;
  final File markdownFile;
  List<File> mediaFiles;
  final File metaFile;
  String _html;
  Meta _meta;

  Meta articleMeta() {
    if (this._meta == null && this.metaFile != null) {
      this._meta = new Meta();
      dynamic metaJson = jsonDecode(this.metaFile.readAsStringSync());
      if (metaJson != null) {
        this._meta.Id = metaJson['ID'];
        this._meta.siteId = metaJson['site_ID'];
        this._meta.modified = metaJson['modified'];
      }
      print("Article META ${this._meta}");
    }
    return this._meta;
  }

  void updateMeta(Map<String, dynamic> response) {
    print("updateMeta - response - $response");
    final String metaFile = this.articleDirectory.path + "/.meta";
    Map<String, dynamic> metaData = {
      'ID': response['ID'],
      'site_ID': response['site_ID'],
      'modified': response['modified'],
    };

    new File(metaFile).writeAsStringSync(jsonEncode(metaData));
  }

  int postId() {
    Meta articleMeta = this.articleMeta();
    if (articleMeta != null) {
      return articleMeta.Id;
    }
    return null;
  }

  int siteId() {
    Meta articleMeta = this.articleMeta();
    if (articleMeta != null) {
      return articleMeta.siteId;
    }
    return null;
  }

  String modified() {
    Meta articleMeta = this.articleMeta();
    if (articleMeta != null) {
      return articleMeta.modified;
    }
    return null;
  }

  String articleHTML() {
    if (this.markdownFile == null) {
      print("articleHTML - error, markdownFile is null");
      return null;
    }
    if (this._html == null) {
      this._html = markdownToHtml(this.markdownFile.readAsStringSync());
      print("Article HTML ${this._html}");
    }
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
    if (this.markdownFile == null) {
      print("articleTitleFromFilename - error, markdownFile is null");
      return null;
    }

    String articlePath = this.markdownFile.path;
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
    return articleContent;
  }

  LocalArticle(
    this.articleDirectory,
    this.markdownFile,
    this.mediaFiles,
    this.metaFile,
  );
}

// getArticles - returns a list of local articles for site
List<LocalArticle> getArticles() {
  // Articles directory for site
  var articleDir = new Directory("./articles");

  // Check the directory exists or return
  if (articleDir.existsSync() != true) {
    print("getArticles - Missing articles directory");
    return null;
  }

  List<LocalArticle> localArticles = [];

  // Article directories
  List<FileSystemEntity> articleDirectories =
      articleDir.listSync(recursive: false, followLinks: false);

  // Article directory files
  for (FileSystemEntity articleDirectory in articleDirectories) {
    List<FileSystemEntity> articleFiles = (articleDirectory as Directory)
        .listSync(recursive: false, followLinks: false);

    File markdownFile;
    List<File> mediaFiles = [];
    File metaFile;

    for (FileSystemEntity articleFile in articleFiles) {
      String filePath = (articleFile as File).path;
      if (filePath.endsWith(".md")) {
        markdownFile = (articleFile as File);
      } else if (filePath.endsWith("meta")) {
        metaFile = (articleFile as File);
      } else {
        mediaFiles.add((articleFile as File));
      }
    }

    LocalArticle localArticle = new LocalArticle(
      articleDirectory,
      markdownFile,
      mediaFiles,
      metaFile,
    );
    localArticles.add(localArticle);
  }

  return localArticles;
}
