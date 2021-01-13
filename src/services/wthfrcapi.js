// Module wthfrcapi

function toIndicator(b) {
    return b ? '1' : '0';
}

exports.convertLocationToObject = (dataIn) => {
    // Initialize the request object
    const dataOut = {};

    // Convert fields in record as string to fields in object
    dataOut.lat = Number(dataIn.substring(0, 10).trimEnd());
    dataOut.lon = Number(dataIn.substring(10, 20).trimEnd());

    // Return the request as an object
    return dataOut;
};

exports.convertObjectToResult = (dataIn) => {
    // Initialize the response record as string
    let dataOut = '';

    // Convert fields in object to fields in record as string
    dataOut += dataIn.httpstatus.toString().substring(0, 3).padEnd(3);
    dataOut += dataIn.message.substring(0, 77).padEnd(77);

    // Return the response record as a string
    return dataOut;
};

exports.convertObjectToForecast = (dataIn) => {
    // Initialize the response record as string
    let dataOut = '';

    // Convert fields in object to fields in record as string
    dataOut += dataIn.date.substring(0, 10).padEnd(10);
    dataOut += dataIn.min.toString().substring(0, 6).padEnd(6);
    dataOut += dataIn.max.toString().substring(0, 6).padEnd(6);
    dataOut += dataIn.description.substring(0, 58).padEnd(58);

    // Return the response record as a string
    return dataOut;
};
