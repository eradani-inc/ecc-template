const axios = require('axios');
const { weather, ecclient } = require('../config');
const { ECClient } = require('@eradani-inc/ec-client');
const { convertLocationToObject, convertObjectToResult, convertObjectToForecast } = require('./wthfrcapi');

const ecc = new ECClient(ecclient);

const axiosInstance = axios.create(weather);

exports.getforecast = async (reqkey, data) => {
    // get parameters from incomming data buffer
    const reqFields = convertLocationToObject(data);

    // add api key
    reqFields.appid = weather.apikey;

    // add constraints
    reqFields.exclude = 'current,minutely,hourly';
    reqFields.units = 'imperial';

    // call web service
    let result;
    let nextReqKey = reqkey;
    try {
        result = await axiosInstance.get('onecall', { params: reqFields });
    } catch (err) {
        if (err.response) {
            // If the request was made and the server responded with a status code
            // that falls out of the range of 2xx
            // Note: These error formats are dependent on the web service
            return ecc.sendObjectToCaller(
                {
                    httpstatus: err.response.status,
                    message: err.response.data.message
                },
                convertObjectToResult,
                nextReqKey
            );
        }

        // Else the request was made but no response was received
        // Note: This error format has nothing to do with the web service. This is
        // mainly TCP/IP errors.
        return ecc.sendObjectToCaller(
            {
                httpstatus: 999,
                error: err.message
            },
            convertObjectToResult,
            nextReqKey
        );
    }

    // Send success result to client
    nextReqKey = await ecc.sendObjectToCaller(
        {
            httpstatus: result.status,
            message: ''
        },
        convertObjectToResult,
        nextReqKey
    );

    // Reduce response to an array of forecasts
    const forecasts = result.data.daily.map((obj) => {
        const dt = new Date(obj.dt * 1000);
        const DD = dt.getDate().toString().padStart(2, '0');
        const MM = (dt.getMonth() + 1).toString().padStart(2, '0');
        const YYYY = dt.getFullYear().toString();
        const dtAsStr = `${YYYY}-${MM}-${DD}`;
        return {
            date: dtAsStr,
            min: obj.temp.min,
            max: obj.temp.max,
            description: obj.weather[0].description
        };
    });

    // Send array of forecasts back to client
    return ecc.sendObjectsToCaller(forecasts, convertObjectToForecast, nextReqKey);
};
