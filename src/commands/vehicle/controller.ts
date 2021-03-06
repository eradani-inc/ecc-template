import { ECCHandlerFunction } from '@eradani-inc/ecc-router/types';
import axios from 'axios';
import config from 'config';
import createLogger from 'src/services/logger';
const logger = createLogger('commands/vehicle');
const { vehicle } = config;
import * as converter from 'src/interfaces/vinapi';

const axiosInstance = axios.create(vehicle);

export const getVehicleData: ECCHandlerFunction = async (reqkey, data, ecc) => {
    logger.debug('VinAPI:', 'Got data', data);
    // Get parameters from incomming data buffer
    const vinData = converter.convertVinDataToObject(data);
    logger.debug('VinAPI:', 'Parsed data', vinData);

    // Call web service
    let result;
    let nextReqKey = reqkey;
    try {
        logger.debug('VinAPI:', 'Sending Request', '/vehicles/decodevinvalues/' + vinData.vin, {
            params: {
                format: 'json',
                modelyear: vinData.modelYear
            }
        });
        result = await axiosInstance.get('/vehicles/decodevinvalues/' + vinData.vin, {
            params: {
                format: 'json',
                modelyear: vinData.modelYear
            }
        });
    } catch (err) {
        logger.debug('VinAPI:', 'Got ERROR!', err);
        if (err.response) {
            // If the request was made and the server responded with a status code
            // That falls out of the range of 2xx
            // Note: These error formats are dependent on the web service
            return ecc.sendEccResult('ECC1000', err.response.data.message, nextReqKey);
        }

        // Else the request was made but no response was received
        // Note: This error format has nothing to do with the web service. This is
        // Mainly TCP/IP errors.
        return ecc.sendEccResult('ECC1000', err.message, nextReqKey);
    }

    logger.debug('VinAPI:', 'Got Result from API call', result);
    if (!result || !result.data || !result.data.Results || !result.data.Results.length || vinData.modelYear >= 2030) {
        logger.debug('VinAPI:', 'No data in response, sending 404');
        return ecc.sendEccResult('ECC1000', 'No Results Found', nextReqKey);
    }

    // Send success result to client
    nextReqKey = await ecc.sendEccResult('ECC0000', 'Success', nextReqKey);

    const responseData = result.data.Results[0];
    logger.debug('VinAPI:', 'Sending vin info', responseData);
    return ecc.sendObjectToCaller(responseData, converter.convertObjectToVinInfo, nextReqKey);
};
