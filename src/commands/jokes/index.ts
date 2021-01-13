import { ECCInternalRouter } from '@eradani-inc/ecc-router/ecc-router';
import { getJoke } from './controller';
import icndbapi from 'src/interfaces/icndbapi';

export default function registerJokes(router: ECCInternalRouter) {

    router.use('getjoke', icndbapi, getJoke);

}
