import ECCRouter from '@eradani-inc/ecc-router';
import { ECClient } from '@eradani-inc/ec-client';

import config from 'config';
import { createLogger } from '@eradani-inc/ec-logger';
const { ecclient, debug } = config;
import registerCommands from 'src/commands';

const logger = createLogger('app', true);

let router: ECCRouter;

async function start() {
    const ecc = new ECClient(ecclient);
    router = new ECCRouter(ecc, { debug });

    await registerCommands(router);

    await router.listen();

    logger.info('ECC App Listening for Commands');
}

async function stop() {
    return router.close();
}

module.exports = {
    startup: start(),
    stop
};
