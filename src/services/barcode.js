const {
  barcode,
  ecclient
} = require("../config");
const fs = require('fs/promises');
const path = require('path');
const {
  ECClient
} = require("@eradani-inc/ec-client");
const jsbarcode = require('jsbarcode');
const { createCanvas, loadImage, Image } = require('canvas');
const logger = require("./logger").forContext("services/barcode");
const converter = require('./barcdeapi');
const response = new ECClient(ecclient);

exports.getBarcodeLabel = async (reqkey, data) => {
  logger.debug('Got data');
  logger.silly(JSON.stringify(data));
  // get parameters from incoming data buffer
  const labelData = converter.convertCodeDataToObject(data);
  logger.debug('Parsed data');
  logger.silly(JSON.stringify(labelData));

  let nextReqKey = reqkey;
  try {
    const canvas = _createMainCanvas();
    _drawOutline(canvas);
    _addText(canvas, labelData);

    const barcodeCanvas = createCanvas();
    jsbarcode(barcodeCanvas, labelData.code, {
      format: 'upc'
    });
    const barcode = barcodeCanvas.toDataURL();

    await _addBarcode(canvas, barcode);

    let filename = `barcode-${+new Date()}-${nextReqKey}.b64`;

    await fs.writeFile(path.join(__dirname, '../../temp/barcode', filename), canvas.toDataURL());

    result = {
      status: 'SUCCESS',
      message: 'Barcode Label Generated Successfully',
      ifsFile: filename
    };

    // Send success result to client

    logger.debug('Sending Result Data');
    logger.silly(JSON.stringify(result));

    nextReqKey = await response.sendObjectToCaller(
      result,
      converter.convertObjectToResult,
      nextReqKey
    );

    logger.debug('Sending Label Data');
    logger.silly(JSON.stringify(labelData));

    return response.sendObjectToCaller(
      result,
      converter.convertObjectToBarcode,
      nextReqKey
    );

  } catch (err) {

    logger.warn('Got ERROR');
    logger.warn(err);

    return response.sendObjectToCaller({
        status: 'ERROR',
        message: err.message
      },
      converter.convertObjectToResult,
      nextReqKey
    );
  }
};

function _createMainCanvas() {
  const canvas = createCanvas(500, 600);
  canvas.block1Height = 175;
  canvas.block2Height = 115;
  canvas.padding = {
    x: 20,
    y: 50
  };
  canvas.lineHeight = 50;

  return canvas;
}

function _drawOutline(canvas) {
  const { width, height, block1Height, block2Height } = canvas;
  const ctx = canvas.getContext('2d');
  ctx.fillStyle = `#FFFFFF`;
  ctx.fillRect(0, 0, width, height);
  ctx.strokeStyle = 'rgba(0, 0, 0, 0.5)';
  ctx.beginPath();
  ctx.lineTo(0, height);
  ctx.lineTo(width, height);
  ctx.lineTo(width, 0);
  ctx.lineTo(0, 0);
  ctx.moveTo(0, block1Height);
  ctx.lineTo(width, block1Height);
  ctx.moveTo(0, block1Height + block2Height);
  ctx.lineTo(width, block1Height + block2Height);
  ctx.moveTo(width / 3, block1Height);
  ctx.lineTo(width / 3, block1Height + block2Height);
  ctx.stroke();
}

function _addText(canvas, labelData) {
  const { width, height, block1Height, block2Height, padding, lineHeight } = canvas;
  const ctx = canvas.getContext('2d');
  ctx.font = 'bold 30px arial';
  ctx.textAlign = "start";
  ctx.textBaseline = "bottom";
  ctx.fillStyle = "rgba(0, 0, 0, 1)";
  ctx.fillText(labelData.customer, padding.x, padding.y, width - padding.x * 2);
  ctx.fillText(labelData.address, padding.x, padding.y + lineHeight, width - padding.x * 2);
  const address2 = `${labelData.city}, ${labelData.state} ${labelData.zip}`;
  ctx.fillText(address2, padding.x, padding.y + lineHeight * 2, width - padding.x * 2);

  ctx.font = 'light 30px arial';
  ctx.fillText('PRD: ' + labelData.product, width / 3 + padding.x, block1Height + padding.y, (2 * width / 3) - (padding.x * 2));
  ctx.fillText('QTY: ' + labelData.quantity, width / 3 + padding.x, block1Height + lineHeight + padding.y, (2 * width / 3) - (padding.x * 2));
}

async function _addBarcode(canvas, barcode) {
  const { width, height, block1Height, block2Height, padding, lineHeight } = canvas;
  const barcodeSize = height - block1Height - block2Height - padding.x * 2;
  const ctx = canvas.getContext('2d');
  const image = new Image();
  image.src = barcode;
  ctx.drawImage(image, width / 2 - barcodeSize / 2, block1Height + block2Height + padding.x, barcodeSize, barcodeSize);
}