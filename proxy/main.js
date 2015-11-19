var redis = require('redis')
var express = require('express')
var app = express()
var httpProxy = require('http-proxy')
var PropertiesReader = require('properties-reader')
var Random = require('random-js')

var r = new Random();
var proxyPort = 8080;    // default port
process.argv.forEach(function (val, index, array) {
    if (index == 2) {
        proxyPort = parseInt(val);
    }
});

var client = redis.createClient(6379, '127.0.0.1', {})

var stableNode;
client.get("stable_node", function(err, value) {
    stableNode = value;
});

var isCanaryEnabled = false;
var canaryNode = null;
var routeToCanaryPercentage = 30; // default value to ensure no failure for the first time

var proxy = httpProxy.createProxyServer({});
var proxyApp = express();
proxyApp.all('/*', function(req, res) {
    client.get('is_canary_enabled', function(err, value) {
        isCanaryEnabled = value;
        if (isCanaryEnabled == 'true') {
            if (canaryNode == null) {
                client.get('canary_route_percentage', function(err, v1) {
                    routeToCanaryPercentage = v1;
                    client.get('canary_node', function(err, v2) {
                        canaryNode = v2;
                    });
                });
            }
        } else {
            canaryNode = null;            
        }
    });

    var targetNode = stableNode;
    if (isCanaryEnabled && (canaryNode != null)) {
        console.log("canary node is enabled");
        if (r.bool(routeToCanaryPercentage, 100)) {
            targetNode = canaryNode;
        }
    };
    
    console.log("proxying request to %s", targetNode);
    proxy.web(req, res, {target: targetNode});
});

var proxyServer = proxyApp.listen(proxyPort, function() {
    var host = proxyServer.address().address
    if (!host || host == "::") {
        host = "localhost";
    }
    var port = proxyServer.address().port
    console.log('Proxy server listening at http://%s:%s', host, port)
});
