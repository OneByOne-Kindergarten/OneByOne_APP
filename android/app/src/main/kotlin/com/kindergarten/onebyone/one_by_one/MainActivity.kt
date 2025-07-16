package com.kindergarten.onebyone.one_by_one

import android.content.ActivityNotFoundException
import android.content.Intent
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.net.URISyntaxException


class MainActivity: FlutterActivity() {
    private val CHANNEL = "PARSE_INTENT"

    //MethodChannel
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            // Intent:// 스키마 URL파싱
            if(call.method == "getAppUrl") {
                try {
                    val url: String? = call.argument("url")

                    if(url == null) {
                        result.error("9999", "URL PARAMETER IS NULL", null)
                    } else {
                        Log.i("[getAppUrl] url", url)
                        val intent = Intent.parseUri(url, Intent.URI_INTENT_SCHEME)
                        result.success(intent.dataString)
                    }
                } catch (e: URISyntaxException) {
                    result.notImplemented()
                } catch (e: ActivityNotFoundException) {
                    result.notImplemented()
                }
                // market 다운로드 주소 반환
            } else if(call.method == "getMarketUrl") {
                try {
                    val url: String? = call.argument("url")
                    if(url == null) {
                        result.error("9999", "URL PARAMETER IS NULL", null)
                    } else {
                        Log.i("[getMarketUrl] url", url)
                        val intent = Intent.parseUri(url, Intent.URI_INTENT_SCHEME)
                        val scheme = intent.scheme
                        val packageName = intent.getPackage()
                        if (packageName != null) {
                            result.success("market://details?id=$packageName")
                        }
                        result.notImplemented()
                    }
                } catch (e: URISyntaxException) {
                    result.notImplemented()
                } catch (e: ActivityNotFoundException) {
                    result.notImplemented()
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
