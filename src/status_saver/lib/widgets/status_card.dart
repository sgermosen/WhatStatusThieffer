import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:status_saver/app/app.dart';

class StatusCard extends StatefulWidget {
  // Variables
  final String statusPath;
  final bool isVideo;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onSave;
  final VoidCallback onDelete;

  StatusCard({
    Key key,
    this.statusPath,
    this.isVideo = false,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
    this.onSave,
    this.onDelete,
  }) : super(key: key);

  @override
  _StatusCardState createState() => _StatusCardState();
}

class _StatusCardState extends State<StatusCard> {
  // Variables
  final App _app = new App();
  Future _thumbnail;

  @override
  void initState() {
    super.initState();
    // Check video path
    if (widget.isVideo) {
      _thumbnail = _app.getVideoThumbnail(widget.statusPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: this.widget.onTap,
      onLongPress: this.widget.onLongPress,
      child: Stack(
        children: <Widget>[
          Card(
            child: Column(
            children: [
              Expanded(
                  child: this.widget.isVideo
                      ? _videoStatus()
                      : _imageStatus(widget.statusPath)),
              // Status Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // View status
                  IconButton(
                      icon: Icon(Icons.remove_red_eye),
                      onPressed: this.widget.onTap),
                  // Delete status
                  widget.onDelete == null
                      ? // Save status                 // View status
                      IconButton(
                          icon: Icon(Icons.get_app),
                          onPressed: () {
                            widget.onSave();
                            // Save status
                            _app.saveFileInGallery(context,
                                filePath: widget.statusPath);
                          })
                      : this.widget.isSelected && widget.onDelete != null
                          ? Container(width: 0, height: 0)
                          : IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: this.widget.onDelete),
                  // Share status
                  IconButton(
                    icon: Icon(Icons.share),
                    onPressed: () {
                      /// Share status
                      if (widget.onDelete == null) {
                        // Share not saved status
                        _app.shareNotSavedStatus(widget.statusPath, context);
                      } else {
                        Share.shareFiles([this.widget.statusPath]);
                      }
                  }),
                ],
              ),
            ],
          )),
          this.widget.isVideo
              ? Positioned.fill(
                  child: Center(
                      child: Icon(Icons.play_circle_outline,
                          color: Colors.white, size: 50)))
              : Container(width: 0, height: 0),
          this.widget.isSelected
              ? Positioned(
                  top: 5,
                  right: 5,
                  child: Icon(
                    Icons.check_circle,
                    size: 40,
                    color: Colors.teal,
                  ),
                )
              : Container(width: 0, height: 0)
        ],
      ),
    );
  }

  Widget _imageStatus(String path) {
    return Image.file(File(path),
        width: 500,
        color: Colors.black.withOpacity(this.widget.isSelected ? 0.9 : 0),
        colorBlendMode: BlendMode.color,
        fit: BoxFit.cover);
  }

  Widget _videoStatus() {
    /// Show video status
    return FutureBuilder(
        future: _thumbnail,
        builder: (context, snapshot) {
          /// Check result
          if (snapshot.connectionState == ConnectionState.done) {
            if (!snapshot.hasData)
              return Center(
                child: CircularProgressIndicator(),
              );
            return _imageStatus(snapshot.data);
          } else {
            /// Loading video placeholder
            return Card(
              margin: const EdgeInsets.all(5.0),
              shape: Border.all(color: Colors.teal),
              elevation: 8.0,
              child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset("assets/images/video_loader.gif",
                      fit: BoxFit.cover)),
            );
          }
        });
  }
}
