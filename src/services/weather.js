const axios = require("axios");
const { weather, ecclient } = require("../config");
const { ECClient } = require("@eradani-inc/ec-client");
const {
  convertLocationToObject,
  convertObjectToEccResult,
  convertObjectToForecast,
} = require("./wthfrcapi");

const ecc = new ECClient(ecclient);

const axiosInstance = axios.create(weather);

exports.getforecast = async (reqkey, data) => {
  // get parameters from incomming data buffer
  const reqFields = convertLocationToObject(data);

  // add api key
  reqFields.appid = weather.apikey;

  // add constraints
  reqFields.exclude = "current,minutely,hourly";
  reqFields.units = "imperial";

  // call web service
  let result;
  let nextReqKey = reqkey;
  try {
    result = await axiosInstance.get("onecall", { params: reqFields });
  } catch (err) {
    if (err.response) {
      // If the request was made and the server responded with a status code
      // that falls out of the range of 2xx
      // Note: These error formats are dependent on the web service
      return ecc.sendObjectToCaller(
        {
          MsgId: "ECC1000",
          MsgTime: new Date(),
          MsgDesc: err.response.data.message,
        },
        convertObjectToEccResult,
        nextReqKey
      );
    }

    // Else the request was made but no response was received
    // Note: This error format has nothing to do with the web service. This is
    // mainly TCP/IP errors.
    return ecc.sendObjectToCaller(
      {
        MsgId: "ECC1000",
        MsgTime: new Date(),
        MsgDesc: err.message,
      },
      convertObjectToEccResult,
      nextReqKey
    );
  }

  // Send success result to client
  nextReqKey = await ecc.sendObjectToCaller(
    {
      MsgId: "ECC0000",
      MsgTime: new Date(),
      MsgDesc: "Success",
    },
    convertObjectToEccResult,
    nextReqKey
  );

  console.log("Unmapped forecast received:");
  console.log(JSON.stringify(result.data.daily));

  // Reduce response to an array of forecasts
  const forecasts = result.data.daily.map((obj) => {
    return {
      date: new Date(obj.dt * 1000),
      min: obj.temp.min,
      max: obj.temp.max,
      description: obj.weather[0].description,
    };
  });

  console.log("Forcasts received:");
  console.log(JSON.stringify(forecasts));

  // Send array of forecasts back to client
  return ecc.sendObjectsToCaller(
    forecasts,
    convertObjectToForecast,
    nextReqKey
  );
};
