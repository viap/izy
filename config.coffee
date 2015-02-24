# set this var to appropriate value (dev / prod):
exports.env = process.argv[2] || process.env.NODE_ENV || window?.ENV || 'dev'

exports.isBrowser = () ->
	return typeof window != 'undefined'

exports.isServer = () ->
	return typeof window == 'undefined'

exports.isProduction = () ->
	return exports.env == 'prod' || exports.env == 'production'

if exports.isProduction() == true
	exports.server =
		url: 'http://beta-music-svoy.azurewebsites.net'
		api: 'http://beta-music-svoy.azurewebsites.net'
		apiTest2: 'http://dev.svoy.ru'
		apiTest: 'http://private-39ce-svoy.apiary-mock.com'
		workerPort: process.env.PORT
else
	exports.server =
		url: 'http://localhost:5000'
		api: 'http://localhost:5000'
		apiTest2: 'http://dev.svoy.ru'
		apiTest: 'http://private-39ce-svoy.apiary-mock.com'
		workerPort: 5000

exports.sessionCookieName = '__SVOY_SESSION__'
exports.anonymousCookieName = '__SVOY_LABEL__'