/**
 * The MIT License (MIT)
 * 
 * Copyright (c) 2018 Eric McNiece <emcniece@gmail.com>
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
*/

package net.emcniece.cordova;

import android.content.Context;
import android.net.wifi.WifiManager;
import android.net.wifi.WifiInfo;
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
                        status.put("isIPhoneX", false);

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
