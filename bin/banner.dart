// Banner is a helper tool that creates a featured.png image given a banner image
// argument, a text string and article folder.

import 'dart:io';
import 'dart:core';
import 'package:intl/intl.dart';

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:image/image.dart';

const argBanner = 'banner';
const argArticle = 'article';
const argText = 'text';

void main(List<String> arguments) async {
  // Logging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
  });

  // Logger
  final log = Logger('main');

  // Arguments
  final parser = ArgParser()..addOption(argBanner)..addOption(argArticle)..addOption(argText);

  var argResults = parser.parse(arguments);

  log.fine('Banner  : ${argResults[argBanner]}');
  log.fine('Article : ${argResults[argArticle]}');
  log.fine('Text    : ${argResults[argText]}');

  int alpha = 255;
  int red = 0;
  int green = 0;
  int blue = 0;

  // Font colour
  int colour = (alpha << 24) + (red << 16) + (green << 8) + blue;

  log.finer('Colour alpha : ${alpha << 24}');
  log.finer('Colour red   : ${red << 16}');
  log.finer('Colour green : ${green << 8}');
  log.finer('Colour blue  : $blue');
  log.finer('Colour final : $colour');

  // Banner
  bool exists = await File('./banners/${argResults[argBanner]}.png').exists();
  if (!exists) {
    log.severe('Banner ${argResults[argBanner]} does not exist');
    var files = Directory('./banners').listSync();
    log.info('Available banners:');
    files.forEach((FileSystemEntity file) {
      String banner = file.path;
      banner = banner.replaceFirst(new RegExp(r'\./banners/'), '');
      banner = banner.replaceFirst(new RegExp(r'\.png'), '');
      log.info('- $banner');
    });
    return;
  }

  // Output path
  String outputPath = await resolveOutputPath(argResults[argArticle]);

  // Text
  String text = argResults[argText] ?? 'Text missing';

  // Create featured image
  var bannerImage = decodePng(File('./banners/${argResults[argBanner]}.png').readAsBytesSync());
  var featureImage = drawString(bannerImage, arial_48, 130, 30, text, color: colour);

  File('$outputPath/featured.png').writeAsBytesSync(encodePng(featureImage));

  log.info("Created $outputPath/featured.png");
}

Future<String> resolveOutputPath(String article) async {
  // Logger
  final log = Logger('resolveOutputPath');

  // If article is null create article directory based
  // on the current date
  if (article == null) {
    var formatter = DateFormat('y-MM-dd');
    article = formatter.format(DateTime.now());
  }

  String outputPath = './articles/$article';
  bool exists = await Directory(outputPath).exists();
  if (!exists) {
    log.info('Creating output directory $outputPath');
    await Directory(outputPath).create();
  }

  return outputPath;
}
