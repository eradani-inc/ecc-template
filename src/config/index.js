const _ = require("lodash");
const defaults = require("./default");

const config = require(`./${process.env.NODE_ENV || "development"}`);

module.exports = _.merge({}, defaults, config);
