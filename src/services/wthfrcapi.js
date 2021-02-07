// Module: wthfrcapi
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

  // Convert Location record to JavaScript object
exports.convertLocationToObject = function convertLocationToObject(dataIn) {
  // Initialize the request object
  const dataOut =   {
  
    };

  // Convert fields in record as string to fields in object
  dataOut.lat = Number(dataIn.substring(0, 11).trimEnd());
  dataOut.lon = Number(dataIn.substring(11, 22).trimEnd());

  // Return the request as an object
  return dataOut;
}

  // Convert JavaScript object to EccResult record
exports.convertObjectToEccResult = function convertObjectToEccResult(dataIn) {
  // Initialize the response record as string
  let dataOut = "";

  // Convert fields in object to fields in record as string
  dataOut += dataIn.MsgId.substring(0, 7).padEnd(7);
  dataOut += toIbmiTimestamp(dataIn.MsgTime, 23);
  dataOut += dataIn.MsgDesc.substring(0, 50).padEnd(50);

  // Return the response record as a string
  return dataOut;
}

  // Convert JavaScript object to Forecast record
exports.convertObjectToForecast = function convertObjectToForecast(dataIn) {
  // Initialize the response record as string
  let dataOut = "";

  // Convert fields in object to fields in record as string
  dataOut += toIbmiDate(dataIn.date);
  dataOut += dataIn.min.toFixed(2).substring(0, 7).padEnd(7);
  dataOut += dataIn.max.toFixed(2).substring(0, 7).padEnd(7);
  dataOut += dataIn.description.substring(0, 58).padEnd(58);

  // Return the response record as a string
  return dataOut;
}
