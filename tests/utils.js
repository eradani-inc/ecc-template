const mocha = require('mocha');
const chai = require('chai');
const chaiHttp = require('chai-http');
const expect = chai.expect;

const config = require('../src/config');

chai.use(chaiHttp);

const request = function (route) {
    return chai.request(config.testing.baseUrl + (route || ''));
};

const unimplemented = function (done) {
    return new Promise((_, reject) => {
        reject(chai.expect.fail('Unimplemented'));
    }).catch(done);
};

const _capitalize = function (word) {
    return word.charAt(0).toUpperCase() + word.substr(1, word.length);
};

const _authTokens = {
    admin: null
};

const setAuthToken = function (level, token) {
    _authTokens[level] = token;
};

const getAuthTokens = function () {
    return _authTokens;
};

const expectAccessAccepted = function (request) {
    return request.then((response) => {
        expect(response.forbidden).to.be.false;
        expect(response.unauthorized).to.be.false;
        expect(response.status).to.not.equal(403);
        expect(response.status).to.not.equal(401);
    });
};

const expectAccessRejected = function (request) {
    return request.then((response) => {
        expect(response.forbidden).to.be.true;
        expect(response.status).to.equal(403);
    });
};

const standardPermissionLevels = ['admin'];
const expectMinPermissions = function (minPermissions, method, route) {
    const minPermissionIndex = standardPermissionLevels.indexOf(minPermissions);
    for (let i = 0; i < standardPermissionLevels.length; i++) {
        if (i < minPermissionIndex) {
            it('Blocks access to ' + _capitalize(standardPermissionLevels[i]) + ' users', function () {
                return expectAccessRejected(
                    request(route)
                        [method]('/')
                        .set('authorization', 'Bearer ' + getAuthTokens()[standardPermissionLevels[i]])
                );
            });
        } else {
            it('Allows access to ' + _capitalize(standardPermissionLevels[i]) + ' users', function () {
                return expectAccessAccepted(
                    request(route)
                        [method]('/')
                        .set('authorization', 'Bearer ' + getAuthTokens()[standardPermissionLevels[i]])
                );
            });
        }
    }
};

module.exports = {
    request,
    unimplemented,
    setAuthToken,
    getAuthTokens,
    expectMinPermissions
};
