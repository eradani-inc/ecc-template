import { ECCInternalRouter } from '@eradani-inc/ecc-router/ecc-router';
import { getTrafficData } from './controller';
import * as trfcapi from 'src/interfaces/trfcapi';

export default function registerTraffic(router: ECCInternalRouter) {
    router.use('getdata', trfcapi, getTrafficData);
}
