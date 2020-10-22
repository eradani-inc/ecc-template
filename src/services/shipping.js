const axios = require("axios");
const download = require('download');
const { shipping, ecclient } = require("../config");
const { ECClient } = require("@eradani-inc/ec-client");
const converter = require('./lblapi');
const response = new ECClient(ecclient);

const axiosInstance = axios.create(shipping);

exports.getShippingLabel = async (reqkey, data) => {
  console.log('ShippingAPI:', 'Got data', data);
  // get parameters from incomming data buffer
  const labelInput = converter.convertLabelDataToObject(data);
  console.log('ShippingAPI:', 'Parsed data', labelInput);

  // call web service
  let result;
  let nextReqKey = reqkey;
  try {
    let reqData = {
      shipment: {
        service_code: "usps_priority_mail",
        ship_to: {
          name: labelInput.toName,
          address_line1: labelInput.toAddress,
          city_locality: labelInput.toCity,
          state_province: labelInput.toState,
          postal_code: labelInput.toZip,
          country_code: labelInput.toCountry,
          address_residential_indicator: "yes"
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
    }

    console.log('ShippingAPI:', 'Sending Request', "/labels", JSON.stringify(reqData));
    result = await axiosInstance.post("/labels", reqData, {
      headers: {
        'Content-Type': 'application/json',
        'API-Key': shipping.apiKey
      }
    });
  } catch (err) {
    console.log('ShippingAPI:', 'Got ERROR!', err);
    if (err.response) {
      // If the request was made and the server responded with a status code
      // that falls out of the range of 2xx
      // Note: These error formats are dependent on the web service
      return response.sendObjectToCaller({
          httpstatus: err.response.status,
          message: err.response.data.message
        },
        converter.convertObjectToResponse,
        nextReqKey
      );
    }

    // Else the request was made but no response was received
    // Note: This error format has nothing to do with the web service. This is
    // mainly TCP/IP errors.
    return response.sendObjectToCaller({
        httpstatus: 999,
        error: err.message
      },
      converter.convertObjectToResponse,
      nextReqKey
    );
  }

  console.log('ShippingAPI:', 'Got Result from API call', result);
  const resultData = {
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

  console.log('ShippingAPI:', 'Writing label files (async)');

  await Promise.all([
    download(result.data.label_download.pdf, 'temp/usps'),
    download(result.data.label_download.png, 'temp/usps'),
    download(result.data.label_download.zpl, 'temp/usps')
  ]);

  // Send success result to client
  
  console.log('ShippingAPI:', 'Sending Result Data', JSON.stringify(resultData));
  nextReqKey = await response.sendObjectToCaller(
    resultData,
    converter.convertObjectToResult,
    nextReqKey
  );
  console.log('ShippingAPI:', 'Sending Label Data', JSON.stringify(labelData));
  return response.sendObjectToCaller(
    labelData,
    converter.convertObjectToLabel,
    nextReqKey
  );
};