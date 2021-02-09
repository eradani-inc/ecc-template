import ECCRouter from '@eradani-inc/ecc-router';
import registerJokes from './jokes';
import registerTraffic from './traffic';
import registerVehicle from './vehicle';

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

    return router;
}
