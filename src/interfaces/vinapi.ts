/* eslint-disable */
// @ts-nocheck
// Module: vinapi
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
export interface VinData {
    /**
     * @size 17 characters
     */
    vin: string,
    /**
     * @size 4 digits
     * @precision 0 decimals
     */
    modelYear: number
}

/**
 * Convert VinData record to TypeScript object
 */
export function convertVinDataToObject(dataIn: string): VinData {
  const dataOut: any =   {
  
    };

  dataOut.vin = dataIn.substring(0, 17).trimEnd();
  dataOut.modelYear = Number(dataIn.substring(17, 23).trimEnd());

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
export interface VinInfo {
    /**
     * @size 35 characters
     */
    ElectrificationLevel: string,
    /**
     * @size 15 characters
     */
    FuelTypePrimary: string,
    /**
     * @size 25 characters
     */
    FuelTypeSecondary: string
}

/**
 * Convert JavaScript object to VinInfo record
 */
export function convertObjectToVinInfo(dataIn: VinInfo): string {
  let dataOut = "";

  dataOut += dataIn.ElectrificationLevel.substring(0, 35).padEnd(35);
  dataOut += dataIn.FuelTypePrimary.substring(0, 15).padEnd(15);
  dataOut += dataIn.FuelTypeSecondary.substring(0, 25).padEnd(25);

  return dataOut;
}

/* eslint-enable */
