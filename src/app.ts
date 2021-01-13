import ECCRouter from "@eradani-inc/ecc-router";
import { ECClient } from "@eradani-inc/ec-client";

import loggerService from "./services/logger";
import { ecclient, debug } from "./config";
import registerCommands from './commands';

const logger = loggerService.forContext("app");
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
