/* eslint-disable */
// @ts-nocheck
// Module: wthfrcapi
// Generated source -- do not modify

import { ibmiConversions } from '@eradani-inc/ec-client';
const { fromIbmiDate, fromIbmiTime, fromIbmiTimestamp, toIbmiDate, toIbmiTime, toIbmiTimestamp } = ibmiConversions;

/**
 * Output interface
 */
export interface Location {
    /**
     * @size 9 digits
     * @precision 6 decimals
     */
    lat: number;
    /**
     * @size 9 digits
     * @precision 6 decimals
     */
    lon: number;
}

/**
 * Convert Location record to TypeScript object
 */
export function convertLocationToObject(dataIn: string): Location {
    const dataOut: any = {};

    dataOut.lat = Number(dataIn.substring(0, 11).trimEnd());
    dataOut.lon = Number(dataIn.substring(11, 22).trimEnd());

    return dataOut;
}

/**
 * Input interface
 */
export interface EccResult {
    /**
     * @size 7 characters
     */
    MsgId: string;
    /**
     */
    MsgTime: Date;
    /**
     * @size 50 characters
     */
    MsgDesc: string;
}

/**
 * Convert JavaScript object to EccResult record
 */
export function convertObjectToEccResult(dataIn: EccResult): string {
    let dataOut = '';

    dataOut += dataIn.MsgId.substring(0, 7).padEnd(7);
    dataOut += toIbmiTimestamp(dataIn.MsgTime, 23);
    dataOut += dataIn.MsgDesc.substring(0, 50).padEnd(50);

    return dataOut;
}

/**
 * Input interface
 */
export interface Forecast {
    /**
     */
    date: Date;
    /**
     * @size 5 digits
     * @precision 2 decimals
     */
    min: number;
    /**
     * @size 5 digits
     * @precision 2 decimals
     */
    max: number;
    /**
     * @size 58 characters
     */
    description: string;
}

/**
 * Convert JavaScript object to Forecast record
 */
export function convertObjectToForecast(dataIn: Forecast): string {
    let dataOut = '';

    dataOut += toIbmiDate(dataIn.date);
    dataOut += dataIn.min.toFixed(2).substring(0, 7).padEnd(7);
    dataOut += dataIn.max.toFixed(2).substring(0, 7).padEnd(7);
    dataOut += dataIn.description.substring(0, 58).padEnd(58);

    return dataOut;
}

/* eslint-enable */
