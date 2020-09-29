const axios = require("axios");
const {
  traffic
} = require("../../config").get();

const axiosInstance = axios.create(traffic);

exports.getTrafficData = async (reqkey, data, interface, response) => {
  console.log('TrafficAPI:', 'Got data', data);
  // get parameters from incomming data buffer
  const compareData = interface.convertCompareToObject(data);
  console.log('TrafficAPI:', 'Parsed data', compareData);

  // call web service
  let result;
  let nextReqKey = reqkey;
  try {
    console.log('TrafficAPI:', 'Sending Request', "/traffic/6.1/flow.json", {
      params: {
        bbox: '37.8929,-122.3016;37.8851,-122.2744',
        apiKey: traffic.apiKey
      }
    });
    result = await axiosInstance.get("/traffic/6.1/flow.json", {
      params: {
        bbox: '37.8929,-122.3016;37.8851,-122.2744',
        apiKey: traffic.apiKey
      }
    });
  } catch (err) {
    console.log('TrafficAPI:', 'Got ERROR!', err);
    if (err.response) {
      // If the request was made and the server responded with a status code
      // that falls out of the range of 2xx
      // Note: These error formats are dependent on the web service
      return response.sendObjectToCaller({
          httpStatus: err.response.status,
          message: err.response.data.message
        },
        interface.convertObjectToResponse,
        nextReqKey
      );
    }

    // Else the request was made but no response was received
    // Note: This error format has nothing to do with the web service. This is
    // mainly TCP/IP errors.
    return response.sendObjectToCaller({
        httpStatus: 999,
        message: err.message
      },
      interface.convertObjectToResponse,
      nextReqKey
    );
  }

  console.log('TrafficAPI:', 'Got Result from API call', result);

  try {
    let intersection;
    for (let road of result.data.RWS[0].RW) {
      if (road.LI === '105-00419') {
        intersection = road;
        break;
      }
    }

    let roads = [];
    for (let road of intersection.FIS[0].FI) {
      roads.push({
        rank: 0,
        streetName: road.TMC.DE,
        averageSpeed: road.CF[0].SP,
        length: road.TMC.LE,
        jamFactor: road.CF[0].JF * 10,
        confidence: road.CF[0].CN * 100
      });
    }
    
    roads.sort((a, b) => {
      if (a.averageSpeed > b.averageSpeed) {
        return -1;
      } else if (a.averageSpeed < b.averageSpeed) {
        return 1;
      } else {
        return 0;
      }
    });

    for (let i = 0; i < roads.length; i++) {
      roads[i].rank = i + 1;
    }

    nextReqKey = await response.sendObjectToCaller({
        httpStatus: 200,
        message: 'API Call Succeeded'
      },
      interface.convertObjectToResponse,
      nextReqKey
    );

    // Send success result to client
    
    console.log('TrafficAPI:', 'Sending success response', roads);
    return response.sendObjectsToCaller(
      roads,
      interface.convertObjectToTraffic,
      nextReqKey
    );
  } catch(e) {
    console.log('TrafficAPI:', 'Failed parsing results', e);
    return response.sendObjectToCaller({
        httpStatus: 404,
        message: 'No Route Found'
      },
      interface.convertObjectToResponse,
      nextReqKey
    );
  }
};