package com.mobilemarkdown.mobile_markdown

import android.content.ContentResolver
import android.content.Intent
import android.database.Cursor
import android.net.Uri
import android.provider.OpenableColumns
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val FILE_CHANNEL = "com.mobilemarkdown/file"
        private const val OPENED_FILE_CHANNEL = "com.mobilemarkdown/opened_file"
        private const val OPENED_FILE_EVENTS = "com.mobilemarkdown/opened_file/events"
    }

    private var initialOpenedFile: Map<String, String?>? = null
    private var openedFileSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, FILE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "readContentUri" -> {
                        val uriString = call.argument<String>("uri")
                        if (uriString == null) {
                            result.error("bad_args", "Missing uri", null)
                            return@setMethodCallHandler
                        }

                        try {
                            val bytes = readContentUri(uriString)
                            result.success(bytes)
                        } catch (e: SecurityException) {
                            result.error("permission_denied", e.message, null)
                        } catch (e: java.io.FileNotFoundException) {
                            result.error("not_found", e.message, null)
                        } catch (e: Exception) {
                            result.error("read_failed", e.message, null)
                        }
                    }

                    "contentUriExists" -> {
                        val uriString = call.argument<String>("uri")
                        if (uriString == null) {
                            result.success(false)
                            return@setMethodCallHandler
                        }

                        result.success(contentUriExists(uriString))
                    }

                    "getContentUriSize" -> {
                        val uriString = call.argument<String>("uri")
                        if (uriString == null) {
                            result.success(0)
                            return@setMethodCallHandler
                        }

                        result.success(getContentUriSize(uriString)?.toInt() ?: 0)
                    }

                    "persistUriPermission" -> {
                        val uriString = call.argument<String>("uri")
                        if (uriString == null) {
                            result.success(false)
                            return@setMethodCallHandler
                        }

                        result.success(persistUriPermission(uriString))
                    }

                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, OPENED_FILE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInitialOpenedFile" -> {
                        result.success(initialOpenedFile)
                        initialOpenedFile = null
                    }

                    else -> result.notImplemented()
                }
            }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, OPENED_FILE_EVENTS)
            .setStreamHandler(
                object : EventChannel.StreamHandler {
                    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                        openedFileSink = events
                    }

                    override fun onCancel(arguments: Any?) {
                        openedFileSink = null
                    }
                },
            )

        handleViewIntent(intent, initial = true)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleViewIntent(intent, initial = false)
    }

    private fun handleViewIntent(intent: Intent?, initial: Boolean) {
        if (intent?.action != Intent.ACTION_VIEW) {
            return
        }

        val uri = intent.data ?: return
        maybePersistUriPermission(uri, intent.flags)

        val fileData = mapOf(
            "path" to normalizeUriPath(uri),
            "fileName" to resolveDisplayName(uri),
        )

        if (!initial && openedFileSink != null) {
            openedFileSink?.success(fileData)
        } else {
            initialOpenedFile = fileData
        }
    }

    private fun normalizeUriPath(uri: Uri): String {
        return if (uri.scheme == ContentResolver.SCHEME_FILE) {
            uri.path ?: uri.toString()
        } else {
            uri.toString()
        }
    }

    private fun resolveDisplayName(uri: Uri): String {
        if (uri.scheme == ContentResolver.SCHEME_FILE) {
            return uri.lastPathSegment ?: "Untitled"
        }

        val projection = arrayOf(OpenableColumns.DISPLAY_NAME)
        val cursor: Cursor? = contentResolver.query(uri, projection, null, null, null)
        cursor?.use {
            if (it.moveToFirst()) {
                val index = it.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                if (index != -1) {
                    return it.getString(index)
                }
            }
        }

        return uri.lastPathSegment ?: "Untitled"
    }

    private fun maybePersistUriPermission(uri: Uri, flags: Int) {
        if (uri.scheme != ContentResolver.SCHEME_CONTENT) {
            return
        }

        val canRead = (flags and Intent.FLAG_GRANT_READ_URI_PERMISSION) != 0
        if (!canRead) {
            return
        }

        try {
            contentResolver.takePersistableUriPermission(
                uri,
                Intent.FLAG_GRANT_READ_URI_PERMISSION,
            )
        } catch (_: SecurityException) {
        } catch (_: UnsupportedOperationException) {
        }
    }

    private fun persistUriPermission(uriString: String): Boolean {
        val uri = Uri.parse(uriString)
        if (uri.scheme != ContentResolver.SCHEME_CONTENT) {
            return false
        }

        return try {
            contentResolver.takePersistableUriPermission(
                uri,
                Intent.FLAG_GRANT_READ_URI_PERMISSION,
            )
            true
        } catch (_: SecurityException) {
            false
        } catch (_: UnsupportedOperationException) {
            false
        }
    }

    private fun readContentUri(uriString: String): ByteArray {
        val uri = Uri.parse(uriString)
        contentResolver.openInputStream(uri)?.use { stream ->
            return stream.readBytes()
        }

        throw java.io.FileNotFoundException("Could not open $uriString")
    }

    private fun contentUriExists(uriString: String): Boolean {
        val uri = Uri.parse(uriString)

        return try {
            contentResolver.openAssetFileDescriptor(uri, "r")?.use {
                true
            } ?: false
        } catch (_: Exception) {
            false
        }
    }

    private fun getContentUriSize(uriString: String): Long? {
        val uri = Uri.parse(uriString)
        val projection = arrayOf(OpenableColumns.SIZE)
        val cursor: Cursor? = contentResolver.query(uri, projection, null, null, null)
        cursor?.use {
            if (it.moveToFirst()) {
                val index = it.getColumnIndex(OpenableColumns.SIZE)
                if (index != -1 && !it.isNull(index)) {
                    return it.getLong(index)
                }
            }
        }

        return try {
            contentResolver.openAssetFileDescriptor(uri, "r")?.use { descriptor ->
                descriptor.length.takeIf { it >= 0 }
            }
        } catch (_: Exception) {
            null
        }
    }
}
