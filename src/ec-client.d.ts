declare module '@eradani-inc/ec-client' {
    import JSONObject from '@eradani-inc/ecc-router/types/json-object';
    import { ECCInternalRouter } from '@eradani-inc/ecc-router/ecc-router';
    export type RequestKey = number;

    export interface RawDataRecord {
        key: RequestKey;
        data: string;
    }

    export interface RawRequestRecord extends RawDataRecord {
        command: string;
    }

    export type ECCResponseConverter = (object: JSONObject) => string;
    export type ECCRequestConverter = (data: string) => JSONObject;

    export interface ECCRecordConverter {
        [k: string]: ECCRequestConverter & ECCResponseConverter;
    }

    export type ECCHandlerFunction = (
        key: RequestKey,
        data: string,
        converter: ECCRecordConverter,
        ecc: ECClient,
        config: JSONObject
    ) => any;

    export interface ECCHandlerRoute {
        converter: ECCRecordConverter;
        handler: ECCHandlerFunction;
    }

    export interface ECCRouterRoute {
        router: ECCInternalRouter;
    }

    export type ECCRoute = ECCHandlerRoute | ECCRouterRoute;

    export interface ECCRouteList {
        [k: string]: ECCRoute;
    }

    export class ECClient {
        constructor(config: JSONObject);
        connect: () => Promise<void>;
        sendObjectToCaller: (
            object: JSONObject,
            converter: ECCResponseConverter,
            key: RequestKey
        ) => Promise<RequestKey>;
        sendObjectsToCaller: (
            objects: JSONObject[],
            converter: ECCResponseConverter,
            key: RequestKey
        ) => Promise<RequestKey>;
        sendFieldToCaller: (data: string, key: RequestKey) => Promise<RequestKey>;
        getNextRequest: () => Promise<RawRequestRecord>;
        getNextRecord: (key: RequestKey) => Promise<RawDataRecord>;
    }

    namespace ibmiConversions {
        export function fromIbmiDate(ibmiDate: string): Date;

        export function fromIbmiTime(ibmiTime: string): Date;

        export function fromIbmiTimestamp(ibmiTimestamp: string): Date;

        export function toIbmiDate(jsDate: string | Date): string;

        export function toIbmiTime(jsDate: string | Date): string;

        export function toIbmiTimestamp(jsDate: string | Date, length: number): string;
    }
}
