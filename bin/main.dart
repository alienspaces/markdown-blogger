// Publish articles to monsterweekly.com
import 'dart:io';

import 'package:args/args.dart';
import 'package:markdown_blogger/markdown_blogger.dart';

const argDelete = 'delete';
const argPublish = 'publish';

// main
Future<void> main(List<String> arguments) async {
  // Arguments
  final parser = ArgParser()
    ..addFlag(argDelete, negatable: false)
    ..addFlag(argPublish, negatable: false);

  var argResults = parser.parse(arguments);

  // Delete all posts
  if (argResults[argDelete]) {
    print("Deleting posts");
    // Delete all wordpress posts
    await deleteArticles();
  }

  // Publish all local posts
  if (argResults[argPublish]) {
    print("Publishing posts");
    await publishArticles();
  }

  print("Main - Done");
}

void publishArticles() async {
  // Get auth token data
  var authTokenData = await wpAuthToken();
  if (authTokenData == null) {
    print("publishArticles - authTokenData is null");
    return null;
  }

  // Site
  String site = Platform.environment['WORDPRESS_SITE'];
  if (site == null) {
    print("publishArticles - WORDPRESS_SITE is null");
    return null;
  }

  // Get articles
  var articles = getArticles();
  if (articles == null) {
    print("publishArticles - no articles found");
    return;
  }

  for (Article article in articles) {
    // Get article meta
    var meta = new Meta(article.metaFile);
    print("publishArticles - meta ${meta.toString()}");

    // Each "article" object has a list of all the files that are currently in
    // the article directory.
    // The "meta" object contains any current meta data for files that are
    // currently or have once been in the article directory

    // For each of the article files:
    // - If meta data exists then we update the remote file
    // - If meta data does not exist then we create the remote file

    // We need to cycle through article media files first as the article
    // content itself will need updated media URL's
    for (var mediaFile in article.mediaFiles) {
      var mediaMeta = meta.getMeta(mediaFile.path);

      // Update or create remote media
      if (mediaMeta != null) {
        // Check modified
        DateTime localModified = mediaFile.lastModifiedSync().toUtc();
        DateTime remoteModified = DateTime.parse(mediaMeta.modified);
        if (localModified.isAfter(remoteModified)) {
          print("publishArticles - updating id ${mediaMeta.id}");
          print("publishArticles - updating media ${mediaFile.path}");

          // Update remote media if local media is newer
          var wordpressMedia = await wpUpdateMedia(
            authTokenData,
            mediaFile.path,
            mediaMeta.id,
          );
          print("publishArticles - updated media ID ${wordpressMedia.id}");
          print("publishArticles - updated media URL ${wordpressMedia.url}");

          // Update meta with new modified time
          mediaMeta.modified = wordpressMedia.modified;
          meta.updateMediaMeta(mediaMeta);
        }
      } else {
        print("publishArticles - creating media ${mediaFile.path}");

        // Create remote media
        var wordpressMedia = await wpCreateMedia(
          authTokenData,
          mediaFile.path,
        );
        print("publishArticles - created media ID ${wordpressMedia.id}");
        print("publishArticles - created media URL ${wordpressMedia.url}");

        // Add meta for new media
        var mediaMeta = new MetaData(
          wordpressMedia.id,
          wordpressMedia.siteId,
          wordpressMedia.url,
          wordpressMedia.modified,
          mediaFile.path,
        );
        meta.addMediaMeta(mediaMeta);
      }

      // Assign article featured image
      if (mediaFile.path.split('/').last.startsWith('featured')) {
        article.featuredImageId = mediaMeta.id;
      }
    }

    // TODO: Delete remote files defined in meta media that don't exist anymore

    // For each of the meta media data:
    // - If the article media file does not exist then delete the remote file
    //   and remove the meta

    // Replace article URL's with actual media meta URLS's
    for (var mediaMeta in meta.mediaMeta) {
      var filename = mediaMeta.localPath.split('/').last;
      var url = mediaMeta.url;
      article.articleReplace(filename, url);
    }

    WordpressPost wordpressPost;

    if (meta.articleMeta != null) {
      // Check modified
      DateTime localModified = article.articleFile.lastModifiedSync().toUtc();
      DateTime remoteModified = DateTime.parse(meta.articleMeta.modified);
      if (localModified.isAfter(remoteModified)) {
        print("publishArticles - updating post ID ${meta.articleMeta.id}");
        print("publishArticles - updating post HTML ${article.articleHTML()}");
        // Update article
        wordpressPost = await wpUpdatePost(
          authTokenData,
          article,
          site,
          meta.articleMeta.id,
        );
        print("publishArticles - updated post ID ${wordpressPost.id}");
      }
    } else {
      print("publishArticles - creating post HTML ${article.articleHTML()}");
      // Create article
      wordpressPost = await wpCreatePost(
        authTokenData,
        article,
        site,
      );
      print("publishArticles - created post ID ${wordpressPost.id}");
    }

    // Update article meta
    if (wordpressPost != null) {
      var articleMeta = new MetaData(
        wordpressPost.id,
        wordpressPost.siteId,
        wordpressPost.url,
        wordpressPost.modified,
        article.articleFile.path,
      );
      meta.updateArticleMeta(articleMeta);
    }

    // Save meta data
    meta.saveFile();
  }
}

// deleteArticles - deletes all articles and associated media, keeps all local
// files but removes the .meta file
void deleteArticles() async {
  // Get auth token data
  var authTokenData = await wpAuthToken();

  // Site
  String site = Platform.environment['WORDPRESS_SITE'];
  if (site.length == 0) {
    print("wpDelete - WORDPRESS_SITE not defined");
    return null;
  }

  // Get articles
  var articles = getArticles();

  for (var article in articles) {
    // Get article meta
    var meta = new Meta(article.metaFile);

    var response = await wpDelete(
      authTokenData,
      site,
      meta.articleMeta.id,
    );
    print("deleteArticles - delete response $response");
  }
}
