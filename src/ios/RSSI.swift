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

import Foundation

extension UIView {
    func findStatusBarWifiSignalBars() -> Int? {
        for view in subviews {
            if let statusBarWifiSignalView = NSClassFromString("_UIStatusBarWifiSignalView"),
               view.isKind(of: statusBarWifiSignalView) {
                // iPhone X
                return view.value(forKey: "numberOfActiveBars") as? Int
            } else if let statusBarWifiSignalView = NSClassFromString("UIStatusBarDataNetworkItemView"),
                      view.isKind(of: statusBarWifiSignalView) {
                // iPhone non-X
                return view.value(forKey: "wifiStrengthBars") as? Int
            } else if let nestedBars = view.findStatusBarWifiSignalBars() {
                return nestedBars
            }
        }
        return nil
    }
}

@objc(RSSI) public class RSSI : CDVPlugin  {
    @objc(read:)
    public func read(_ command: CDVInvokedUrlCommand) {
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async {
                var rssi: Any
                var bars: Int!
                
                if #available(iOS 13.0, *) {
                    rssi = NSNull() // No method for obtaining RSSI on iOS 13+
                } else {
                    rssi = self.getWifiRSSI() as Any
                }
                
                bars = self.getWifiBars()
                
                #if DEBUG
                    print("cordova-plugin-rssi: rssi: \(rssi), bars: \(bars)")
                #endif

                let message: NSDictionary = NSDictionary(
                    objects: [rssi, bars],
                    forKeys: ["rssi" as NSCopying, "bars" as NSCopying]
                )
                
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: message as? [AnyHashable: Any])
                self.commandDelegate?.send(pluginResult, callbackId: command.callbackId)
            }
        }
    }
    
    private func getWifiRSSI() -> Int? {
        let app = UIApplication.shared
        var rssi: Int?
        
        let exception = tryBlock {
            guard let statusBar = app.value(forKey: "statusBar") as? UIView else { return }
            if let statusBarModern = NSClassFromString("UIStatusBar_Modern"), statusBar .isKind(of: statusBarModern) { return }
            guard let foregroundView = statusBar.value(forKey: "foregroundView") as? UIView else { return  }
            
            for view in foregroundView.subviews {
                if let statusBarDataNetworkItemView = NSClassFromString("UIStatusBarDataNetworkItemView"), view .isKind(of: statusBarDataNetworkItemView) {
                    if let val = view.value(forKey: "wifiStrengthRaw") as? Int {
                        rssi = val
                        break
                    }
                }
            }
        }
        
        if let exception = exception {
            print("cordova-plugin-rssi: getWiFiRSSI exception: \(exception)")
        }
        
        return rssi
    }
    
    private func getWifiBars() -> Int? {
        var bars: Int?
        let exception = tryBlock {
            if #available(iOS 13.0, *) {
                if let statusBarManager = UIApplication.shared.keyWindow?.windowScene?.statusBarManager,
                    let localStatusBar = statusBarManager.value(forKey: "createLocalStatusBar") as? NSObject,
                    let statusBar = localStatusBar.value(forKey: "statusBar") as? NSObject,
                    let _statusBar = statusBar.value(forKey: "_statusBar") as? UIView,
                    let currentData = _statusBar.value(forKey: "currentData")  as? NSObject,
                    let wifi = currentData.value(forKey: "wifiEntry") as? NSObject,
                    let signalStrength = wifi.value(forKey: "displayValue") as? Int {
                    bars = signalStrength
                }
            } else {
                let statusBarView = UIApplication.shared.value(forKey: "statusBar") as! UIView
                bars = statusBarView.findStatusBarWifiSignalBars()
            }
        }
        
        if let exception = exception {
            print("cordova-plugin-rssi: getWifiBars exception: \(exception)")
        }
        
        return bars
    }
}
