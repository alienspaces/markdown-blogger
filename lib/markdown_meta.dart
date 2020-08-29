import 'dart:convert';
import 'dart:io';

class MetaData {
  int id;
  int siteId;
  String url;
  String modified;
  String localPath;

  MetaData(this.id, this.siteId, this.url, this.modified, this.localPath);
}

// Meta -
class Meta {
  File file;
  // article meta data
  MetaData articleMeta;
  // article media meta data
  List<MetaData> mediaMeta;

  MetaData getMeta(String localPath) {
    print("getMeta - Finding localPath $localPath");
    if (this.articleMeta != null && this.articleMeta.localPath == localPath) {
      return this.articleMeta;
    }
    if (this.mediaMeta != null) {
      for (var mediaMeta in this.mediaMeta) {
        print("getMeta - checking media localPath ${mediaMeta.localPath}");
        if (mediaMeta.localPath == localPath) {
          return mediaMeta;
        }
      }
    }
    return null;
  }

  void updateArticleMeta(MetaData articleMeta) {
    this.articleMeta = articleMeta;
  }

  void addMediaMeta(MetaData mediaMeta) {
    if (this.mediaMeta == null) {
      this.mediaMeta = [];
    }
    print("addMediaMeta - adding media meta ${mediaMeta.localPath}");
    this.mediaMeta.add(mediaMeta);
  }

  void updateMediaMeta(MetaData mediaMeta) {
    int idx = 0;
    for (var metaData in this.mediaMeta) {
      if (metaData.id == mediaMeta.id) {
        print("updateMediaMeta - updating media meta ${mediaMeta.localPath}");
        this.mediaMeta[idx] = mediaMeta;
        break;
      }
      idx++;
    }
  }

  void saveFile() {
    Map<String, dynamic> articleMetaData = {
      'id': this.articleMeta.id,
      'siteId': this.articleMeta.siteId,
      'url': this.articleMeta.url,
      'modified': this.articleMeta.modified,
      'localPath': this.articleMeta.localPath,
    };
    List<Map<String, dynamic>> mediaMetaData = [];
    for (var mediaMeta in this.mediaMeta) {
      Map<String, dynamic> metaData = {
        'id': mediaMeta.id,
        'siteId': mediaMeta.siteId,
        'url': mediaMeta.url,
        'modified': mediaMeta.modified,
        'localPath': mediaMeta.localPath,
      };
      mediaMetaData.add(metaData);
    }
    Map<String, dynamic> metaData = {
      'article': articleMetaData,
      'media': mediaMetaData,
    };
    print("saveFile - saving meta $metaData");
    JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    this.file.writeAsStringSync(encoder.convert(metaData));
  }

  Meta(File file) {
    this.file = file;
    this.mediaMeta = [];
    // Read meta file content
    var fileContent = file.readAsStringSync();
    if (fileContent.length != 0) {
      dynamic metaJson = jsonDecode(fileContent);
      if (metaJson != null) {
        // article meta
        Map<String, dynamic> articleJson = metaJson['article'];
        if (articleJson != null) {
          var articleMeta = new MetaData(
            articleJson['id'],
            articleJson['siteId'],
            articleJson['url'],
            articleJson['modified'],
            articleJson['localPath'],
          );
          this.articleMeta = articleMeta;
        }
        // article media meta
        List<dynamic> mediaJsonList = metaJson['media'];
        if (mediaJsonList != null) {
          for (Map<String, dynamic> mediaJson in mediaJsonList) {
            var mediaMeta = new MetaData(
              mediaJson['id'],
              mediaJson['siteId'],
              mediaJson['url'],
              mediaJson['modified'],
              mediaJson['localPath'],
            );
            this.mediaMeta.add(mediaMeta);
          }
        }
      }
    }
  }
}
