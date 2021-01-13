import _ from "lodash";
import defaults from "./default.json";
import overrides from './overrides.json';
let config = {};

try {
    config = require(`./${process.env.NODE_ENV || "development"}`);
} catch(e) {
    console.log(`Requested environment config (${process.env.NODE_ENV || "development"}) not found`);
}

export default _.merge({}, defaults, overrides, config);
