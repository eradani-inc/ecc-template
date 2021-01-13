const _ = require("lodash");
const defaults = require("./default");
const overrides = require('./overrides');
let config = {};

try {
    config = require(`./${process.env.NODE_ENV || "development"}`);
} catch(e) {}

module.exports = _.merge({}, defaults, overrides, config);
