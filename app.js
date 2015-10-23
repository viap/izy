var config = require('./config');

if (!config.isBrowser()) {
	console.log('starting...');
	
	require('coffee-script/register');
	require('./node_init').init();
} else {
	require('./browser_init').init();
}