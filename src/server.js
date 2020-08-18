const { ECClient } = require("@eradani-inc/ec-client");
const getjoke = require("./commands/getjoke");
const { getforecast } = require("./services/weather");
const logger = require("./services/logger").forContext("server");
const { ecclient } = require("./config");

async function handleRequest(data) {
  switch (data.command) {
    case "getjoke":
      return getjoke(data.key, data.data);
    case "getgridinfo":
      return getgridinfo(data.key, data.data);
    case "getgridinfo2":
      return getgridinfo2(data.key, data.data);
    case "getweatherforecast":
      return getforecast(data.key, data.data);
    default:
      throw new RangeError(`"${data.command}" is not a valid command.`);
  }
}

(async () => {
  try {
    const ecc = new ECClient(ecclient);
    await ecc.connect();

    while (true) {
      // getNextRequest will wait for 5 seconds before timing out
      const result = await ecc.getNextRequest();
      if (result.command) {
        // if there wasn't a time out handle the request
        await handleRequest(result);
      }
    }
  } catch (err) {
    logger.error(`Error: ${err}`);
    logger.close();
  }
})();
