package com.xamarindo.wpstatusaver

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.DocumentsContract
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

/**
 * Hosts a small Storage Access Framework (SAF) bridge.
 *
 * Since Android 11 apps can't read WhatsApp's `.Statuses` folder with plain
 * file access (it lives in Android/media and contains a .nomedia file). The
 * user grants access to that folder once through the system folder picker;
 * we keep the permission and copy the statuses into the app cache so the
 * Flutter side keeps working with ordinary file paths.
 */
class MainActivity : FlutterActivity() {
    private val requestCodeTree = 4242
    private var pendingResult: MethodChannel.Result? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "status_saver/saf")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "sdkInt" -> result.success(Build.VERSION.SDK_INT)
                    "hasAccess" -> result.success(hasAccess(call.argument<String>("uri")))
                    "requestAccess" -> requestAccess(call.argument<String>("path") ?: "", result)
                    "sync" -> inBackground(result) {
                        sync(call.argument<String>("uri")!!, call.argument<String>("dir")!!)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /** True if we still hold a persisted read permission for [uri]. */
    private fun hasAccess(uri: String?): Boolean {
        if (uri == null) return false
        return contentResolver.persistedUriPermissions.any {
            it.uri.toString() == uri && it.isReadPermission
        }
    }

    /** Open the system folder picker, pre-navigated to [path] when possible. */
    private fun requestAccess(path: String, result: MethodChannel.Result) {
        if (pendingResult != null) {
            result.error("busy", "A folder request is already in progress", null)
            return
        }
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
            addFlags(
                Intent.FLAG_GRANT_READ_URI_PERMISSION or
                    Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION
            )
            if (path.isNotEmpty()) {
                val initial = DocumentsContract.buildDocumentUri(
                    "com.android.externalstorage.documents", "primary:$path"
                )
                putExtra(DocumentsContract.EXTRA_INITIAL_URI, initial)
            }
        }
        pendingResult = result
        @Suppress("DEPRECATION")
        startActivityForResult(intent, requestCodeTree)
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode != requestCodeTree) {
            @Suppress("DEPRECATION")
            super.onActivityResult(requestCode, resultCode, data)
            return
        }
        val result = pendingResult ?: return
        pendingResult = null
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {
            result.success(null)
            return
        }
        try {
            contentResolver.takePersistableUriPermission(
                uri, Intent.FLAG_GRANT_READ_URI_PERMISSION
            )
            result.success(uri.toString())
        } catch (e: SecurityException) {
            result.error("permission", e.message, null)
        }
    }

    /**
     * Copy every image/video in the granted folder into cache/statuses/[dir]
     * (skipping files already cached with the same size), delete cached files
     * that disappeared from the source, and return the cached paths.
     */
    private fun sync(treeUri: String, dir: String): List<String> {
        val tree = Uri.parse(treeUri)
        val cacheDir = File(cacheDir, "statuses/$dir").apply { mkdirs() }
        val children = DocumentsContract.buildChildDocumentsUriUsingTree(
            tree, DocumentsContract.getTreeDocumentId(tree)
        )
        val projection = arrayOf(
            DocumentsContract.Document.COLUMN_DOCUMENT_ID,
            DocumentsContract.Document.COLUMN_DISPLAY_NAME,
            DocumentsContract.Document.COLUMN_MIME_TYPE,
            DocumentsContract.Document.COLUMN_SIZE,
        )
        val paths = mutableListOf<String>()
        contentResolver.query(children, projection, null, null, null)?.use { c ->
            while (c.moveToNext()) {
                val id = c.getString(0)
                val name = c.getString(1) ?: continue
                val mime = c.getString(2) ?: ""
                val size = if (c.isNull(3)) -1L else c.getLong(3)
                if (!mime.startsWith("image/") && !mime.startsWith("video/")) continue
                val dest = File(cacheDir, name)
                if (!dest.exists() || dest.length() != size) {
                    val docUri = DocumentsContract.buildDocumentUriUsingTree(tree, id)
                    contentResolver.openInputStream(docUri)?.use { input ->
                        dest.outputStream().use { output -> input.copyTo(output) }
                    }
                }
                paths.add(dest.absolutePath)
            }
        }
        val keep = paths.toSet()
        cacheDir.listFiles()?.forEach { if (it.absolutePath !in keep) it.delete() }
        return paths
    }

    private fun inBackground(result: MethodChannel.Result, work: () -> Any?) {
        Thread {
            try {
                val value = work()
                mainHandler.post { result.success(value) }
            } catch (e: Exception) {
                mainHandler.post { result.error("saf", e.message, null) }
            }
        }.start()
    }
}
