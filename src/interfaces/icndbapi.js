"use strict";
// Module: icndbapi
// Generated source -- do not modify
exports.__esModule = true;
exports.convertObjectToResData = exports.convertObjectToEccResult = exports.convertReqDataToObject = void 0;
var ec_client_1 = require("@eradani-inc/ec-client");
var _a = ec_client_1["default"].ibmiConversions, 
// @ts-ignore
fromIbmiDate = _a.fromIbmiDate, 
// @ts-ignore
fromIbmiTime = _a.fromIbmiTime, 
// @ts-ignore
fromIbmiTimestamp = _a.fromIbmiTimestamp, 
// @ts-ignore
toIbmiDate = _a.toIbmiDate, 
// @ts-ignore
toIbmiTime = _a.toIbmiTime, 
// @ts-ignore
toIbmiTimestamp = _a.toIbmiTimestamp;
/**
 * Convert ReqData record to TypeScript object
 */
var convertReqDataToObject = function (dataIn) {
    var dataOut = {};
    dataOut.limitTo = dataIn.substring(0, 15).trimEnd();
    return dataOut;
};
exports.convertReqDataToObject = convertReqDataToObject;
/**
 * Convert JavaScript object to EccResult record
 */
var convertObjectToEccResult = function (dataIn) {
    var dataOut = '';
    dataOut += dataIn.MsgId.substring(0, 7).padEnd(7);
    dataOut += toIbmiTimestamp(dataIn.MsgTime, 23);
    dataOut += dataIn.MsgDesc.substring(0, 50).padEnd(50);
    return dataOut;
};
exports.convertObjectToEccResult = convertObjectToEccResult;
/**
 * Convert JavaScript object to ResData record
 */
function convertObjectToResData(dataIn) {
    var dataOut = '';
    dataOut += dataIn.joke.substring(0, 80).padEnd(80);
    return dataOut;
}
exports.convertObjectToResData = convertObjectToResData;
