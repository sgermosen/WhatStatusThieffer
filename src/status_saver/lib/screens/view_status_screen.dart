import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:status_saver/app/ads.dart';
import 'package:status_saver/app/app.dart';
import 'package:status_saver/widgets/play_video.dart';
import 'package:status_saver/app/app_localizations.dart';

class ViewStatusScreen extends StatefulWidget {
  final String filePath;
  final bool savedStatus;

  ViewStatusScreen({
    @required this.filePath,
    @required this.savedStatus,
  });

  @override
  _ViewStatusScreenState createState() => _ViewStatusScreenState();
}

class _ViewStatusScreenState extends State<ViewStatusScreen> {
  // Variable
  final _app = new App();
  AppLocalizations _i18n;

  @override
  void dispose() {
    //  Ads.disposeInterstitialAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.close,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          widget.savedStatus
              ? _savedStatusesButton()
              : FlatButton.icon(
                  textColor: Colors.white,
                  icon: Icon(Icons.file_download), //`Icon` to display
                  label: Text(_i18n.translate('SAVE'),
                      style: TextStyle(fontSize: 20.0)), //`Text` to display
                  onPressed: () async {
                    // Show Ad
                    //Ads.showInterstitialAd();

                    /// Save image
                    _app.saveFileInGallery(context, filePath: widget.filePath);
                  },
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 10, bottom: 65),
        child: widget.filePath.endsWith('.mp4')
            ? PlayVideo(videoSrc: widget.filePath)
            : Hero(
                tag: widget.filePath,
                child: Image.file(
                  File(widget.filePath),
                  fit: BoxFit.cover,
                ),
              ),
      ),
    );
  }

  Widget _savedStatusesButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              /// Delete status
              File(widget.filePath).deleteSync();
              Navigator.pop(context, widget.filePath);
            },
          ),
          SizedBox(width: 15),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () async {
              /// Share status
              Share.shareFiles([widget.filePath]);
            },
          ),
        ],
      ),
    );
  }
}
