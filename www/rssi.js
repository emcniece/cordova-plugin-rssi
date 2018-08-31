'use strict';
const exec = require('cordova/exec');

const RSSI = {
  read : function(success, failure) {
      return exec(success, failure, "RSSI", "read", []);
  }
};

module.exports = RSSI;