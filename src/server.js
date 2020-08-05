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

const ecc = new ECClient(ecclient);

logger.debug("receiving request data queue");
(async function receiveDQ() {
  try {
    // wait for 5 seconds
    const result = await ecc.getNextRequest();
    if (result.data !== "") {
      await handleRequest(result);
    }
    receiveDQ();
  } catch (err) {
    logger.error(`Error: ${err}`);
    logger.close();
  }
})();
