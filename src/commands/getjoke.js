const { getJoke } = require("../services/icndb");

module.exports = async (reqkey, data) => {
  return getJoke(reqkey, data);
};
