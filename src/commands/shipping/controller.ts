import { ECCHandlerFunction } from '@eradani-inc/ecc-router/types';
import axios from 'axios';
import download from 'download';
import config from 'config';
import createLogger from 'src/services/logger';
const logger = createLogger('commands/shipping');
const { shipping } = config;
import * as converter from 'src/interfaces/lblapi';

const axiosInstance = axios.create(shipping);

export const getLabel: ECCHandlerFunction = async (reqkey, data, ecc) => {
    logger.debug('Got data');
    logger.silly(JSON.stringify(data));
    // Get parameters from incomming data buffer
    const labelInput = converter.convertLabelDataToObject(data);
    logger.debug('Parsed data');
    logger.silly(JSON.stringify(labelInput));

    // Call web service
    let result;
    let nextReqKey = reqkey;
    try {
        /* eslint-disable */
        let reqData = {
            shipment: {
                service_code: 'usps_priority_mail',
                ship_to: {
                    name: labelInput.toName,
                    address_line1: labelInput.toAddress,
                    city_locality: labelInput.toCity,
                    state_province: labelInput.toState,
                    postal_code: labelInput.toZip,
                    country_code: labelInput.toCountry,
                    address_residential_indicator: 'yes'
                },
                ship_from: shipping.shipFrom,
                packages: [
                    {
                        weight: {
                            value: labelInput.weight,
                            unit: labelInput.weightUnits === 'OZ' ? 'ounce' : ''
                        },
                        dimensions: {
                            height: labelInput.height,
                            width: labelInput.width,
                            length: labelInput.length,
                            unit: labelInput.sizeUnits === 'IN' ? 'inch' : ''
                        }
                    }
                ]
            }
        };
        /* eslint-enable */

        logger.debug('Sending Request to "/labels"');
        logger.silly(JSON.stringify(reqData));

        result = await axiosInstance.post('/labels', reqData, {
            headers: {
                'Content-Type': 'application/json',
                'API-Key': shipping.apiKey
            }
        });
    } catch (err) {
        logger.warn('Got ERROR');
        logger.warn(err);

        if (err.response) {
            logger.warn('Sending http failure response');

            // If the request was made and the server responded with a status code
            // That falls out of the range of 2xx
            // Note: These error formats are dependent on the web service
            return ecc.sendEccResult(
                'ECC1000',
                err.response.status + '-' + err.response.data.errors[0].message,
                nextReqKey
            );
        }

        logger.warn('Sending generic (999) failure response');

        // Else the request was made but no response was received
        // Note: This error format has nothing to do with the web service. This is
        // Mainly TCP/IP errors.
        return ecc.sendEccResult('ECC1000', err.message, nextReqKey);
    }

    logger.debug('Got success result from API call');
    logger.silly(result);

    const shippingInfo = {
        httpstatus: result.status,
        labelStatus: result.data.status,
        shipmentId: result.data.shipment_id,
        labelId: result.data.label_id,
        shipmentCost: result.data.shipment_cost.amount,
        shipmentCostCurrency: result.data.shipment_cost.currency,
        insuranceCost: result.data.insurance_cost.amount,
        insuranceCostCurrency: result.data.insurance_cost.currency
    };

    const labelFileParts = result.data.label_download.href.split('/');
    const labelFileName = labelFileParts[labelFileParts.length - 1].split('.')[0];

    const labelData = {
        trackingNumber: result.data.tracking_number,
        labelPdfFile: `temp/${labelFileName}.pdf`,
        labelZplFile: `temp/${labelFileName}.zpl`
    };

    logger.debug('Writing label files (async)');

    await Promise.all([
        download(result.data.label_download.pdf, 'temp/usps'),
        download(result.data.label_download.png, 'temp/usps'),
        download(result.data.label_download.zpl, 'temp/usps')
    ]);

    // Send success result to client
    nextReqKey = await ecc.sendEccResult('ECC0000', 'Success', nextReqKey);

    logger.debug('Sending Shipping Info');
    logger.silly(JSON.stringify(shippingInfo));

    nextReqKey = await ecc.sendObjectToCaller(shippingInfo, converter.convertObjectToShipInfo, nextReqKey);

    logger.debug('Sending Label Data');
    logger.silly(JSON.stringify(labelData));

    return ecc.sendObjectToCaller(labelData, converter.convertObjectToLabel, nextReqKey);
};
