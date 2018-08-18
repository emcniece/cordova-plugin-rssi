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
