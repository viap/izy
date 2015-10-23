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

	#initRoutes expressApp

initExpress = ->
	express = require 'express'
	bodyParser = require 'body-parser'
	cookieParser = require 'cookie-parser'

	app = express()

	app.use cookieParser()
	app.use bodyParser()
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
		res.sendfile "#{appName}/templates/#{templateName}.ejs", {root: './apps'}

setupApiRoutes = (app) ->
	fs = require 'fs'

	#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ ALBUMS API REQUESTS @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	app.get '/api/music/albums/:id', (req, res) ->
		url = config.server.apiTest2 + "/music/albums/"+req.params.id
		url += '?' + _.map(req.query, (v,k)->k+'='+v).join '&'

		RequestManager.get url, (err, data) ->
			data = JSON.parse data if _.isString data
			res.json data

	app.get '/api/music/albums', (req, res) ->
		url = config.server.apiTest2 + "/music/albums"
		url += '?' + _.map(req.query, (v,k)->k+'='+v).join '&'

		RequestManager.get url, (err, data) ->
			data = JSON.parse data if _.isString data
			res.json data


	app.get '/api/music/songs', (req, res)->
		url = config.server.apiTest2 + "/music/songs?" + _.map(req.query, (v,k)->k+'='+v).join '&'

		RequestManager.get url, (err, data) ->
			data = JSON.parse data if _.isString data
			res.json data

	#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ TRACKS API REQUESTS @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	app.get '/api/music/tracks/:id', (req, res) ->
		url = config.server.apiTest2 + "/music/songs/" + req.params.id
		url += '?' + _.map(req.query, (v,k)->k+'='+v).join '&'

		RequestManager.get url, (err, data) ->
			data = JSON.parse data if _.isString data
			res.json data

	app.get '/api/music/songs/:id', (req, res) ->
		url = config.server.apiTest2 + "/music/songs/" + req.params.id
		url += '?' + _.map(req.query, (v,k)->k+'='+v).join '&'

		RequestManager.get url, (err, data) ->
			data = JSON.parse data if _.isString data
			res.json data

	app.get '/api/music/playlists/:id/items', (req, res) ->
		url = config.server.apiTest2 + "/music/playlists/"+req.params.id+"/items"
		url += '?' + _.map(req.query, (v,k)->k+'='+v).join '&'

		RequestManager.get url, (err, data) ->
			data = JSON.parse data if _.isString data
			res.json data

	app.post '/api/music/streams', (req, res) ->
		url = config.server.apiTest2 + "/music/streams"
		url += '?' + _.map(req.query, (v,k)->k+'='+v).join '&'

		RequestManager.post url, {form: req.body}, (err, data) ->
			if !err
				data = JSON.parse data if _.isString data
				res.json data
			else
				res.json {}

	#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ FEATURING @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	app.get '/api/featuring/', (req, res) ->
		url = config.server.apiTest2 + '/featurings'
		url += '?' + _.map(req.query, (v,k)->k+'='+v).join '&'

		RequestManager.get url, (err, data) ->
			data = JSON.parse data if _.isString data
			res.json data

	#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ COMMENTS API REQUESTS @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	app.get '/api/comments/get/:type/:id', (req, res) ->
		fs.readFile './api/'+req.params.type+'/commentList.json', {encoding: 'UTF-8'}, (err, data) ->
			data = JSON.parse data
			data.id = req.params.id
			res.json data

	#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ SIMILARS API REQUESTS @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	app.get '/api/similars/get/:type/:id', (req, res) ->
		fs.readFile './api/'+req.params.type+'/similars.json', {encoding: 'UTF-8'}, (err, data) ->
			data = JSON.parse data
			data.id = req.params.id
			res.json data

	#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ ARTISTS API REQUESTS @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	app.get '/api/music/artists', (req, res) ->
		url = config.server.apiTest2 + '/music/artists'
		url += '?' + _.map(req.query, (v,k)->k+'='+v).join '&'

		getParams = []
		_.each req.query, (value, name)->
			getParams.push name+"="+value
		url += '?' + getParams.join '&' if getParams.length

		RequestManager.get url, (err, data) ->
			data = JSON.parse data if _.isString data
			res.json data

	app.get '/api/music/artists/letters/', (req, res) ->
		url = config.server.apiTest2 + '/music/artists/letters'
		url += '?' + _.map(req.query, (v,k)->k+'='+v).join '&'

		RequestManager.get url, (err, data) ->
			data = JSON.parse data if _.isString data
			res.json data

	app.get '/api/music/artists/:id', (req, res) ->
		url = config.server.apiTest2 + "/music/artists/" + req.params.id
		url += '?' + _.map(req.query, (v,k)->k+'='+v).join '&'

		RequestManager.get url, (err, data) ->
			data = JSON.parse data if _.isString data
			res.json data

	###
	app.get '/api/artists/:id/albums', (req, res) ->
		url = config.server.apiTest + "/music/artists/"+req.params.id+'/albums'
		url += '?' + _.map(req.query, (v,k)->k+'='+v).join '&'

		RequestManager.get url, (err, data) ->
			data = JSON.parse data if _.isString data
			res.json data
	###

	app.get '/api/artists/:id/articles', (req, res) ->
		fs.readFile './api/artists/articleList.json', {encoding: 'UTF-8'}, (err, data) ->
			data = JSON.parse data
			res.json data

	#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ INTERVIEWS API REQUESTS @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

	app.get '/api/interviews', (req, res) ->
		fs.readFile './api/interviews/interviewsAll.json', {encoding: 'UTF-8'}, (err, data) ->
			data = JSON.parse data
			res.json data

	#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ TOPLIST API REQUESTS @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	app.get '/api/top/:type/artists/:id', (req, res) ->
		fs.readFile './api/top/'+req.params.type+'_artist_top.json', {encoding: 'UTF-8'}, (err, data) ->
			data = JSON.parse data
			data.id = req.params.id
			res.json data

	#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@PLAYLISTS API REQUESTS @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	app.get '/api/music/playlists' , (req, res)->
		url = config.server.apiTest2+"/music/playlists"
		url += '?' + _.map(req.query, (v,k)->k+'='+v).join '&'

		RequestManager.get url, (err, data) ->
			data = JSON.parse data if _.isString data
			res.json data

	app.post '/api/music/playlists' , (req, res)->
		url = config.server.apiTest2+"/music/playlists"
		url += '?' + _.map(req.query, (v,k)->k+'='+v).join '&'

		RequestManager.post url, {form: req.body} , (err, data) ->
			data = JSON.parse data if _.isString data
			res.json data

	app.delete '/api/music/playlists/:id' , (req, res)->
		url = config.server.apiTest2+"/music/playlists/"+req.params.id
		url += '?' + _.map(req.query, (v,k)->k+'='+v).join '&'

		RequestManager.del url, (err, data) ->
			#data = JSON.parse data if _.isString data
			if ! err
				data = { code: 0 } if ! data
				res.json data
			else
				res.json { err: err }

	app.get '/api/music/playlists/user_playlists' , (req, res)->
		fs.readFile './api/playlists/user_playlists.json', {encoding: 'UTF-8'}, (err, data) ->
			data = JSON.parse data
			res.json data

	app.get '/api/music/playlists/:id' , (req, res)->
		url = config.server.apiTest2+"/music/playlists/"+req.params.id
		url += '?' + _.map(req.query, (v,k)->k+'='+v).join '&'

		RequestManager.get url, (err, data) ->
			data = JSON.parse data if _.isString data
			res.json data

	app.get '/api/music/playlists/:id/items' , (req, res)->
		url = config.server.apiTest2+"/music/playlists/"+req.params.id+"/items"
		url += '?' + _.map(req.query, (v,k)->k+'='+v).join '&'

		RequestManager.get url, (err, data) ->
			data = JSON.parse data if _.isString data
			res.json data

	app.post '/api/music/playlists/:id/items' , (req, res)->
		url = config.server.apiTest2+"/music/playlists/"+req.params.id+"/items"
		url += '?' + _.map(req.query, (v,k)->k+'='+v).join '&'

		RequestManager.post url, { form: req.body }, (err, data)->
			data = JSON.parse data if _.isString data
			res.json data

	#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ MUSIC API REQUESTS @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	app.get '/api/music/contentItem/:id', (req, res) ->
		fs.readFile './api/music/contentItem.json', {encoding: 'UTF-8'}, (err, data) ->
			data = JSON.parse data
			data.id = req.params.id
			res.json data

	app.get '/api/music/contentList', (req, res) ->
		fs.readFile './api/music/contentList.json', {encoding: 'UTF-8'}, (err, data) ->
			data = JSON.parse data
			res.json data

	app.get '/api/music/genres', (req, res) ->
		url = config.server.apiTest2 + "/music/genres"
		url += '?' + _.map(req.query, (v,k)->k+'='+v).join '&'

		RequestManager.get url, (err, data) ->
			data = JSON.parse data if _.isString data
			res.json data

	app.get '/api/selections/:type/:category/:genre', (req, res) ->
		fs.readFile './api/selections/'+req.params.type+'_'+req.params.category+'.json', {encoding: 'UTF-8'}, (err, data) ->
			data = JSON.parse data
			res.json data

	app.get '/api/recommends', (req, res) ->
		fs.readFile './api/recommends/recommends.json', {encoding: 'UTF-8'}, (err, data) ->
			data = JSON.parse data
			res.json data

	app.get '/api/main/contentList', (req, res) ->
		fs.readFile './api/main/contentList.json', {encoding: 'UTF-8'}, (err, data) ->
			data = JSON.parse data
			res.json data

	#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ SEARCH API REQUESTS @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

	app.get '/api/search/:query', (req, res) ->
		url = config.server.apiTest2 + '/search/'+req.params.query+'/elements'
		url += '?' + _.map(req.query, (v,k)->k+'='+v).join '&'

		RequestManager.get url, (err, data) ->
			data = JSON.parse data if _.isString data
			res.json data

	app.get '/api/search/categories/:query', (req, res) ->
		RequestManager.get config.server.apiTest2 + '/search/'+req.params.query+'/categories', (err, data) ->
			data = JSON.parse data if _.isString data
			res.json data

	app.get '/api/search/types/:query', (req, res) ->
		url = config.server.apiTest2 + '/search/'+req.params.query+'/types'
		url += '?' + _.map(req.query, (v,k)->k+'='+v).join '&'

		RequestManager.get url, (err, data) ->
			data = JSON.parse data if _.isString data
			res.json data

	#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ USERS API REQUESTS @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	app.get '/api/users/me', (req, res) ->
		url = config.server.apiTest2 + '/users/me'
		url += '?' + _.map(req.query, (v,k)->k+'='+v).join '&'

		#console.log '################################ REQUEST ME=', req.query

		RequestManager.get url , (err, data) ->
			data = JSON.parse data if _.isString data
			res.json data

	app.post '/api/users/login', (req, res) ->
		RequestManager.post config.server.apiTest2 + '/users/login', {form: req.body} , (err, data) ->
			data = JSON.parse data if _.isString data
			res.json data

	#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ RELATIONS REQUESTS @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	#get user relation
	app.get '/api/:type/:id/relations', (req, res) ->
		url = config.server.apiTest2 + '/'+req.params.type+'/'+req.params.id+'/relations'
		url += '?' + _.map(req.query, (v,k)->k+'='+v).join '&'

		RequestManager.get  url, (err, data) ->
			if ! err
				data = JSON.parse data if _.isString data
				res.json data

	#set user relation
	app.post '/api/:type/:id/relations', (req, res) ->
		url = config.server.apiTest2 + '/'+req.params.type+'/'+req.params.id+'/relations'
		url += '?' + _.map(req.query, (v,k)->k+'='+v).join '&'

		RequestManager.post url, (err, data) ->
			if ! err
				data = JSON.parse data if _.isString data
				res.json data

	#delete user relation
	app.delete '/api/:type/:id/relations', (req, res) ->
		url = config.server.apiTest2 + '/'+req.params.type+'/'+req.params.id+'/relations'
		url += '?' + _.map(req.query, (v,k)->k+'='+v).join '&'

		RequestManager.del url, (err, data) ->
			if ! err
				if data && _.isString data
					data = JSON.parse data
				else
					data = {}
				res.json data

	#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ THE END @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

	#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ ALL API REQUESTS: start @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	# get requests
	app.get '/api/*' , (req, res)->
		url = config.server.apiTest2 + (/^\/api(\/.*)$/).exec( req.url )[1]
		url += '?' + _.map(req.query, (v,k)->k+'='+v).join '&'

		RequestManager.get url, (err, data) ->
			data = JSON.parse data if _.isString data
			res.json data

	# post requests
	app.post '/api/*' , (req, res)->
		url = config.server.apiTest2 + (/^\/api(\/.*)$/).exec( req.url )[1]
		url += '?' + _.map(req.query, (v,k)->k+'='+v).join '&'

		RequestManager.post url, {form: req.body} , (err, data) ->
			data = JSON.parse data if _.isString data
			res.json data

	# delete requests
	app.delete '/api/*', (req, res) ->
		url = config.server.apiTest2 + (/^\/api(\/.*)$/).exec( req.url )[1]
		url += '?' + _.map(req.query, (v,k)->k+'='+v).join '&'

		RequestManager.del url, (err, data) ->
			if ! err
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