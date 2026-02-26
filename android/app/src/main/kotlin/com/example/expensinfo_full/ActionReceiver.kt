package com.example.expensinfo_full

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

class ActionReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {

        val amount = intent.getDoubleExtra("amount", 0.0)
        val merchant = intent.getStringExtra("merchant") ?: ""
        val category = intent.getStringExtra("category") ?: ""

        val flutterEngine = FlutterEngine(context)
        flutterEngine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "background_channel"
        ).invokeMethod("insertExpense", mapOf(
            "amount" to amount,
            "merchant" to merchant,
            "category" to category
        ))
    }
}
