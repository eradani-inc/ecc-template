import ECCRouter from '@eradani-inc/ecc-router';
import registerJokes from './jokes';

export default async function registerCommands(router: ECCRouter) {
    const jokes = new ECCRouter.Router();
    registerJokes(jokes);
    router.use('jokes', jokes);

    return router;
}