process.env.NODE_CONFIG_DIR = __dirname;
console.log(process.env.NODE_CONFIG_DIR);
import { JSONObject } from 'src/types';
const configModule = require('../../node_modules/config');

function init(): JSONObject {
    // Arbitrary custom logic can be placed here to modify config.
    // For example:   configModule.port = 3001;

    // Config is globally immutable after this function completes.
    lockConfig();
    return configModule;
}

function lockConfig() {
    try {
        configModule.__locked = true;
        configModule.get('__locked');
    } catch (e) {
        e = e;
    }
}

export = init();
