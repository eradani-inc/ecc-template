// Module: icndbapi
// Generated source -- do not modify

import eradaniClient from '@eradani-inc/ec-client';
const {
    fromIbmiDate,
    fromIbmiTime,
    fromIbmiTimestamp,
    toIbmiDate,
    toIbmiTime,
    toIbmiTimestamp
} = eradaniClient.ibmiConversions;

/**
 * Output interface
 */
export interface ReqData {
    /**
     * @size 15 characters
     */
    limitTo: string;
}

/**
 * Convert ReqData record to TypeScript object
 */
export function convertReqDataToObject(dataIn: string): ReqData {
    const dataOut: any = {};

    dataOut.limitTo = dataIn.substring(0, 15).trimEnd();

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
export interface ResData {
    /**
     * @size 80 characters
     */
    joke: string;
}

/**
 * Convert JavaScript object to ResData record
 */
export function convertObjectToResData(dataIn: ResData): string {
    let dataOut = '';

    dataOut += dataIn.joke.substring(0, 80).padEnd(80);

    return dataOut;
}
