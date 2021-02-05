// Module: icndbapi
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

  // Convert ReqData record to JavaScript object
exports.convertReqDataToObject = function convertReqDataToObject(dataIn) {
  // Initialize the request object
  const dataOut =   {
  
    };

  // Convert fields in record as string to fields in object
  dataOut.limitTo = dataIn.substring(0, 15).trimEnd();

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

  // Convert JavaScript object to ResData record
exports.convertObjectToResData = function convertObjectToResData(dataIn) {
  // Initialize the response record as string
  let dataOut = "";

  // Convert fields in object to fields in record as string
  dataOut += dataIn.joke.substring(0, 80).padEnd(80);

  // Return the response record as a string
  return dataOut;
}
