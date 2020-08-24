// Publish articles to monsterweekly.com
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

  ArgResults argResults = parser.parse(arguments);

  // Delete all posts
  if (argResults[argDelete]) {
    print("Deleting all remote posts");
    // Get auth token data
    Map<String, dynamic> authTokenData = await wpAuthToken();

    // Delete all wordpress posts
    await wpDeleteAll(authTokenData);
  }

  // Publish all local posts
  if (argResults[argPublish]) {
    print("Publishing all local unpublished posts");
    // Get list of articles for site
    List<LocalArticle> articles = getArticles();
    if (articles != null) {
      for (LocalArticle article in articles) {
        // print("Article directory ${article.articleDirectory.path}");
        // print("Article markdown ${article.markdownFile.path}");
        // if (article.mediaFiles != null) {
        //   print("Article media file count ${article.mediaFiles.length}");
        // }
        // if (article.metaFile != null) {
        //   print("Article meta ${article.metaFile.path}");
        // }

        // Get auth token data
        Map<String, dynamic> authTokenData = await wpAuthToken();

        // Create article
        await wpCreate(authTokenData, article);
      }
    }
  }

  print("Main - Done");
}
