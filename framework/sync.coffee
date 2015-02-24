RequestManager = require './request_manager'

class Sync

	@emulateHTTP: true
	@emulateJSON: false #true
	@methodMap:
		'create': 'POST'
		'update': 'PUT'
		'patch':  'PATCH'
		'delete': 'DELETE'
		'read':   'GET'

	#@noXhrPatch = !_.isUndefined( window ) && !! window.ActiveXObject && !( window.XMLHttpRequest && ( new XMLHttpRequest ).dispatchEvent )

	@urlError: ()->
		throw new Error 'Not specified url for sync'

	@ajax: ()->
		RequestManager.ajax.apply RequestManager , arguments

	@request: ( method, model, options )->
		_.defaults options || (options = {}), { emulateHTTP: Sync.emulateHTTP, emulateJSON: Sync.emulateJSON }

		type = Sync.methodMap[method]
		params = { type: type, dataType: 'json' }

		if ! options.url
			params.url = model && model.getUrl && model.getUrl( {method: method} ) || Sync.urlError()

		if _.isEmpty( options.data ) && model && (method == 'create' || method == 'update' || method == 'patch')
			params.contentType = 'application/json'
			params.data = JSON.stringify options.attrs || model.toJSON(options)

		if options.emulateJSON || ! _.isEmpty( options.data )
			options.emulateJSON = true if ! options.emulateJSON
			params.contentType = 'application/x-www-form-urlencoded'
			params.data = if params.data then {model: params.data} else {}

		if options.emulateHTTP && (type == 'PUT' || type == 'DELETE' || type == 'PATCH')
			params.type = 'POST'
			params.data._method = type if options.emulateJSON
			beforeSend = options.beforeSend
			options.beforeSend = (xhr)->
				xhr.setRequestHeader 'X-HTTP-Method-Override', type
				if beforeSend
					return beforeSend.apply this, arguments

		if params.type != 'GET' && !options.emulateJSON
			params.processData = false;

		###
		if params.type == 'PATCH' && noXhrPatch
			params.xhr = ()->
				return new ActiveXObject "Microsoft.XMLHTTP"
		###

		callback = options.callback
		delete options.callback

		xhr = options.xhr = Sync.ajax _.extend(params, options), callback

		model.trigger 'request', model, xhr, options if model?.trigger

		xhr

	#@localStorage: ()->


module.exports = Sync
