import ECCRouter from '@eradani-inc/ecc-router';
import registerJokes from './jokes';
import registerTraffic from './traffic';
import registerVehicle from './vehicle';
import registerWeather from './weather';
import registerShipping from './shipping';

export default async function registerCommands(router: ECCRouter) {
    const jokes = new ECCRouter.Router();
    registerJokes(jokes);
    router.use('jokes', jokes);

    const traffic = new ECCRouter.Router();
    registerTraffic(traffic);
    router.use('traffic', traffic);

    const vehicle = new ECCRouter.Router();
    registerVehicle(vehicle);
    router.use('vehicle', vehicle);

    const weather = new ECCRouter.Router();
    registerWeather(weather);
    router.use('weather', weather);

    const shipping = new ECCRouter.Router();
    registerShipping(shipping);
    router.use('shipping', shipping);

    return router;
}
