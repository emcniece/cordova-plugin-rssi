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

@objc(RSSI) public class RSSI : CDVPlugin  {

    override public func pluginInitialize() {
    }

    override public func onAppTerminate() {
    }

    
    public func read(_ command: CDVInvokedUrlCommand) {

        let hostname = "test" //Hostname.get() as String

        #if DEBUG
            print("RSSI: hostname \(hostname)")
        #endif

        let pluginResult = CDVPluginResult(status:CDVCommandStatus_OK, messageAs: hostname)
        self.commandDelegate?.send(pluginResult, callbackId: command.callbackId)
    }
    

    /*
    public func read(_ command: CDVInvokedUrlCommand) {

        #if DEBUG
            print("RSSI: read")
        #endif

        let hostname = Hostname.get() as String
        let message: NSDictionary = NSDictionary(
            objects: [hostname, false, false, false],
            forKeys: ["hostname" as NSCopying, "connection" as NSCopying, "interfaces" as NSCopying, "dhcp" as NSCopying]
        )

        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: message as! [AnyHashable: Any])
        self.commandDelegate?.send(pluginResult, callbackId: command.callbackId)
    }
    */
}
