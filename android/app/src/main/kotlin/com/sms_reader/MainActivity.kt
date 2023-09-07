package com.sms_reader
import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.telephony.SubscriptionInfo
import android.telephony.SubscriptionManager
import android.telephony.TelephonyManager
import android.util.Log
import androidx.annotation.NonNull
import android.provider.Settings
import android.os.PowerManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.HashMap
import android.database.Cursor
import android.content.Intent
import android.content.IntentFilter
import android.content.ContentResolver
import android.net.Uri

class MainActivity: FlutterActivity() {

    private val CHANNEL = "com.sms_reader/sim_info"
//    private val CHANNEL1 = "com.sms_reader/sim1"
    private val REQUEST_CODE = 123 // You can use any value you prefer


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val powerManager = getSystemService(POWER_SERVICE) as PowerManager
        val packageName = packageName

        if (!powerManager.isIgnoringBatteryOptimizations(packageName)) {
            val intent = Intent()
            intent.action = Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
            intent.data = Uri.parse("package:$packageName")
            startActivity(intent)
        }
    }


    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

//        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
//            if (call.method == "openSettings") {
//                openSimSettings()
//                result.success(null)
//            } else {
//                result.notImplemented()
//            }
//        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->

            if (call.method == "requestBatteryOptimizations") {
                requestIgnoreBatteryOptimizations()
                result.success(true)
            } else if (call.method == "getSim1MessageIds") {
                val sim1MessageIds = getSim1MessageIds() // This is the function that fetches SIM1 messages' IDs
                result.success(sim1MessageIds)
            }

//            else if (call.method == "getSimInfo") {
//                val simInfo = getSimInfo()
//                result.success(simInfo)
//            }

            else {
                result.notImplemented()
            }
        }
    }

    private fun getSimInfo(): String {
        val telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        val simInfoBuilder = StringBuilder()

        if (telephonyManager != null) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) == PackageManager.PERMISSION_GRANTED) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
                    val subscriptionManager = SubscriptionManager.from(this)
                    val subscriptionInfoList = subscriptionManager.activeSubscriptionInfoList

                    if (subscriptionInfoList != null) {
                        for (subscriptionInfo in subscriptionInfoList) {
                            val number = subscriptionInfo.number // SIM number
                            Log.e("SimInfo", number)

                            simInfoBuilder.append("SIM ${subscriptionInfo.simSlotIndex + 1}: $number\n")
                        }
                    }
                } else {
                    val number = telephonyManager.line1Number
                    simInfoBuilder.append("SIM hello 1: $number\n")
                }
            } else {
                Log.e("SimInfo", "Read phone state permission not granted")
            }
        }

        return simInfoBuilder.toString()
    }


    //open sim setting
    private fun openSimSettings() {
        val intent = Intent()
        try {
            // Try to open SIM settings (this is not a standard Android intent and may not work)
            intent.action = "android.settings.SIM_CARD_SETTINGS"
            startActivity(intent)
        } catch (e: Exception) {
            // Handle the exception, e.g., by opening general settings as a fallback
            intent.action = Settings.ACTION_SETTINGS
            startActivity(intent)
        }
    }


    private fun requestIgnoreBatteryOptimizations() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent()
            val packageName = packageName
            val pm = getSystemService(POWER_SERVICE) as PowerManager
            if (!pm.isIgnoringBatteryOptimizations(packageName)) {
                intent.action = Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
                intent.data = Uri.parse("package:$packageName")
                startActivity(intent)
            }
        }
    }


    private fun getSim1MessageIds(): List<Int> {
        val sim1MessageIds = mutableListOf<Int>()

        // Fetch all SMS messages
        val cursor: Cursor? = contentResolver.query(
                Uri.parse("content://sms"),
                arrayOf("_id", "sub_id"), // We only need the IDs and subscription IDs
                null,
                null,
                null
        )

        if (cursor != null && cursor.moveToFirst()) {
            val subscriptionManager = getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as SubscriptionManager
            val subscriptionInfoList: List<SubscriptionInfo> = subscriptionManager.activeSubscriptionInfoList

            for (subscriptionInfo in subscriptionInfoList) {
                if (subscriptionInfo.simSlotIndex == 1) {
                    Log.e("main Sim1", "okk")
                    // This is SIM1
                    do {
                        var messageId = cursor.getInt(cursor.getColumnIndexOrThrow("_id"))
                        var subId = cursor.getInt(cursor.getColumnIndexOrThrow("sub_id"))
                        Log.e("main Sim1", "okk m id$messageId")
                        Log.e("main Sim1", "okk sub $subId")

                        if (subId == subscriptionInfo.subscriptionId) {
                            sim1MessageIds.add(messageId)
                        }
                    } while (cursor.moveToNext())
                }
            }

            cursor.close()
        }

        return sim1MessageIds
    }


}
