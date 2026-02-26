package com.example.expensinfo_full

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.os.Build
import androidx.core.app.NotificationCompat
import java.util.regex.Pattern

class SmsReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {

        if (Telephony.Sms.Intents.SMS_RECEIVED_ACTION != intent.action) return

        val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)

        for (sms in messages) {

            val body = sms.messageBody

            val parsed = parseTransaction(body) ?: continue

            showSmartNotification(
                context,
                parsed.first,
                parsed.second
            )
        }
    }

    private fun parseTransaction(message: String): Pair<Double, String>? {

        val amountPattern = Pattern.compile("(?:INR|Rs\\.?)[ ]?(\\d+(?:\\.\\d+)?)")
        val matcher = amountPattern.matcher(message)

        if (!matcher.find()) return null

        val amount = matcher.group(1)?.toDoubleOrNull() ?: return null

        val merchant = extractMerchant(message)

        return Pair(amount, merchant)
    }

    private fun extractMerchant(message: String): String {

        val toIndex = message.indexOf(" to ")
        if (toIndex != -1) {
            val after = message.substring(toIndex + 4)
            return after.split(" ")[0]
        }

        return "Unknown"
    }

    private fun showSmartNotification(
        context: Context,
        amount: Double,
        merchant: String
    ) {

        val channelId = "smart_sms_channel"

        val manager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Smart Transactions",
                NotificationManager.IMPORTANCE_HIGH
            )
            manager.createNotificationChannel(channel)
        }

        val categories = listOf("Food", "Fuel", "Shopping", "Borrowed")

        val builder = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle("₹$amount spent at $merchant")
            .setContentText("Categorize instantly")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setColor(0xFFFFFFFF.toInt())

        categories.forEachIndexed { index, category ->

            val actionIntent = Intent(context, ActionReceiver::class.java)
            actionIntent.putExtra("amount", amount)
            actionIntent.putExtra("merchant", merchant)
            actionIntent.putExtra("category", category)

            val pendingIntent = PendingIntent.getBroadcast(
                context,
                index,
                actionIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            builder.addAction(0, category, pendingIntent)
        }

        manager.notify(System.currentTimeMillis().toInt(), builder.build())
    }
}
