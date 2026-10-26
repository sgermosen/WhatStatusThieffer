
import 'package:flutter/material.dart';
import 'package:status_saver/app/ads.dart';
import 'package:status_saver/app/app.dart';
import 'package:status_saver/screens/view_status_screen.dart';
import 'package:status_saver/widgets/folder_access_prompt.dart';
import 'package:status_saver/widgets/status_card.dart';
import 'package:status_saver/app/app_localizations.dart';

class VideosTab extends StatefulWidget {
  // Variables
  final String app;

  VideosTab({required this.app});

  @override
  VideosTabState createState() {
    return new VideosTabState();
  }
}

class VideosTabState extends State<VideosTab> {
  // Variables
  final App _app = new App();
  List<String>? _videoList;
  late AppLocalizations _i18n;

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
        _videoList?.remove(result);
      });

      // Show message
      _app.showDialogInfo(
        context: context,
        message: _i18n.translate('status_successfully_deleted'),
        color: Colors.red,
      );
    }
  }

  bool _needsFolderAccess = false;
  static const _extensions = [".mp4", ".mkv", ".mov", ".3gp"];

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Load the platform's media and keep only this tab's file types.
  Future<void> _load() async {
    final result = await _app.loadMediaFiles(widget.app);
    final files = result.files
        .where((f) => _extensions.any((e) => f.toLowerCase().endsWith(e)))
        .toList();
    if (!mounted) return;
    setState(() {
      _needsFolderAccess = result.needsFolderAccess;
      _videoList = files;
    });
  }

  Future<void> _grantFolderAccess() async {
    if (await _app.requestFolderAccess(widget.app)) {
      setState(() => _videoList = null);
      _load();
    }
  }

  @override
  void dispose() {
    super.dispose();
    //  Ads.disposeInterstitialAd();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    return _showVideoStatuses();
  }

  /// Show video statuses
  Widget _showVideoStatuses() {
    if (_needsFolderAccess) {
      return FolderAccessPrompt(onGrant: _grantFolderAccess);
    }
    /// Check list
    if (_videoList == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (_videoList!.isNotEmpty) {
      /// Show video list
      return GridView.builder(
          itemCount: _videoList!.length,
          padding: EdgeInsets.only(bottom: 65.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemBuilder: (context, index) {
            /// Get thumbnail from video
            return StatusCard(
              statusPath: _videoList![index],
              isVideo: true,
              onTap: () {
                _viewStatus(_videoList![index]);
              },
              onSave: Ads.showInterstitial,
            );
          });
    } else {
      return Center(
          child: Text(
        _i18n.translate('no_video_found'),
        style: TextStyle(fontSize: 18.0),
      ));
    }
  }
}
