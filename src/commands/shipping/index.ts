import { ECCInternalRouter } from '@eradani-inc/ecc-router/ecc-router';
import { getLabel } from './controller';
import * as lblapi from 'src/interfaces/lblapi';

export default function registerWeather(router: ECCInternalRouter) {
    router.use('getlabel', lblapi, getLabel);
}
