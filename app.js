var config = require('./config');

if (!config.isBrowser()) {
	require('coffee-script/register');
	require('./node_init').init();
} else {
	require('./browser_init').init();
}