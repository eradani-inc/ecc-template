/* eslint-disable */
// @ts-nocheck
// Module: trfcapi
// Generated source -- do not modify

const { ibmiConversions } = require("@eradani-inc/ec-client");
const {
  fromIbmiDate,
  fromIbmiTime,
  fromIbmiTimestamp,
  toIbmiDate,
  toIbmiTime,
  toIbmiTimestamp
} = ibmiConversions;

  // Convert Compare record to JavaScript object
exports.convertCompareToObject = function convertCompareToObject(dataIn) {
  // Initialize the request object
  const dataOut =   {
  
    };

  // Convert fields in record as string to fields in object
  dataOut.type = dataIn.substring(0, 10).trimEnd();

  // Return the request as an object
  return dataOut;
}

  // Convert JavaScript object to Traffic record
exports.convertObjectToTraffic = function convertObjectToTraffic(dataIn) {
  // Initialize the response record as string
  let dataOut = "";

  // Convert fields in object to fields in record as string
  dataOut += dataIn.rank.toFixed(0).substring(0, 4).padEnd(4);
  dataOut += dataIn.streetName.substring(0, 30).padEnd(30);
  dataOut += dataIn.averageSpeed.toFixed(1).substring(0, 6).padEnd(6);
  dataOut += dataIn.length.toFixed(5).substring(0, 9).padEnd(9);
  dataOut += dataIn.jamFactor.toFixed(5).substring(0, 10).padEnd(10);
  dataOut += dataIn.confidence.toFixed(0).substring(0, 5).padEnd(5);

  // Return the response record as a string
  return dataOut;
}

/* eslint-enable */
