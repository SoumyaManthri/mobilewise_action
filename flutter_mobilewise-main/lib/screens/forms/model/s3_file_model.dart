class S3FileModel {
  String? url;
  String? path;
  bool isDownloading;
  S3FileModel({this.url, this.path, required this.isDownloading});
}