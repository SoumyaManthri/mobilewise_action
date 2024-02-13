import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget{
  LoadingIndicator({this.text = ''});

  final String text;

  @override
  Widget build(BuildContext context) {
    var displayedText = text;

    return Container(
        padding: EdgeInsets.all(16),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _getLoadingIndicator(),
              SizedBox(width: 10,),
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _getHeading(context),
                    _getText(displayedText)
                  ]
              )

            ]
        )
    );
  }

  Padding _getLoadingIndicator() {
    return Padding(
        child: Container(
            child: CircularProgressIndicator(
                strokeWidth: 5
            ),
            width: 32,
            height: 32
        ),
        padding: EdgeInsets.only(bottom: 16)
    );
  }

  Widget _getHeading(context) {
    return
      Padding(
          child: Text(
            'Please wait …',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16
            ),
            textAlign: TextAlign.center,
          ),
          padding: EdgeInsets.only(bottom: 4)
      );
  }

  Text _getText(String displayedText) {
    return Text(
      displayedText,
      style: TextStyle(
          color: Colors.white,
          fontSize: 16
      ),
      textAlign: TextAlign.center,
    );
  }
}