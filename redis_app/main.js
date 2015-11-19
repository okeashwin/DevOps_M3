var redis = require('redis')
var express = require('express')
var app = express()

var serverPort = 8090;
process.argv.forEach(function (val, index, array) {
    if (index == 2) {
        serverPort = parseInt(val);
    }
});

// REDIS
var client = redis.createClient(6379, '127.0.0.1', {})

app.use(function(req, res, next) {
    next();
});

app.get('/canary', function(req, res) {
    if (req.query.flag == "on") {        
        var canaryNode;
        if (req.query.protocol) {
            canaryNode = req.query.protocol;
        } else {
            canaryNode = 'http';
        }
        canaryNode += ('://' + req.query.ip + ':' + req.query.port + '/');        
        client.set('canary_node', canaryNode);

        client.set('canary_route_percentage', req.query.percentage);
        client.set('is_canary_enabled', 'true');
        res.send('Enabled Canary Server at ' + canaryNode);
    } else {
        client.set('is_canary_enabled', 'false');
        res.send('Disabled Canary Server');
    }
});

app.get('/stable', function(req, res) {
    var stableNode;
    if (req.query.protocol) {
        stableNode = req.query.protocol;
    } else {
        stableNode = 'http';
    }
    stableNode += ('://' + req.query.ip + ':' + req.query.port + '/');
    client.set('stable_node', stableNode);
    res.send('Stable server successfully set to ' + stableNode);
});

// Server Info (ip, port, number of servers)
var server = app.listen(serverPort);
var host = server.address().address;
if (!host || host == "::") {
    host = "localhost";
}
var targetNode = "http" + "://" + host + ":" + serverPort;
console.log('App listening at %s', targetNode);

