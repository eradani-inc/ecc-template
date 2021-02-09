/* eslint-disable */
// @ts-nocheck
// Module: trfcapi
// Generated source -- do not modify

import { ibmiConversions } from "@eradani-inc/ec-client";
const {
  fromIbmiDate,
  fromIbmiTime,
  fromIbmiTimestamp,
  toIbmiDate,
  toIbmiTime,
  toIbmiTimestamp
} = ibmiConversions;

/**
 * Output interface
 */
export interface Compare {
    /**
     * @size 10 characters
     */
    type: string
}

/**
 * Convert Compare record to TypeScript object
 */
export function convertCompareToObject(dataIn: string): Compare {
  const dataOut: any =   {
  
    };

  dataOut.type = dataIn.substring(0, 10).trimEnd();

  return dataOut;
}

/**
 * Input interface
 */
export interface EccResult {
    /**
     * @size 7 characters
     */
    MsgId: string,
    /**
     */
    MsgTime: Date,
    /**
     * @size 50 characters
     */
    MsgDesc: string
}

/**
 * Convert JavaScript object to EccResult record
 */
export function convertObjectToEccResult(dataIn: EccResult): string {
  let dataOut = "";

  dataOut += dataIn.MsgId.substring(0, 7).padEnd(7);
  dataOut += toIbmiTimestamp(dataIn.MsgTime, 23);
  dataOut += dataIn.MsgDesc.substring(0, 50).padEnd(50);

  return dataOut;
}

/**
 * Input interface
 */
export interface Traffic {
    /**
     * @size 2 digits
     * @precision 0 decimals
     */
    rank: number,
    /**
     * @size 30 characters
     */
    streetName: string,
    /**
     * @size 4 digits
     * @precision 1 decimals
     */
    averageSpeed: number,
    /**
     * @size 7 digits
     * @precision 5 decimals
     */
    length: number,
    /**
     * @size 8 digits
     * @precision 5 decimals
     */
    jamFactor: number,
    /**
     * @size 3 digits
     * @precision 0 decimals
     */
    confidence: number
}

/**
 * Convert JavaScript object to Traffic record
 */
export function convertObjectToTraffic(dataIn: Traffic): string {
  let dataOut = "";

  dataOut += dataIn.rank.toFixed(0).substring(0, 4).padEnd(4);
  dataOut += dataIn.streetName.substring(0, 30).padEnd(30);
  dataOut += dataIn.averageSpeed.toFixed(1).substring(0, 6).padEnd(6);
  dataOut += dataIn.length.toFixed(5).substring(0, 9).padEnd(9);
  dataOut += dataIn.jamFactor.toFixed(5).substring(0, 10).padEnd(10);
  dataOut += dataIn.confidence.toFixed(0).substring(0, 5).padEnd(5);

  return dataOut;
}

/* eslint-enable */
