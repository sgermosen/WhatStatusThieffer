import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:status_saver/app/app.dart';
import 'package:status_saver/app/app_localizations.dart';
import 'package:status_saver/models/app_model.dart';

class AppSettingsScreen extends StatefulWidget {
  @override
  _AppSettingsScreenState createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  // Variables
  final App _app = new App();
  final _savedStatusDirController = TextEditingController();
  String _savedStatusDir = '';
  bool _autoPlayVideo = true;
  bool _isDarkThemeEnabled = false;
  AppLocalizations _i18n;

  @override
  void initState() {
    super.initState();

    /// Get Saved Status Directory
    _app.getSavedStatusDir().then((value) {
      setState(() {
        _savedStatusDir = value;
        _savedStatusDirController.text = value;
        print(value);
      });
    });

    /// Get Auto Play Video setting
    _app.getAutoPlayVideo().then((value) {
      setState(() {
        _autoPlayVideo = value;
        print(value);
      });
    });

    /// Get Auto Play Video setting
    _app.getDarkTheme().then((value) {
      setState(() {
        _isDarkThemeEnabled = value;
        print(value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_i18n.translate('app_settings')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            /// Saved Status Directory
            ListTile(
              leading: Icon(Icons.folder),
              title: Text(_i18n.translate('saved_status_directory')),
              trailing: Text(_savedStatusDir,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.teal)),
              onTap: () => _getUserDirectory(),
            ),
            Divider(thickness: 1),

            /// Auto Play video
            ListTile(
              leading: Icon(Icons.play_circle_fill_outlined),
              title: Text(_i18n.translate('auto_play_video')),
              trailing: Switch(
                value: _autoPlayVideo,
                onChanged: (newValue) {
                  // Update preferences
                  _app.setAutoPlayVideo(newValue);
                  // Update UI
                  setState(() {
                    _autoPlayVideo = newValue;
                  });
                },
              ),
            ),
            Divider(thickness: 1),

            /// Enable Dark Theme
            ListTile(
              leading: Icon(Icons.brightness_medium),
              title: Text(_i18n.translate('enable_dark_theme')),
              trailing: Switch(
                value: _isDarkThemeEnabled,
                onChanged: (newValue) {
                  // Update preferences
                  _app.setDarkTheme(newValue);
                  AppModel().updateAppTheme(newValue);
                  // Update UI
                  setState(() {
                    _isDarkThemeEnabled = newValue;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Allows the user to browse the file system and pick a folder
  void _getUserDirectory() async {
    // Get choosed dir
    String newDirPath = await FilePicker.platform.getDirectoryPath();

    if (newDirPath != null) {
      // Get folder name
      final String folder = newDirPath.split('/').last;
      // Update Saved Statuses Dir
      await _app.setSavedStatusDir(folder);
      // Update UI
      setState(() {
        _savedStatusDir = folder;
      });
    }
    //else {
    // User canceled the picker
    //}
  }
}
