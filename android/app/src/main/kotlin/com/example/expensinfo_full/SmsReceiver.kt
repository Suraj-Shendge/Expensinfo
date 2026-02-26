package com.your.package.name

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.telephony.SmsMessage

class SmsReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (Telephony.Sms.Intents.SMS_RECEIVED_ACTION == intent.action) {

            val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)

            for (sms in messages) {
                val messageBody = sms.messageBody

                // Send SMS to Flutter through broadcast
                val i = Intent("SMS_RECEIVED_INTERNAL")
                i.putExtra("sms_body", messageBody)
                context.sendBroadcast(i)
            }
        }
    }
}
