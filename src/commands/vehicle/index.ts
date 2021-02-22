import { ECCInternalRouter } from '@eradani-inc/ecc-router/ecc-router';
import { getVehicleData } from './controller';
import * as vinapi from 'src/interfaces/vinapi';

export default function registerVehicle(router: ECCInternalRouter) {
    router.use('getdata', vinapi, getVehicleData);
}
