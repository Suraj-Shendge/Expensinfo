package com.expensinfo.mobile

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.IntentFilter
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class MainActivity: FlutterActivity() {

    private val CHANNEL = "sms_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                val smsBody = intent?.getStringExtra("sms_body")
                MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
                    .invokeMethod("onSmsReceived", smsBody)
            }
        }

        registerReceiver(receiver, IntentFilter("SMS_RECEIVED_INTERNAL"))
    }
}
