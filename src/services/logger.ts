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
 */

const winston = require('winston');
require('winston-daily-rotate-file');
const path = require('path');
const config = require('../../config').get().logger;

const formatter = winston.format.printf((options: any) => {
    let logString = ''
        + `[${options.level.toUpperCase()}]`.padEnd(7, ' ')
        + `(${(new Date).toISOString()})` 
        + ` -- In ${options.context}: ${options.message}$`;
    return logString;
});

const normalTransport = new winston.transports.DailyRotateFile({
    filename: path.join(__dirname, '../../logs/' + (process.env.APP_TESTING === 'true' ? 'testing/' : ''), '%DATE%.log'),
    datePattern: 'YYYY-MM-DD',
    prepend: true,
    json: true,
    level: config.maxLoggingLevel,
    format: formatter
});

// Only handles uncaught exceptions in the program
const exceptionTransport = new winston.transports.DailyRotateFile({
    filename: path.join(__dirname, '../../logs/' + (process.env.APP_TESTING === 'true' ? 'testing/' : '') + 'exceptions/', '%DATE%.exceptions'),
    datePattern: 'YYYY-MM-DD',
    prepend: true,
    handleExceptions: true,
    humanReadableUnhandledException: true,
    json: true,
    level: config.maxLoggingLevel,
    format: formatter
});

const consoleTransport = new winston.transports.Console({
    level: config.maxLoggingLevel,
    format: formatter
});

const logger = winston.createLogger({
    transports: [
        normalTransport,
        consoleTransport
    ],
    exceptionHandlers: [
        normalTransport,
        consoleTransport,
        exceptionTransport
    ],
    exitOnError: false
});

// Don't output to the console if we're in testing mode
if (config.disableConsole) {
    logger.remove(consoleTransport);
}

export default function (context: string) {
    // Set the default context of the child
    return logger.child({ context });
}
