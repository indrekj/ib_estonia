const http = require('http');
const url = require('url');
const IB = require('ib');

const PORT = 7633;

const responseCallbacks = {};

const ib = new IB({
}).on('error', err => {
  console.log('ib - %s', err.message);
}).on('contractDetails', (reqId, data) => {
  console.log(`Got contract details for request ${reqId}`)

  const id = data.secIdList.find(({tag, value}) => tag === 'ISIN');
  if (id) {
    console.log(`Found ISIN for request ${reqId}, ${data.summary.symbol}: ${id.value}`);
    responseCallbacks[reqId](id.value);
  } else {
    console.warn(`Request ${reqId} contract does not have ISIN`, data);
    responseCallbacks[reqId](null);
  }
  delete responseCallbacks[reqId];
});
ib.connect();

let lastReqId = 1;

function requestISIN(symbol, cb) {
  const reqId = lastReqId;
  lastReqId++;

  console.log(`Requesting ISIN for ${symbol}, reqId: ${reqId}`);

  // ib.contract.stock takes symbol, exchange and currency. It however looks
  // that we get correct responses by only providing a symbol. It likely
  // default to SMART exchange.
  const contract = ib.contract.stock(symbol);
  ib.reqContractDetails(reqId, contract);
  responseCallbacks[reqId] = cb;

  setTimeout(() => {
    if (responseCallbacks[reqId] !== undefined) {
      console.warn(`Request ${reqId} timed out`);
      responseCallbacks[reqId](null);
      delete responseCallbacks[reqId];
    };
  }, 1000);
}

http.createServer(function (req, res) {
  const queryData = url.parse(req.url, true).query;

  res.writeHead(200, {'Content-Type': 'text/plain'});

	if (queryData.symbol) {
	  requestISIN(queryData.symbol, isin => res.end(isin));
  } else {
    res.end('Please provide `symbol` as a query parameter');
  }
}).listen(PORT);

console.log(`Server running at http://127.0.0.1:${PORT}`);
