const axios = require("axios");
const download = require("download");
const { shipping, ecclient } = require("../config");
const { ECClient } = require("@eradani-inc/ec-client");
const logger = require("./logger").forContext("services/shipping");
const converter = require("../interfaces/lblapi");
const response = new ECClient(ecclient);

const axiosInstance = axios.create(shipping);

exports.getShippingLabel = async (reqkey, data) => {
  logger.debug("Got data");
  logger.silly(JSON.stringify(data));
  // get parameters from incomming data buffer
  const labelInput = converter.convertLabelDataToObject(data);
  logger.debug("Parsed data");
  logger.silly(JSON.stringify(labelInput));

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
          address_residential_indicator: "yes",
        },
        ship_from: shipping.shipFrom,
        packages: [
          {
            weight: {
              value: labelInput.weight,
              unit: labelInput.weightUnits === "OZ" ? "ounce" : "",
            },
            dimensions: {
              height: labelInput.height,
              width: labelInput.width,
              length: labelInput.length,
              unit: labelInput.sizeUnits === "IN" ? "inch" : "",
            },
          },
        ],
      },
    };

    logger.debug('Sending Request to "/labels"');
    logger.silly(JSON.stringify(reqData));

    result = await axiosInstance.post("/labels", reqData, {
      headers: {
        "Content-Type": "application/json",
        "API-Key": shipping.apiKey,
      },
    });
  } catch (err) {
    logger.warn("Got ERROR");
    logger.warn(err);

    if (err.response) {
      logger.warn("Sending http failure response");

      // If the request was made and the server responded with a status code
      // that falls out of the range of 2xx
      // Note: These error formats are dependent on the web service
      return response.sendObjectToCaller(
        {
          MsgId: "ECC1000",
          MsgTime: new Date(),
          MsgDesc:
            err.response.status + "-" + err.response.data.errors[0].message,
        },
        converter.convertObjectToEccResult,
        nextReqKey
      );
    }

    logger.warn("Sending generic (999) failure response");

    // Else the request was made but no response was received
    // Note: This error format has nothing to do with the web service. This is
    // mainly TCP/IP errors.
    return response.sendObjectToCaller(
      {
        MsgId: "ECC1000",
        MsgTime: new Date(),
        MsgDesc: err.message,
      },
      converter.convertObjectToEccResult,
      nextReqKey
    );
  }

  logger.debug("Got success result from API call");
  logger.silly(result);

  const shippingInfo = {
    httpstatus: result.status,
    labelStatus: result.data.status,
    shipmentId: result.data.shipment_id,
    labelId: result.data.label_id,
    shipmentCost: result.data.shipment_cost.amount,
    shipmentCostCurrency: result.data.shipment_cost.currency,
    insuranceCost: result.data.insurance_cost.amount,
    insuranceCostCurrency: result.data.insurance_cost.currency,
  };

  const labelFileParts = result.data.label_download.href.split("/");
  const labelFileName = labelFileParts[labelFileParts.length - 1].split(".")[0];

  const labelData = {
    trackingNumber: result.data.tracking_number,
    labelPdfFile: `temp/${labelFileName}.pdf`,
    labelZplFile: `temp/${labelFileName}.zpl`,
  };

  logger.debug("Writing label files (async)");

  await Promise.all([
    download(result.data.label_download.pdf, "temp/usps"),
    download(result.data.label_download.png, "temp/usps"),
    download(result.data.label_download.zpl, "temp/usps"),
  ]);

  // Send success result to client
  nextReqKey = await response.sendObjectToCaller(
    {
      MsgId: "ECC0000",
      MsgTime: new Date(),
      MsgDesc: "Success",
    },
    converter.convertObjectToEccResult,
    nextReqKey
  );

  logger.debug("Sending Shipping Info");
  logger.silly(JSON.stringify(shippingInfo));

  nextReqKey = await response.sendObjectToCaller(
    shippingInfo,
    converter.convertObjectToShipInfo,
    nextReqKey
  );

  logger.debug("Sending Label Data");
  logger.silly(JSON.stringify(labelData));

  return response.sendObjectToCaller(
    labelData,
    converter.convertObjectToLabel,
    nextReqKey
  );
};
