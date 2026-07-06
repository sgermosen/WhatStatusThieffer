import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:status_saver/app/app.dart';
import 'package:status_saver/app/app_localizations.dart';
import 'package:status_saver/services/link_downloader.dart';

/// Screen that lets the user paste a link (Instagram / Facebook / TikTok / any
/// site with Open Graph tags) and download its media into the Saved folder.
class DownloadLinkScreen extends StatefulWidget {
  /// Optional pre-filled URL (e.g. coming from a share action in the future).
  final String initialUrl;

  DownloadLinkScreen({this.initialUrl});

  @override
  _DownloadLinkScreenState createState() => _DownloadLinkScreenState();
}

class _DownloadLinkScreenState extends State<DownloadLinkScreen> {
  final App _app = new App();
  final LinkDownloader _downloader = new LinkDownloader();
  final TextEditingController _controller = new TextEditingController();

  String _detectedPlatform;
  bool _isBusy = false;
  AppLocalizations _i18n;

  @override
  void initState() {
    super.initState();
    if (widget.initialUrl != null) {
      _controller.text = widget.initialUrl;
      _onChanged(widget.initialUrl);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {
      _detectedPlatform = _downloader.detectPlatform(value);
    });
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      _controller.text = data.text;
      _onChanged(data.text);
    }
  }

  Future<void> _startDownload() async {
    final String raw = _controller.text;
    if (extractUrl(raw) == null) {
      _showMessage(_i18n.translate('invalid_link'), error: true);
      return;
    }

    setState(() => _isBusy = true);
    try {
      // Resolve the direct media URL and download it.
      final media = await _downloader.resolve(raw);
      await _downloader.download(media);

      setState(() => _isBusy = false);
      _showMessage(_i18n.translate('download_completed'));
    } catch (error) {
      setState(() => _isBusy = false);
      // `error` is one of our i18n keys when we threw it on purpose.
      final String key = error is String ? error : 'download_failed';
      _showMessage(_translateError(key), error: true);
    }
  }

  String _translateError(String key) {
    const known = [
      'invalid_link',
      'unsupported_or_private_link',
      'download_failed',
    ];
    return known.contains(key)
        ? _i18n.translate(key)
        : _i18n.translate('download_failed');
  }

  void _showMessage(String message, {bool error = false}) {
    _app.showDialogInfo(
      context: context,
      message: message,
      color: error ? Colors.red : Colors.teal,
    );
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_i18n.translate('download_from_link')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Icon(Icons.link, size: 80, color: Colors.teal),
            SizedBox(height: 10),
            Text(
              _i18n.translate('paste_a_link_to_download'),
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _controller,
              onChanged: _onChanged,
              maxLines: 2,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: _i18n.translate('paste_link_here'),
                suffixIcon: IconButton(
                  icon: Icon(Icons.content_paste),
                  tooltip: _i18n.translate('paste'),
                  onPressed: _isBusy ? null : _pasteFromClipboard,
                ),
              ),
            ),
            if (_detectedPlatform != null && _detectedPlatform != 'link')
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.check_circle, color: Colors.teal, size: 20),
                    SizedBox(width: 6),
                    Text(
                      '${_i18n.translate('detected_platform')}: $_detectedPlatform',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 20),
            _isBusy
                ? Column(
                    children: <Widget>[
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text(_i18n.translate('downloading')),
                    ],
                  )
                : RaisedButton.icon(
                    color: Colors.teal,
                    textColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    icon: Icon(Icons.file_download),
                    label: Text(
                      _i18n.translate('download'),
                      style: TextStyle(fontSize: 18),
                    ),
                    onPressed: _startDownload,
                  ),
            SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withAlpha(40),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _i18n.translate('link_download_disclaimer'),
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
