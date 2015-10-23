// set this var to appropriate value (dev / prod):
exports.env = process.argv[2] || process.env.NODE_ENV || (this.window && this.window.ENV) || 'dev';

exports.isBrowser = function() {
	return typeof window !== 'undefined';
}

exports.isServer = function() {
	return typeof window === 'undefined';
}

exports.isProduction = function() {
	return exports.env === 'prod' || exports.env === 'production';
}

if (exports.isProduction() === true) {
	exports.server = {
		url: 'http://beta-music-svoy.azurewebsites.net',
		api: 'http://beta-music-svoy.azurewebsites.net',
		apiTest2: 'http://dev.svoy.ru',
		apiTest: 'http://private-39ce-svoy.apiary-mock.com',
		workerPort: process.env.PORT
	};
} else {
	exports.server = {
		url: 'http://localhost:5000',
		api: 'http://localhost:5000',
		apiTest2: 'http://dev.svoy.ru',
		apiTest: 'http://private-39ce-svoy.apiary-mock.com',
		workerPort: 5000
	};
}

exports.sessionCookieName = '__IZY_SESSION__';
exports.anonymousCookieName = '__IZY_LABEL__';