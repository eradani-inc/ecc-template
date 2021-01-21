/*

const mocha = require('mocha');
const chai = require('chai');
const chaiHttp = require('chai-http');

const expect = chai.expect;
const utils = require('./utils');
const initializer = require('./initializeTests.js');

chai.use(chaiHttp);

const request = utils.request;

describe('Module Name', function() {
    describe('Action 1', function() {
        describe('As Permission Level 1', function() {
            it('Integration Test 1', function() {
                return request('/url')
                    .post('/')
                    .set('authorization', 'Bearer ' + initializer.getAuthTokens().template)
                    .send({})
                    .then(response => {
                        expect.fail("Unimplemented");
                    });
            });
            
            it('Unit Test 1', function(done) {
                expect.fail("Unimplemented");
                done();
            });
        });
    });
});

*/
