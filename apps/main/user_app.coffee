Application = require '../../framework/application'
ModelManager = require  '../../framework/model_manager'

UserView = require './views/user_view'
UserModel = require './models/user_model'

CommonInit = require  '../../common_init'

ModelManager = require '../../framework/model_manager'
RequestManager = require '../../framework/request_manager'
Config = require '../../config'
Sync = require '../../framework/sync'
Event = require '../../framework/event'
Utils = require '../../framework/utils'

class UserApp extends Application
	constructor: (params)->

		@model = ModelManager.getModel UserModel, params
		@view = new UserView()

		#example of using submodules
		#SubModuleName = CommonInit.getModule('SubModuleName')
		#@addSubmodule 'submodule_region', new SubModuleName()

		super params

	isAuthorized: ()->
		!! @model.currentUser

	initUser: ( session, anonymous, cb )->
		cb = ( ()-> ) if ! _.isFunction cb
		if token = session || $?.cookies?.get( Config.sessionCookieName )
			@authBySession token, cb
		else
			@initAnonymousUser anonymous
			cb()

	login: (email, password, cb)->
		if Config.isBrowser()
			url = @model.urlLogin
			cb = ( ()->@ ) if ! _.isFunction cb
			callback = ( err, data )=>
				if ! err && data?.id && data?.session
					@model.currentUser = ModelManager.getModel UserModel, data
					@initCurrentUser data.session
					Event::trigger 'user:login', @model.currentUser
					cb null, @model.currentUser
				else
					cb err, null
			if url
				Sync.request 'create', null, { url: url, emulateJSON: true, data:{email: email, password: password }, callback: callback }
			else
				cb {msg: 'url is undefined'}, null

	logout:( cb )->
		if Config.isBrowser()
			cb = ( ()->@ ) if ! _.isFunction cb
			@initAnonymousUser()
			Event::trigger 'user:logout'
			cb null, null

	authBySession: ( token, cb )->
		#if( session )

			url = Config.server.api + @model.urlInfo
			cb = ( ()->@ ) if ! _.isFunction cb

			RequestManager.setDefaultData session: token if token

			callback = ( err, data )=>
				if ! err && data
					data = JSON.parse data if _.isString data
					@model.currentUser = ModelManager.getModel UserModel, data
					@initCurrentUser data.session
					Event::trigger 'user:auth_by_session', @model.currentUser
					cb null, @model.currentUser
				else
					@initAnonymousUser()
					cb err, null

			if ! @model.currentUser
				if url
					Sync.request 'read', null, { url: url, callback: callback }
				else
					cb {msg: 'url is undefined'}, null
			else
				cb null, @model.currentUser
		#else
		#	cb {msg: 'session is undefined'}, null

	getCurrentUser: ()->
		@model.currentUser

	initCurrentUser: ( session )->
		if token = session || $?.cookies?.get( config.sessionCookieName )
			$.cookies.set Config.sessionCookieName, token if Config.isBrowser()
			RequestManager.setDefaultData session: token
			@deleteAnonymousUser()

	initAnonymousUser: ( anonymous )->
		if token = anonymous || $?.cookies?.get( Config.anonymousCookieName ) || @generateAnonymousId()
			$.cookies.set Config.anonymousCookieName, token if Config.isBrowser()
			RequestManager.setDefaultData anonymous: token
			@deleteCurrentUser()

	deleteCurrentUser: ()->
		$.cookies.set Config.sessionCookieName if Config.isBrowser()
		@model.currentUser = null
		RequestManager.deleteDefaultData 'session'

	deleteAnonymousUser: ()->
		$.cookies.set Config.anonymousCookieName if Config.isBrowser()
		RequestManager.deleteDefaultData 'anonymous'

	generateAnonymousId: ()->
		Utils.uniqid Date.now()+'.', true

module.exports = UserApp