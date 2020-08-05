const { getforecast } = require("../services/weather");

module.exports.getforecast = async (reqkey, data) => {
  return getforecast(reqkey, data);
};
