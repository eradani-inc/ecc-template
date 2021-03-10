const axios = require("axios");
const HttpsProxyAgent = require("https-proxy-agent");
const { icndb, proxy, ecclient } = require("../config");
const {
  convertReqDataToObject,
  convertObjectToEccResult,
  convertObjectToResData,
} = require("../interfaces/icndbapi");
const { ECClient, sendEccResult } = require("@eradani-inc/ec-client");

const agent = new HttpsProxyAgent(proxy);

if (proxy.enabled) {
  icndb.httpsAgent = agent;
}

const ecc = new ECClient(ecclient);

const axiosInstance = axios.create(icndb);

exports.getJoke = async (reqkey, data) => {
  // get parameters from incomming data buffer
  const reqFields = convertReqDataToObject(data);

  // call web service
  let result;
  let nextReqKey = reqkey;
  try {
    result = await axiosInstance.get("/jokes/random", { params: reqFields });
  } catch (err) {
    if (err.response) {
      // If the request was made and the server responded with a status code
      // that falls out of the range of 2xx
      // Note: These error formats are dependent on the web service
      return ecc.sendEccResult(
        "ECC1000",
        err.response.status + "-" + err.response.statusText,
        nextReqKey
      );
    }

    // Else the request was made but no response was received
    // Note: This error format has nothing to do with the web service. This is
    // mainly TCP/IP errors.
    return ecc.sendEccResult("ECC1000", err.message, nextReqKey);
  }

  if (result.data.type !== "success") {
    // If the request did not succeed
    // Note: if not successful value is a string containing the error
    return ecc.sendEccResult(
      "ECC1000",
      result.status + "-" + result.data.value,
      nextReqKey
    );
  }

  // Else save the joke then change the value field so it is as expected
  // Note: if successful value is an object containing the joke and other info
  const { joke } = result.data.value;
  result.data.httpstatus = result.status;
  result.data.value = "";

  // Send the result info
  nextReqKey = await ecc.sendEccResult("ECC0000", "Success", nextReqKey);

  // Send the joke
  return ecc.sendFieldToCaller(joke, nextReqKey);
};
