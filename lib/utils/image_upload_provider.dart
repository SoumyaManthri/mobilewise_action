import 'dart:io';
import 'package:flutter_mobilewise/utils/util.dart';

import '../aws_s3_upload/aws_s3_upload.dart';
import '../utils/common_constants.dart'  as constants;


class ImageUploadProvider {
  /// This method is called to upload a file to AWS S3
  Future<String> uploadMediaToS3(File file) async {
    String imageUrl = "";
    try {
      String? value = await AwsS3.uploadFile(
        accessKey: constants.accessKey,
        secretKey: constants.secretKey,
        file: File(file.path),
        bucket: constants.bucket,
        region: constants.region,
        destDir: constants.s3Filefolder,
      );
      if (value != null) {
        Util.instance.logMessage('API Provider', 'Uploaded media to S3');
        imageUrl = value;
      }
    } catch (e) {
      Util.instance.logMessage(
          'Exception: $e',
          'API Provider -  Could not'
              ' upload media to S3');
      return imageUrl;
    }
    return imageUrl;
  }

}