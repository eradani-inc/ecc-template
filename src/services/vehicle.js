const axios = require("axios");
const { vehicle, ecclient } = require("../config");
const { ECClient } = require("@eradani-inc/ec-client");
const interface = require("../interfaces/vinapi");
const response = new ECClient(ecclient);

const axiosInstance = axios.create(vehicle);

exports.getVehicleData = async (reqkey, data) => {
  console.log("VinAPI:", "Got data", data);
  // get parameters from incomming data buffer
  const vinData = interface.convertVinDataToObject(data);
  console.log("VinAPI:", "Parsed data", vinData);

  // call web service
  let result;
  let nextReqKey = reqkey;
  try {
    console.log(
      "VinAPI:",
      "Sending Request",
      "/vehicles/decodevinvalues/" + vinData.vin,
      {
        params: {
          format: "json",
          modelyear: vinData.modelYear,
        },
      }
    );
    result = await axiosInstance.get(
      "/vehicles/decodevinvalues/" + vinData.vin,
      {
        params: {
          format: "json",
          modelyear: vinData.modelYear,
        },
      }
    );
  } catch (err) {
    console.log("VinAPI:", "Got ERROR!", err);
    if (err.response) {
      // If the request was made and the server responded with a status code
      // that falls out of the range of 2xx
      // Note: These error formats are dependent on the web service
      return response.sendObjectToCaller(
        {
          MsgId: "ECC1000",
          MsgTime: new Date(),
          MsgDesc: err.response.data.message,
        },
        interface.convertObjectToEccResult,
        nextReqKey
      );
    }

    // Else the request was made but no response was received
    // Note: This error format has nothing to do with the web service. This is
    // mainly TCP/IP errors.
    return response.sendObjectToCaller(
      {
        MsgId: "ECC1000",
        MsgTime: new Date(),
        MsgDesc: err.message,
      },
      interface.convertObjectToEccResult,
      nextReqKey
    );
  }

  console.log("VinAPI:", "Got Result from API call", result);
  if (
    !result ||
    !result.data ||
    !result.data.Results ||
    !result.data.Results.length ||
    parseInt(vinData.modelYear, 10) >= 2030
  ) {
    console.log("VinAPI:", "No data in response, sending 404");
    return response.sendObjectToCaller(
      {
        MsgId: "ECC1000",
        MsgTime: new Date(),
        MsgDesc: "No Results Found",
      },
      interface.convertObjectToEccResult,
      nextReqKey
    );
  }

  // Send success result to client
  nextReqKey = await response.sendObjectToCaller(
    {
      MsgId: "ECC0000",
      MsgTime: new Date(),
      MsgDesc: "Success",
    },
    interface.convertObjectToEccResult,
    nextReqKey
  );

  const responseData = result.data.Results[0];
  console.log("VinAPI:", "Sending vin info", responseData);
  return response.sendObjectToCaller(
    responseData,
    interface.convertObjectToVinInfo,
    nextReqKey
  );
};
