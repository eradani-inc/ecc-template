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

  // Convert Data record to JavaScript object
exports.convertDataToObject = function convertDataToObject(dataIn) {
  // Initialize the request object
  const dataOut =   {
  
    };

  // Convert fields in record as string to fields in object
  dataOut.limitTo = dataIn.substring(0, 15).trimEnd();

  // Return the request as an object
  return dataOut;
}

  // Convert JavaScript object to RetData record
exports.convertObjectToRetData = function convertObjectToRetData(dataIn) {
  // Initialize the response record as string
  let dataOut = "";

  // Convert fields in object to fields in record as string
  dataOut += dataIn.httpstatus.toFixed(0).substring(0, 5).padEnd(5);
  dataOut += dataIn.type.substring(0, 16).padEnd(16);
  dataOut += dataIn.value;

  // Return the response record as a string
  return dataOut;
}

  // Convert JavaScript object to RetData2 record
exports.convertObjectToRetData2 = function convertObjectToRetData2(dataIn) {
  // Initialize the response record as string
  let dataOut = "";

  // Convert fields in object to fields in record as string
  dataOut += dataIn.joke;

  // Return the response record as a string
  return dataOut;
}

  // Convert JavaScript object to RetData3 record
exports.convertObjectToRetData3 = function convertObjectToRetData3(dataIn) {
  // Initialize the response record as string
  let dataOut = "";

  // Convert fields in object to fields in record as string
  dataOut += dataIn.httpstatus.toFixed(0).substring(0, 5).padEnd(5);
  dataOut += dataIn.error;

  // Return the response record as a string
  return dataOut;
}
