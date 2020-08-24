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
        // Get auth token data
        Map<String, dynamic> authTokenData = await wpAuthToken();

        if (article.metaFile != null) {
          // Update article
          Map<String, dynamic> response =
              await wpUpdate(authTokenData, article);
          await article.updateMeta(response);
        } else {
          // Create article
          Map<String, dynamic> response =
              await wpCreate(authTokenData, article);
          await article.updateMeta(response);
        }
      }
    }
  }

  print("Main - Done");
}
