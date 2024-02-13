import 'dart:io';

import 'package:flutter/material.dart';

import '../../../shared/model/image_preview_arguments.dart';
import '../../../utils/common_constants.dart' as constants;
import '../../../utils/util.dart';

class ImagePreviewScreenWidget extends StatefulWidget {
  const ImagePreviewScreenWidget({Key? key,})
      : super(key: key);

  @override
  State<ImagePreviewScreenWidget> createState() =>
      _ImagePreviewScreenWidgetState();
}

class _ImagePreviewScreenWidgetState extends State<ImagePreviewScreenWidget> {
  @override
  Widget build(BuildContext context) {

    final args = ModalRoute.of(context)!.settings.arguments as ImagePreviewArguments;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        elevation: constants.appBarElevation,
        backgroundColor: const Color(constants.primaryColor),
      ),
      resizeToAvoidBottomInset: false,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: args.path != null && args.path!.isNotEmpty ? Center(
          child: Image.file(
            File(args.path!),
            errorBuilder: (BuildContext context, Object exception,
                StackTrace? stackTrace) {
              Util.instance.logMessage('Image Preview screen',
                  'Image.file failed -- $exception');
              return const Center(
                child: Icon(
                  Icons.broken_image,
                  color: Color(constants.formFieldBackgroundColor),
                ),
              );
            },
          ),
        ) : args.url != null && args.url!.isNotEmpty ? Center(
          child: Image.network(
            args.url!,
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) return child;
              return constants.blackIndicator;
            },
            errorBuilder: (BuildContext context, Object exception,
                StackTrace? stackTrace) {
              Util.instance.logMessage('Image Preview screen',
                  'Image.network failed -- $exception');
              return const Center(
                child: Icon(
                  Icons.broken_image,
                  color: Color(constants.formFieldBackgroundColor),
                ),
              );
            },
          ),
        ) : const SizedBox(),
      ),
    );
  }
}
