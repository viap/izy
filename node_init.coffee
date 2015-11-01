config = require './config'
commonInit = require './common_init'
async = require 'async'
RequestManager = require './framework/request_manager'
Utils = require './framework/utils'
ServerRequest = require './framework/node/server_request'
ServerController = require './framework/node/server_controller'
User = null

exports.init = ->
	global._ = require 'underscore'

	expressApp = initExpress()

	initRoutes expressApp

	setSession expressApp

	commonInit.init expressApp

initExpress = ->
	express = require 'express'
	bodyParser = require 'body-parser'
	cookieParser = require 'cookie-parser'
	
	app = express()
	
	app.use cookieParser()
	app.use bodyParser.urlencoded extended: true
	app.use bodyParser.json()

	app.use '/build', express.static(__dirname + '/build')
	app.use '/img', express.static(__dirname + '/assets' + '/img')
	app.use '/assets', express.static(__dirname + '/assets')
	app.use '/js', express.static(__dirname + '/assets' + '/js')
	app.use '/css', express.static(__dirname + '/assets' + '/css')
	app.use '/framework/browser', express.static(__dirname + '/framework/browser')
	app.use '/favicon.(ico|png)', (req, res)-> res.redirect '/img'+req.baseUrl

	app.use (err, req, res, next) ->
		console.log 'ERROR:'
		console.log err

	# Error uncatched handler
	process.on 'uncaughtException', (err)->
		console.log err

	server = app.listen config.server.workerPort
	console.log "Server listening on port %d in %s mode", config.server.workerPort, config.env

	app

setSession = ( app )->
	app.use (req, res, next) =>
		UserApp = commonInit.getModule 'UserApp'
		User = new UserApp() if ! User

		session = req.cookies[config.sessionCookieName] || req.query.session
		anonymous = req.cookies[config.anonymousCookieName] || req.query.anonymous
		User.initUser session, anonymous, ()=>
			#console.log '=====USER LOADED: '+User.isAuthorized()+'/'+session+'/'+anonymous, User.getCurrentUser()
			next.apply @, arguments
		#next()

initRoutes = (app) ->
	setupServerRoutes app
	setupTemplateRoutes app
	setupApiRoutes app

setupServerRoutes = (app)->
	app.get '/server/:action', (req, res) ->
		serverCallback = (data)=> res.json data

		action = req.params.action
		query = req.query
		if ServerController && ServerController[action]
			ServerController[action] query, serverCallback
		else
			res.json null

setupTemplateRoutes = (app) ->
	app.get '/apps/:app/templates/:template', (req, res) ->
		appName = req.params.app
		templateName = req.params.template
		console.log "#{appName}/templates/#{templateName}.ejs"
		res.sendFile "#{appName}/templates/#{templateName}.ejs", {root: './apps'}

setupApiRoutes = (app) ->
	fs = require 'fs'

	#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ ALL API REQUESTS: start @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	# get requests
	app.get '/api/*' , (req, res)->
		url = config.server.api + (/^\/api(\/.*)$/).exec( req.url )[1]
		url += '?' + _.map(req.query, (v,k)->k+'='+v).join '&'

		RequestManager.get url, (err, data) ->
			if data && _.isString data
				data = JSON.parse data
			else
				data = {}
			res.json data

	# post requests
	app.post '/api/*' , (req, res)->
		url = config.server.api + (/^\/api(\/.*)$/).exec( req.url )[1]
		url += '?' + _.map(req.query, (v,k)->k+'='+v).join '&'

		RequestManager.post url, {form: req.body} , (err, data) ->
			if data && _.isString data
				data = JSON.parse data
			else
				data = {}
			res.json data

	# delete requests
	app.delete '/api/*', (req, res) ->
		url = config.server.api + (/^\/api(\/.*)$/).exec( req.url )[1]
		url += '?' + _.map(req.query, (v,k)->k+'='+v).join '&'

		RequestManager.del url, (err, data) ->
			if data && _.isString data
				data = JSON.parse data
			else
				data = {}
			res.json data

	# put requests

	# patch requests

	#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ ALL API REQUESTS: end @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@