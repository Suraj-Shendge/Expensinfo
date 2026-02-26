package com.example.expensinfo_full

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.app.NotificationManager

class ActionReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {

        val amount = intent.getDoubleExtra("amount", 0.0)
        val merchant = intent.getStringExtra("merchant") ?: ""
        val category = intent.getStringExtra("category") ?: ""

        // Save lightweight data safely
        val prefs = context.getSharedPreferences("pending_expense", Context.MODE_PRIVATE)

        prefs.edit()
            .putFloat("amount", amount.toFloat())
            .putString("merchant", merchant)
            .putString("category", category)
            .apply()

        // Close notification
        val manager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.cancelAll()
    }
}
