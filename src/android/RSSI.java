package net.emcniece.cordova;

import android.content.Context;
import android.net.wifi.WifiManager;
import android.net.wifi.WifiInfo;
import android.os.Build;
import android.provider.Settings;
import android.text.TextUtils;
import android.util.Log;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import static android.content.Context.WIFI_SERVICE;

public class RSSI extends CordovaPlugin {
    private static final String TAG = "RSSI";
    public static final String ACTION_READ = "read";

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        Log.v(TAG, "Initialized");
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.v(TAG, "Destroyed");
    }

    @Override
    public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) {

        if (ACTION_READ.equals(action)) {
            Log.d(TAG, "read");
            final CordovaInterface cd = this.cordova;

            cordova.getThreadPool().execute(new Runnable() {
                @Override
                public void run() {
                    Context context = cd.getActivity().getApplicationContext();
                    WifiManager wifi = (WifiManager) context.getSystemService(WIFI_SERVICE);
                    android.net.wifi.WifiInfo wifiInfo = wifi.getConnectionInfo();
                    int numberOfLevels = 5;

                    JSONObject status = new JSONObject();

                    try {
                        int rssi = wifiInfo.getRssi();
                        int level = WifiManager.calculateSignalLevel(rssi, numberOfLevels);

                        status.put("rssi", rssi);
                        status.put("bars", level);

                        Log.d(TAG, "Sending result: " + status.toString());

                        PluginResult result = new PluginResult(PluginResult.Status.OK, status);
                        result.setKeepCallback(true);
                        callbackContext.sendPluginResult(result);

                    } catch (JSONException e) {
                        Log.e(TAG, e.getMessage(), e);
                        callbackContext.error("Error: " + e.getMessage());
                    }
                }
            });

        } else {
            Log.e(TAG, "Invalid action: " + action);
            callbackContext.error("Invalid action: " + action);
            return false;
        }

        return true;
    }
}
