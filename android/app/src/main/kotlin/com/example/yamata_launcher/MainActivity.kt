package com.example.yamata_launcher

import com.example.yamata_launcher.utils.ZipUtils
import android.content.Context
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {

    private val CHANNEL = "aria2c"
    private val TAG = "Aria2cPlugin"

    private var initialized = false
    private var baseName = "yamata"
    private var aria2cDirName = "aria2c"
    private var aria2cBinFile = "libaria2c.so"
    private var utilsName = "libutils.zip.so"
    private var certFileName = "libutils.so/yamata_launcher.pem"
     private var certKeyFileName = "libutils.so/yamata_launcher.key"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "init" -> {
                    try {
                       val paths = initAria2c(applicationContext)
                        result.success(paths)
                    } catch (e: Exception) {
                        result.error("INIT_ERROR", e.message, null)
                    }
                }
            }
        }
    }

    /**
     * Extract aria2c into app private storage (noBackupFilesDir)
     */
   private fun initAria2c(context: Context): Map<String, String> {

    if (initialized) {
        val baseDir = File(context.noBackupFilesDir, baseName)
        val certFile = File(baseDir, certFileName)
        val binaryFile = File(context.applicationInfo.nativeLibraryDir, aria2cBinFile)

        return mapOf(
            "certPath" to certFile.absolutePath,
            "binaryPath" to binaryFile.absolutePath
        )
    }

    val baseDir = File(context.noBackupFilesDir, baseName)
    baseDir.mkdirs()

    val certFile = File(baseDir, certFileName)
    val utilsFile = File(context.applicationInfo.nativeLibraryDir, utilsName)

    if (!utilsFile.exists()) {
        Log.e(TAG, "$utilsName NOT FOUND")
        throw Exception("$utilsName not found")
    }

    if (!certFile.exists()) {
        Log.d(TAG, "Unzipping utils…")
        ZipUtils.unzip(utilsFile, baseDir)
    }

    baseDir.walk().forEach { file ->
        Log.d(TAG, "Loading: ${file.absolutePath}")
    }

    initialized = true

    val binaryFile = File(context.applicationInfo.nativeLibraryDir, aria2cBinFile)

    return mapOf(
        "certPath" to certFile.absolutePath,
        "binaryPath" to binaryFile.absolutePath
    )
}
}
