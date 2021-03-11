/* eslint-disable */
// @ts-nocheck
// Module: vinapi
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

  // Convert VinData record to JavaScript object
exports.convertVinDataToObject = function convertVinDataToObject(dataIn) {
  // Initialize the request object
  const dataOut =   {
  
    };

  // Convert fields in record as string to fields in object
  dataOut.vin = dataIn.substring(0, 17).trimEnd();
  dataOut.modelYear = Number(dataIn.substring(17, 23).trimEnd());

  // Return the request as an object
  return dataOut;
}

  // Convert JavaScript object to VinInfo record
exports.convertObjectToVinInfo = function convertObjectToVinInfo(dataIn) {
  // Initialize the response record as string
  let dataOut = "";

  // Convert fields in object to fields in record as string
  dataOut += dataIn.ElectrificationLevel.substring(0, 35).padEnd(35);
  dataOut += dataIn.FuelTypePrimary.substring(0, 15).padEnd(15);
  dataOut += dataIn.FuelTypeSecondary.substring(0, 25).padEnd(25);

  // Return the response record as a string
  return dataOut;
}

/* eslint-enable */
