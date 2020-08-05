/**
 * Logging Utility
 * Provides a standard interface for logging to a daily log file, and also 
 * logs to the console. Logs are prefixed with one of NPM's logging levels
 * (Error, Warn, Info, Verbose, Debug, and Silly) along with a context label
 * which you provide, such as "core.services.database", to help you locate the
 * source of the log.
 * 
 * There is a setting in the application config file under "logger" called
 * "maxLoggingLevel". You can set this logging level to one of the NPM levels,
 * and this Logger will ignore any logs beyond that level. For example, if you
 * set the maxLoggingLevel to "warn", only "error" and "warn" level logs will
 * be stored. "info", "verbose", "debug", and "silly" log statements will be
 * ignored by the logger.
 *
 * To construct a new logger, add the following code to the top of your JS file:
 * const logger = require('path/to/logger.js').forContext('my.custom.context');
 * 
 * Logs are stored in the '/logs' directory at the root of this application's
 * source code, and are named by their creation dates in the following format:
 * YYYY-MM-DD.log
 * 
 * For example, the log file for October 7th, 2019 would be: 2019-10-07.log
 * 
 * Happy Logging!
**/

const fs = require('fs');
const path = require('path');
const config = require('../config').logger;

const _writestream = fs.createWriteStream(path.join(__dirname, `../../logs/${(new Date).toISOString().split('T')[0].replace(/:/g, '-')}.log`), {flags:'a', autoClose: false});
const _stream = { write: (message) => _cache.push(message) };
let _cache = [];
function forContext(contextString) {
    return new Logger(contextString);
}

class Logger {

    constructor(contextString) {
        this._contextString = contextString;
        const levels = ['error', 'warn', 'info', 'verbose', 'debug', 'silly'];
        const lowestDisabled = (levels.indexOf(config.maxLoggingLevel) + 1) || levels.length;
        for (let i = lowestDisabled; i < levels.length; i++) {
            this[levels[i]] = () => {};
        }
    }

    close() {
        return new Promise(r => {
            _writestream.write(_cache.join(''), () => {
                _cache = [];
                _writestream.close();
                r();
            });
        });
    }

    log(level, message) {
        let logString = `[${level.toUpperCase()}]`.padEnd(7, ' ') + `(${(new Date).toISOString()})` + ` -- In ${this._contextString}: ${message}\n`;
        console.log(logString);
	_stream.write(logString);
    }

    error(message) {
        return this.log('error', message);
    }

    warn(message) {
        return this.log('warn', message);
    }

    info(message) {
        return this.log('info', message);
    }

    verbose(message) {
        return this.log('vrbse', message);
    }

    debug(message) {
        return this.log('debug', message);
    }

    silly(message) {
        return this.log('silly', message);
    }
}

module.exports = {
    forContext
};
