const axios = require("axios");
const { weather, ecclient } = require("../config");
const { ECClient, sendEccResult } = require("@eradani-inc/ec-client");
const {
  convertLocationToObject,
  convertObjectToEccResult,
  convertObjectToForecast,
} = require("../interfaces/wthfrcapi");

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
      return ecc.sendEccResult(
        "ECC1000",
        err.response.data.message,
        nextReqKey
      );
    }

    // Else the request was made but no response was received
    // Note: This error format has nothing to do with the web service. This is
    // mainly TCP/IP errors.
    return ecc.sendEccResult("ECC1000", err.message, nextReqKey);
  }

  // Send success result to client
  nextReqKey = await ecc.sendEccResult("ECC0000", "Success", nextReqKey);

  // Reduce response to an array of forecasts
  const forecasts = result.data.daily.map((obj) => {
    return {
      date: obj.dt * 1000, // new Date(obj.dt * 1000),
      min: obj.temp.min,
      max: obj.temp.max,
      description: obj.weather[0].description,
    };
  });

  // Send array of forecasts back to client
  return ecc.sendObjectsToCaller(
    forecasts,
    convertObjectToForecast,
    nextReqKey
  );
};
