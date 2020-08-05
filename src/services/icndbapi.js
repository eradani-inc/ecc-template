// Module icndbapi

function toIndicator(b) {
  return b ? "1" : "0";
}

exports.convertDataToObject = dataIn => {
  // Initialize the request object
  const dataOut = {};

  // Convert fields in record as string to fields in object
  dataOut.limitTo = dataIn.substring(0, 15).trimEnd();

  // Return the request as an object
  return dataOut;
};

exports.convertObjectToRetData = dataIn => {
  // Initialize the response record as string
  let dataOut = "";

  // Convert fields in object to fields in record as string
  dataOut += dataIn.httpstatus.toString().substring(0, 3).padEnd(3);
  dataOut += dataIn.type.substring(0, 16).padEnd(16);
  dataOut += dataIn.value;

  // Return the response record as a string
  return dataOut;
};

exports.convertObjectToRetData2 = dataIn => {
  // Initialize the response record as string
  let dataOut = "";

  // Convert fields in object to fields in record as string
  dataOut += dataIn.joke;

  // Return the response record as a string
  return dataOut;
};

exports.convertObjectToRetData3 = dataIn => {
  // Initialize the response record as string
  let dataOut = "";

  // Convert fields in object to fields in record as string
  dataOut += dataIn.httpstatus.toString().substring(0, 3).padEnd(3);
  dataOut += dataIn.error;

  // Return the response record as a string
  return dataOut;
};