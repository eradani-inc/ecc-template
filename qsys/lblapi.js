/* eslint-disable */
// @ts-nocheck
// Module: lblapi
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

  // Convert LabelData record to JavaScript object
exports.convertLabelDataToObject = function convertLabelDataToObject(dataIn) {
  // Initialize the request object
  const dataOut =   {
  
    };

  // Convert fields in record as string to fields in object
  dataOut.toName = dataIn.substring(0, 16).trimEnd();
  dataOut.toAddress = dataIn.substring(16, 36).trimEnd();
  dataOut.toCity = dataIn.substring(36, 46).trimEnd();
  dataOut.toState = dataIn.substring(46, 48).trimEnd();
  dataOut.toZip = dataIn.substring(48, 53).trimEnd();
  dataOut.toCountry = dataIn.substring(53, 56).trimEnd();
  dataOut.weight = dataIn.substring(56, 61).trimEnd();
  dataOut.weightUnits = dataIn.substring(61, 63).trimEnd();
  dataOut.height = dataIn.substring(63, 68).trimEnd();
  dataOut.width = dataIn.substring(68, 73).trimEnd();
  dataOut.length = dataIn.substring(73, 78).trimEnd();
  dataOut.sizeUnits = dataIn.substring(78, 80).trimEnd();

  // Return the request as an object
  return dataOut;
}

  // Convert JavaScript object to ShipInfo record
exports.convertObjectToShipInfo = function convertObjectToShipInfo(dataIn) {
  // Initialize the response record as string
  let dataOut = "";

  // Convert fields in object to fields in record as string
  dataOut += dataIn.labelStatus.substring(0, 10).padEnd(10);
  dataOut += dataIn.shipmentId.substring(0, 11).padEnd(11);
  dataOut += dataIn.labelId.substring(0, 11).padEnd(11);
  dataOut += dataIn.shipmentCost.toFixed(2).substring(0, 12).padEnd(12);
  dataOut += dataIn.shipmentCostCurrency.substring(0, 3).padEnd(3);
  dataOut += dataIn.insuranceCost.toFixed(2).substring(0, 12).padEnd(12);
  dataOut += dataIn.insuranceCostCurrency.substring(0, 3).padEnd(3);

  // Return the response record as a string
  return dataOut;
}

  // Convert JavaScript object to Label record
exports.convertObjectToLabel = function convertObjectToLabel(dataIn) {
  // Initialize the response record as string
  let dataOut = "";

  // Convert fields in object to fields in record as string
  dataOut += dataIn.trackingNumber.substring(0, 30).padEnd(30);
  dataOut += dataIn.labelPdfFile.substring(0, 23).padEnd(23);
  dataOut += dataIn.labelZplFile.substring(0, 23).padEnd(23);

  // Return the response record as a string
  return dataOut;
}

/* eslint-enable */
