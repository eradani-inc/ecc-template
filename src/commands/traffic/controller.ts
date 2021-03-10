import { ECCHandlerFunction } from '@eradani-inc/ecc-router/types';
import axios from 'axios';
import config from 'config';
import createLogger from 'src/services/logger';
const logger = createLogger('commands/traffic');
const { traffic } = config;
import * as converter from 'src/interfaces/trfcapi';

const axiosInstance = axios.create(traffic);

export const getTrafficData: ECCHandlerFunction = async (reqkey, data, ecc) => {
    logger.debug('TrafficAPI:', 'Got data', data);
    // Get parameters from incomming data buffer
    const compareData = converter.convertCompareToObject(data);
    logger.debug('TrafficAPI:', 'Parsed data', compareData);

    // Call web service
    let result;
    let nextReqKey = reqkey;
    try {
        logger.debug('TrafficAPI:', 'Sending Request', '/traffic/6.1/flow.json', {
            params: {
                bbox: '37.8929,-122.3016;37.8851,-122.2744',
                apiKey: traffic.apiKey
            }
        });
        result = await axiosInstance.get('/traffic/6.1/flow.json', {
            params: {
                bbox: '37.8929,-122.3016;37.8851,-122.2744',
                apiKey: traffic.apiKey
            }
        });
    } catch (err) {
        logger.debug('TrafficAPI:', 'Got ERROR!', err);
        if (err.response) {
            // If the request was made and the server responded with a status code
            // That falls out of the range of 2xx
            // Note: These error formats are dependent on the web service
            return ecc.sendEccResult('ECC1000', err.response.data.error_description, nextReqKey);
        }

        // Else the request was made but no response was received
        // Note: This error format has nothing to do with the web service. This is
        // Mainly TCP/IP errors.
        return ecc.sendEccResult('ECC1000', err.message, nextReqKey);
    }

    logger.debug('TrafficAPI:', 'Got Result from API call', result);

    try {
        let intersection;
        for (let road of result.data.RWS[0].RW) {
            if (road.LI === '105-00419') {
                intersection = road;
                break;
            }
        }

        let roads = [];
        for (let road of intersection.FIS[0].FI) {
            roads.push({
                rank: 0,
                streetName: road.TMC.DE,
                averageSpeed: road.CF[0].SP,
                length: road.TMC.LE,
                jamFactor: road.CF[0].JF * 10,
                confidence: road.CF[0].CN * 100
            });
        }

        roads.sort((a, b) => {
            if (a.averageSpeed > b.averageSpeed) {
                return -1;
            } else if (a.averageSpeed < b.averageSpeed) {
                return 1;
            } else {
                return 0;
            }
        });

        for (let i = 0; i < roads.length; i++) {
            roads[i].rank = i + 1;
        }

        nextReqKey = await ecc.sendEccResult('ECC0000', 'Success', nextReqKey);

        // Send success result to client

        logger.debug('TrafficAPI:', 'Sending success response', roads);
        return ecc.sendObjectsToCaller(roads, converter.convertObjectToTraffic, nextReqKey);
    } catch (e) {
        logger.debug('TrafficAPI:', 'Failed parsing results', e);
        return ecc.sendEccResult('ECC1000', 'No Route Found', nextReqKey);
    }
};
