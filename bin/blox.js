#!/usr/bin/env node

require('coffee-script');
var blox = require('../lib/blox'),
    addr = process.argv[3];

if (addr && addr.indexOf(':') === -1)
  addr += ':13337';

blox(process.argv[2], addr);
