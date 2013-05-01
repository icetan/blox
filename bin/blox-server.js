#!/usr/bin/env node

require('coffee-script');
var server = require('../lib/server');

server.listen(parseInt(process.argv[2]) || 13337);
