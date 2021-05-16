import 'dart:io';

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:status_saver/app/ads.dart';
import 'package:status_saver/app/app.dart';
import 'package:status_saver/models/app_model.dart';
import 'package:status_saver/screens/view_status_screen.dart';
import 'package:status_saver/app/app_localizations.dart';
import 'package:status_saver/widgets/status_card.dart';

class SavedStatusTab extends StatefulWidget {
  @override
  SavedStatusTabState createState() {
    return new SavedStatusTabState();
  }
}

class SavedStatusTabState extends State<SavedStatusTab> {
  /// Variables
  final App _app = new App();
  List<String> _savedStatusList;
  AppLocalizations _i18n;

  @override
  void initState() {
    super.initState();

    /// Get Saved Statuses path
    _app.getSavedStatusesPath().then((path) async {
      // Check dir
      if (await Directory(path).exists()) {
        // print('yes dir exists')
        // Update the list
        if (mounted) {
          setState(() {
            _savedStatusList = Directory(path).listSync().map((item) {
              return item.path;
            }).toList();
            // Order date DESC
            _savedStatusList.sort((a, b) => b.compareTo(a));
          });
        }
      } else {
        // print("dir doesn't exists");
        setState(() {
          _savedStatusList = [];
        });
      }
    });
  }

  @override
  void dispose() {
    Ads.disposeInterstitialAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    return ScopedModelDescendant<AppModel>(
        rebuildOnChange: false,
        builder: (context, chald, appModel) {
          return _showSavedStatuses();
        });
  }

  Future<void> _viewStatus(String statusPath) async {
    /// Go to view status page and return result
    final result = await Navigator.of(context).push(new MaterialPageRoute(
        builder: (context) => new ViewStatusScreen(
              savedStatus: true,
              filePath: statusPath,
            )));

    // Check result
    if (result != null) {
      // Update user interface
      setState(() {
        _savedStatusList.remove(result);
      });

      // Show message
      _app.showDialogInfo(
        context: context,
        message: _i18n.translate('status_successfully_deleted'),
        color: Colors.red,
      );
    }
  }

  // Handle to show status
  Widget _showSavedStatuses() {
    /// Check list
    if (_savedStatusList == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (_savedStatusList.isNotEmpty) {
      return Container(
        padding: EdgeInsets.only(bottom: 65.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Show bulk delete option
            AppModel().selectedStatusList.isNotEmpty
                ? showDeleteBulkStatus()
                : Container(width: 0, height: 0),

            /// Handle status list
            Expanded(
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: _savedStatusList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                itemBuilder: (context, index) {
                  /// Get Status path
                  final String statusPath = _savedStatusList[index];

                  /// Check selected status
                  final bool isSelected =
                      AppModel().selectedStatusList.contains(statusPath);

                  return StatusCard(
                      key: Key(statusPath),
                      isSelected: isSelected,
                      statusPath: statusPath,
                      isVideo: statusPath.endsWith('.mp4'),
                      onLongPress: () => AppModel().selectStatuses(statusPath),
                      onTap: () => _viewStatus(statusPath),
                      onSave: Ads.showInterstitialAd,
                      onDelete: () {
                        _deleteStatus(_savedStatusList[index]);
                      });
                },
              ),
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Container(
          padding: EdgeInsets.only(bottom: 60.0),
          child: Text(
            _i18n.translate('no_saved_status_found'),
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      );
    }
  }

  /// Show Delete Bulk Statuses button
  Widget showDeleteBulkStatus() {
    return AppModel().selectedStatusList.isNotEmpty
        ? Card(
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text(
                        '${_i18n.translate('selected')} ${AppModel().selectedStatusList.length.toString()}',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.red,
                            fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red, size: 30),
                    onPressed: () {
                      /// Show confirm dialog
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          child: AlertDialog(
                            title: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.red,
                                  child:
                                      Icon(Icons.delete, color: Colors.white),
                                ),
                                SizedBox(width: 5),
                                Expanded(
                                    child: Text(_i18n
                                        .translate('delete_selected_statuses')))
                              ],
                            ),
                            actions: [
                              // Cancel button
                              FlatButton(
                                  textColor: Colors.grey,
                                  child: Text(_i18n.translate('CANCEL')),
                                  onPressed: () => Navigator.of(context).pop()),
                              // Delete button
                              FlatButton(
                                textColor: Colors.red,
                                child: Text(_i18n.translate('DELETE')),
                                onPressed: () async {
                                  /// Delete bulk status
                                  ///
                                  // Loop selected status
                                  for (String status
                                      in AppModel().selectedStatusList) {
                                    print('Selected status: $status');

                                    //Remove status from the list
                                    _savedStatusList.remove(status);

                                    /// Delete status one by one
                                    await File(status).delete();
                                  }
                                  // Empty list
                                  AppModel().clearSeletedStatuses();

                                  /// Update UI
                                  //setState(() {});

                                  // Close dialog
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ));
                    },
                  ),
                ]),
          )
        : Container(width: 0, height: 0);
  }

  /// Delete One Status
  void _deleteStatus(String path) {
    /// Show confirm dialog
    showDialog(
        context: context,
        barrierDismissible: false,
        child: AlertDialog(
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.red,
                child: Icon(Icons.delete, color: Colors.white),
              ),
              SizedBox(width: 5),
              Expanded(child: Text(_i18n.translate('delete_this_status')))
            ],
          ),
          actions: [
            // Cancel button
            FlatButton(
                textColor: Colors.grey,
                child: Text(_i18n.translate('CANCEL')),
                onPressed: () => Navigator.of(context).pop()),
            // Delete button
            FlatButton(
              textColor: Colors.red,
              child: Text(_i18n.translate('DELETE')),
              onPressed: () async {
                /// Delete status one by one
                await File(path).delete();

                /// Update UI
                setState(() {
                  _savedStatusList.remove(path);
                });
                // Close dialog
                Navigator.of(context).pop();
              },
            ),
          ],
        ));
  }
}
