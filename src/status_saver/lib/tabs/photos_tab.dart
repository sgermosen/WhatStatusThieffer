import 'dart:io';
import 'package:flutter/material.dart';
import 'package:status_saver/app/ads.dart';
import 'package:status_saver/app/app.dart';
import 'package:status_saver/screens/view_status_screen.dart';
import 'package:status_saver/widgets/status_card.dart';
import 'package:status_saver/app/app_localizations.dart';

class PhotosTab extends StatefulWidget {
  // Variables
  final String app;

  PhotosTab({@required this.app});

  @override
  _PhotosTabState createState() {
    return new _PhotosTabState();
  }
}

class _PhotosTabState extends State<PhotosTab> {
  // Variables
  final App _app = new App();
  List _imageList;
  AppLocalizations _i18n;

  /// View Status and update UI on delete
  Future<void> _viewStatus(String statusPath) async {
    /// Go to view status page and return result
    final result = await Navigator.of(context).push(new MaterialPageRoute(
        builder: (context) => new ViewStatusScreen(
              savedStatus: false,
              filePath: statusPath,
            )));

    // Check result
    if (result != null) {
      // Update user interface
      setState(() {
        _imageList.remove(result);
      });

      // Show message
      _app.showDialogInfo(
        context: context,
        message: _i18n.translate('status_successfully_deleted'),
        color: Colors.red,
      );
    }
  }

  @override
  void initState() {
    super.initState();

    // Get Statuses path
    _app.getStatusesPath(widget.app).then((path) {
      // Check statuses dir
      if (Directory(path).existsSync()) {
        // print('yes dir exists');
        if (mounted)
          setState(() {
            _imageList = Directory(path)
                .listSync()
                .map((item) => item.path)
                .where((item) => item.endsWith(".jpg") || item.endsWith(".gif"))
                .toList();
          });
      } else {
        // print('Dir does not exists');
        setState(() => _imageList = []);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    Ads.disposeInterstitialAd();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    return _showPhotoStatuses();
  }

  Widget _showPhotoStatuses() {
    /// Check list
    if (_imageList == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (_imageList.isNotEmpty) {
      /// Show image statuses
      return GridView.builder(
          itemCount: _imageList.length,
          padding: EdgeInsets.only(bottom: 65.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemBuilder: (context, index) {
            return StatusCard(
              statusPath: _imageList[index],
              onTap: () {
                _viewStatus(_imageList[index]);
              },
              onSave: Ads.showInterstitialAd,
            );
          });
    } else {
      return Center(
        child: Container(
          padding: EdgeInsets.only(bottom: 60.0),
          child: Text(
            _i18n.translate('no_image_found'),
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      );
    }
  }
}
