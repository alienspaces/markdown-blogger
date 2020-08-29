// Publish articles to monsterweekly.com
import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart';

import 'package:markdown_blogger/markdown_blogger.dart';

const argDelete = 'delete';
const argPublish = 'publish';

// main
Future<void> main(List<String> arguments) async {
  // Logging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    print(
        '${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
  });

  // Logger
  final log = Logger('main');

  // Arguments
  final parser = ArgParser()
    ..addFlag(argDelete, negatable: false)
    ..addFlag(argPublish, negatable: false);

  var argResults = parser.parse(arguments);

  // Delete all posts
  if (argResults[argDelete]) {
    log.info("Deleting posts");
    // Delete all wordpress posts
    await deleteArticles();
  }

  // Publish all local posts
  if (argResults[argPublish]) {
    log.info("Publishing posts");
    await publishArticles();
  }

  log.info("Main - Done");
}

void publishArticles() async {
  // Logger
  final log = Logger('publishArticles');

  // Get auth token data
  var authTokenData = await wpAuthToken();
  if (authTokenData == null) {
    log.warning("authTokenData is null");
    return null;
  }

  // Site
  String site = Platform.environment['WORDPRESS_SITE'];
  if (site == null) {
    log.warning("WORDPRESS_SITE is null");
    return null;
  }

  // Get articles
  var articles = getArticles();
  if (articles == null) {
    log.warning("No articles found");
    return;
  }

  for (Article article in articles) {
    // Get article meta
    var meta = new Meta(article.metaFile);

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
          log.info("Updating id ${mediaMeta.id}");
          log.info("Updating media ${mediaFile.path}");

          // Update remote media if local media is newer
          var wordpressMedia = await wpUpdateMedia(
            authTokenData,
            mediaFile.path,
            mediaMeta.id,
          );
          log.info("Updated media ID ${wordpressMedia.id}");
          log.info("Updated media URL ${wordpressMedia.url}");

          // Update meta with new modified time
          mediaMeta.modified = wordpressMedia.modified;
          meta.updateMediaMeta(mediaMeta);
        }
      } else {
        log.info("Creating media ${mediaFile.path}");

        // Create remote media
        var wordpressMedia = await wpCreateMedia(
          authTokenData,
          mediaFile.path,
        );
        log.info("Created media ID ${wordpressMedia.id}");
        log.info("Created media URL ${wordpressMedia.url}");

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

    // Update or create remote article post
    WordpressPost wordpressPost;

    if (meta.articleMeta != null) {
      // Check modified
      DateTime localModified = article.articleFile.lastModifiedSync().toUtc();
      DateTime remoteModified = DateTime.parse(meta.articleMeta.modified);
      if (localModified.isAfter(remoteModified)) {
        log.info("Updating post ID ${meta.articleMeta.id}");
        log.info("Updating post Path ${article.articleFile.path}");
        log.fine("Updating post HTML ${article.articleHTML()}");
        // Update article
        wordpressPost = await wpUpdatePost(
          authTokenData,
          article,
          site,
          meta.articleMeta.id,
        );
        log.info("Updated post ID ${wordpressPost.id}");
      }
    } else {
      log.info("Creating post Path ${article.articleFile.path}");
      log.fine("Creating post HTML ${article.articleHTML()}");
      // Create article
      wordpressPost = await wpCreatePost(
        authTokenData,
        article,
        site,
      );
      log.info("Created post ID ${wordpressPost.id}");
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
  // Logger
  final log = Logger('deleteArticles');

  // Get auth token data
  var authTokenData = await wpAuthToken();

  // Site
  String site = Platform.environment['WORDPRESS_SITE'];
  if (site.length == 0) {
    log.info("wpDelete - WORDPRESS_SITE not defined");
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
    log.info("deleteArticles - delete response $response");
  }
}
