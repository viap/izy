require('coffee-script/register');
var config = require('./config');

if (config.isBrowser() === false) {
	console.log('starting...');
	require('./node_init').init();
} else {
	require('./browser_init').init();
}

