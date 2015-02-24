request = require 'request'

class ServerRequest
	## ============ STATIC ============ ##
	@instance: null
	# static method for singleton
	@getInstance: ()->
		if ! @instance
			@instance = new ServerRequest();
		@instance;
	## ============ STATIC ============ ##

	_defaultParams: null
	_defaultData: null
	_defaultToUrl: true

	constructor: ()->
		@_defaultParams = {}
		@_defaultData = {}
		@_defaultToUrl = true

	ajax: ( url, options, callback ) ->
		params = ServerRequest._initParams url, options, callback
		ServerRequest._ajax @_insertDefault params

	get: (url, options, callback) ->
		params = ServerRequest._initParams url, options, callback
		params.options.method = 'GET'
		ServerRequest._ajax @_insertDefault params

	post: (url, options, callback) ->
		params = ServerRequest._initParams url, options, callback
		params.options.method = 'POST'
		ServerRequest._ajax @_insertDefault params

	del: (url, options, callback) ->
		params = ServerRequest._initParams url, options, callback
		params.options.method = 'DELETE'
		ServerRequest._ajax @_insertDefault params

	put: (url, options, callback) ->
		params = ServerRequest._initParams url, options, callback
		params.options.method = 'PUT'
		ServerRequest._ajax @_insertDefault params

	patch: (url, options, callback) ->
		params = ServerRequest._initParams url, options, callback
		params.options.method = 'PATCH'
		ServerRequest._ajax @_insertDefault params

	_insertDefault: ( params )->
		if @_defaultToUrl
			if params.uri.indexOf('?') >= 0
				params.uri += '&'
			else
				params.uri += '?'
			params.uri += _.map(@_defaultData, (v,k)-> k+'='+v ).join '&'

			params = _.extend( {}, @_defaultParams, params)
		else
			params = _.extend( {}, @_defaultParams, {json: @_defaultData}, params)

	@_ajax: ( params )->
		request params.uri || null, params.options, params.callback

	@_initParams: (url, options, callback)=>

		if _.isString url
			if _.isFunction options
				callback = options
				options = {}
		else if _.isObject url
			if _.isFunction options
				callback = options
			options = url
			url = options.url || options.uri || ''
			callback = options.callback if _.isFunction options.callback
			delete options.url if url
			delete options.uri if url
			delete options.callback if _.isFunction options.callback
		else
			throw new Error 'Invalid parameters'

		params = request.initParams(url, options, callback)
		if params && _.isFunction params.callback
			callback = params.callback
			params.callback = (err, resp, data) ->
				callback err, data

		params

module.exports = ServerRequest.getInstance()