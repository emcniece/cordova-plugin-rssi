# Cordova RSSI Plugin

This plugin allows you to read WiFi RSSI from applications developed using Cordova 3.0 or newer.

Works on both Android and iOS platforms, but **will not pass the Apple App Store Review process**.


## Installation

In your application project directory:

```bash
cordova plugin add cordova-plugin-rssi
```


## Usage

```js
const rssi = cordova.plugins.rssi;
```


#### `rssi.read(success, failure)`
Returns the device's current WiFi RSSI information via 3 parameters:

```js
rssi.read(function success(data){
    console.log(data);
    // -> {rssi: -38, bars: 4, isIPhoneX: false}
});
```

- `rssi: <number|null>`: WiFi Received Signal Strength Indicator
  - Availability: Android, iOS but not iPhoneX
  - Value: Integer or `null` if unavailable
  - Range: `-100 ≤ x ≤ 0`
- `bars: <number>`: Number of visible bars in WiFi icon
  - Availability: Android, iOS
  - Value: Integer
  - Range: `0 ≤ x ≤ 4`: <sup>\*Range values only tested for Android</sup>
    - `4`: RSSI `-55+`
    - `3`: RSSI `-56` - `-66`
    - `2`: RSSI `-67` - `-77`
    - `1`: RSSI `-78` - `-88`
    - `0`: RSSI `-89-`
- `isIPhoneX: <boolean>`: Flag for detecting whether iPhone X acquisition was used
  - Availability: Android, iOS
  - Value: Boolean


## Browser / Development Usage

While developing in browser, a mock can be utilized to prevent errors. See an example Ionic 4 app at [emcniece/ionic-cordova-rssi-demo](https://github.com/emcniece/ionic-cordova-rssi-demo).


## References

- [Android RSSI-to-bar formula](https://android.stackexchange.com/a/176325)
- [Android WifiManager class](https://github.com/eldarerathis/android_frameworks_base/blob/eldarerathis-7.1.x/wifi/java/android/net/wifi/WifiManager.java#L633)

## Licence ##

[The MIT License](./LICENSE)
