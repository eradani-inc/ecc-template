const { ECClient } = require("@eradani-inc/ec-client");
const ECCRouter = require('@eradani-inc/ecc-router');
const { getJoke } = require('./services/icndb');
const icndbapi = require('./services/icndbapi');
const logger = require("./services/logger").forContext("server");
const { ecclient } = require("./config");

const ecc = new ECClient(ecclient);
const router = new ECCRouter(ecc, { debug: true });
router.use('getjoke', icndbapi, getJoke);

router.listen();
