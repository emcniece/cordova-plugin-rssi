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

/*
 * UIDevice Extension
 * Detects iPhoneX devices.
 * Usage: `if UIDevice.isIphoneX {}`
 * https://stackoverflow.com/a/47566231/943540
 *
 * modelIdentifier:
 *   iPad Pro: 7,1
 *   iPhone SE: 8,4
 *   iPhone 8: 10,4, 10,5
 *   iPhone X: 10,3 10,6
 *   iPhone XR: 11,8
 *   iPhone XS: 11,2
 *   iPhone XS Max: 11,4
 */
extension UIDevice {
    static var isIphoneX: Bool {
        var modelIdentifier = ""
        if isSimulator {
            modelIdentifier = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] ?? ""
        } else {
            var size = 0
            sysctlbyname("hw.machine", nil, &size, nil, 0)
            var machine = [CChar](repeating: 0, count: size)
            sysctlbyname("hw.machine", &machine, &size, nil, 0)
            modelIdentifier = String(cString: machine)
        }

        let modelNumber = modelIdentifier
            .replacingOccurrences(of: "iPhone", with: "")
            .replacingOccurrences(of: "iPad", with: "")
        let modelArray = modelNumber.components(separatedBy: ",")
        let modelMajor:Int! = Int(modelArray[0])
        let modelMinor:Int! = Int(modelArray[1])
        
        #if DEBUG
            print("modelIdentifier: \(modelIdentifier)")
            print("modelArray: \(modelArray)")
        #endif

        if modelMajor < 10 {
            // iPhone 7 and below
            return false
        } else if modelMajor == 10 && modelMinor == 3 {
            // iPhone X, but not iPhone 8
            return true
        } else if modelMajor == 10 && modelMinor == 6 {
            // iPhone X, but not iPhone 8
            return true
        } else if modelMajor > 10 {
            // iPhone XR, XS, XS Max, and above
            return true
        } else {
            // Unknown
            return false
        }
    }
    
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }
}

@objc(RSSI) public class RSSI : CDVPlugin  {
    public func read(_ command: CDVInvokedUrlCommand) {
        var rssi: Any
        var bars: Int!
        var isIPhoneX: Bool! = false
        
        if UIDevice.isIphoneX {
            isIPhoneX = true
            rssi = NSNull() // No method for obtaining RSSI on iPhoneX
            bars = self.getXWifiBars()
        } else {
            rssi = self.getNormalWifiRSSI() as Any
            bars = self.getNormalWifiBars()
        }
        
        #if DEBUG
            print("RSSI: rssi: \(rssi), bars: \(bars), isIPhoneX: \(isIPhoneX)")
        #endif

        let message: NSDictionary = NSDictionary(
            objects: [rssi, bars, isIPhoneX],
            forKeys: ["rssi" as NSCopying, "bars" as NSCopying, "isIPhoneX" as NSCopying]
        )
        
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: message as! [AnyHashable: Any])
        self.commandDelegate?.send(pluginResult, callbackId: command.callbackId)
    }
    
    private func getNormalWifiRSSI() -> Int? {
        let app = UIApplication.shared
        var rssi: Int?
        
        let exception = tryBlock {
            guard let statusBar = app.value(forKey: "statusBar") as? UIView else { return }
            if let statusBarMorden = NSClassFromString("UIStatusBar_Modern"), statusBar .isKind(of: statusBarMorden) { return }
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
            print("getWiFiRSSI exception: \(exception)")
        }
        
        return rssi
    }
    
    private func getNormalWifiBars() -> Int? {
        let app = UIApplication.shared
        var bars: Int?
        
        let exception = tryBlock {
            guard let statusBar = app.value(forKey: "statusBar") as? UIView else { return }
            if let statusBarMorden = NSClassFromString("UIStatusBar_Modern"), statusBar .isKind(of: statusBarMorden) { return }
            guard let foregroundView = statusBar.value(forKey: "foregroundView") as? UIView else { return  }
            
            for view in foregroundView.subviews {
                if let statusBarDataNetworkItemView = NSClassFromString("UIStatusBarDataNetworkItemView"), view .isKind(of: statusBarDataNetworkItemView) {
                    if let val = view.value(forKey: "wifiStrengthBars") as? Int {
                        bars = val
                        break
                    }
                }
            }
        }
        
        if let exception = exception {
            print("getNormalWifiBars exception: \(exception)")
        }
        
        return bars
    }
    
    private func getXWifiBars() -> Int? {
        let app = UIApplication.shared
        var bars: Int?
        
        let exception = tryBlock {
            guard let containerBar = app.value(forKey: "statusBar") as? UIView else { return }
            guard let statusBarMorden = NSClassFromString("UIStatusBar_Modern"), containerBar .isKind(of: statusBarMorden) else { return }
            guard let statusBar = containerBar.value(forKey: "statusBar") as? UIView else { return }
            guard let foregroundView = statusBar.value(forKey: "foregroundView") as? UIView else { return }
            
            for view in foregroundView.subviews {
                for v in view.subviews {
                    if let statusBarWifiSignalView = NSClassFromString("_UIStatusBarWifiSignalView"), v .isKind(of: statusBarWifiSignalView) {
                        if let val = v.value(forKey: "numberOfActiveBars") as? Int {
                            bars = val
                            break
                        }
                    }
                }
            }
        }
        
        if let exception = exception {
            print("getXWifiBars exception: \(exception)")
        }
        
        return bars
    }
}
