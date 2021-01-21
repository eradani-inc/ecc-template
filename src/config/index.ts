import _ from 'lodash';
import fs from 'fs';
import path from 'path';
import { JSONObject } from 'src/types';

const defaults = JSON.parse(fs.readFileSync(path.join(__dirname, 'default.json')).toString());
const overrides = JSON.parse(fs.readFileSync(path.join(__dirname, 'overrides.json')).toString());
let config = {};

try {
    config = JSON.parse(fs.readFileSync(path.join(__dirname, `${process.env.NODE_ENV || 'development'}`)).toString());
} catch (e) {
    console.warn(`Requested environment config (${process.env.NODE_ENV || 'development'}) not found`);
}

export = _.merge({}, defaults, overrides, config) as JSONObject;
