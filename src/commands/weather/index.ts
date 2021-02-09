import { ECCInternalRouter } from '@eradani-inc/ecc-router/ecc-router';
import { getForecast } from './controller';
import * as wthfrcapi from 'src/interfaces/wthfrcapi';

export default function registerWeather(router: ECCInternalRouter) {
    router.use('getforecast', wthfrcapi, getForecast);
}
