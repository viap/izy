Event = require './event'
config = require '../config'
RequestManager = require './request_manager'
ModelManager = require  './model_manager'
Model = require  './model'
Utils = require  './utils'
Sync = require  './sync'

class Collection extends Event

	name: null
	urlRoot: null
	modelType: Model
	queryData: {}

	# private attributes
	_list = null # elements list
	_byId = null
	_loaded = false
	_loading = false
	_appending = false
	_nameToUrl = true

	constructor: ( params ) ->
		@_prepareAttr '_list', []
		@_prepareAttr '_byId', {}
		@_prepareAttr 'queryData'

		@name = ''

		if _.isString params
			params = {name: params}
		else if ! _.isObject params
			params = {}

		@urlRoot = Utils.pasteParamsToString(@urlRoot, params)
		@name = params.name if params.name

		if params.list
			@setList params.list
			@loaded true

		if params && params.queryData
			@queryData = _.clone params.queryData

	destroy: ()->

	fetch: ( params ) ->
		# handle (callback) and ({callback, options}) params style
		method = 'read'
		if _.isFunction params
			callback = params
		else if _.isObject params
			callback = params?.callback || ()->
			options = params?.options || {}
			extData = params?.data || {}
			method = params?.method || options?.method || method
			@loaded params._appending if params.appending

		options = {} if ! options
		url = @getUrl data: extData, method: method
		if !@loaded() && url && ! @loading()
			console.log 'fetching collection: ' + url
			@beforeFetch()
			@loading true

			#RequestManager.get url, options, (err, data) =>
			success = (err, data) =>
				if err
					callback err
					return

				data = @parse data
				@setList data

				# changing statuses
				@loaded true
				@loading false

				@trigger 'fetch_success'

				# call function after success fetching
				@afterFetch data

				if typeof callback == 'function'
					callback null, @

			@sync method, @, _.extend( options, {url: url, callback: success} )
		else
			if typeof callback == 'function'
				callback null, @

	getUrl: (params)->

		urlPath = ''
		url = ''
		mathod = params?.method || ''
		switch( mathod )
			when 'create' then urlPath = @urlCreate || @urlRoot
			when 'update' then urlPath = @urlUpdate || @urlRoot
			when 'patch' then  urlPath = @urlPatch || @urlRoot
			when 'delete' then urlPath = @urlDelete || @urlRoot
			else urlPath = @urlRoot

		if urlPath
			getParams = []
			getParams = _.map _.extend({}, @queryData, params.data), (value, name)-> return name+'='+encodeURIComponent(value)

			url = config.server.api + urlPath + '/' + if @_nameToUrl != false and @name then @name else ''
			url += '?' + getParams.join '&' if getParams.length

		url

	parse: (data, options)->
		data = JSON.parse(data) if _.isString data
		data

	stringify: ()->
		JSON.stringify @getList()

	beforeFetch:()->
	afterFetch:(data)->

	# getters / setters : start
	appending: (value)->
		value = @_appending if _.isUndefined value
		@_appending = !! value

	loaded:( value )->
		value = @_loaded if _.isUndefined value
		@_loaded = !! value

	loading: (value)->
		value = @_loading if _.isUndefined value
		@_loading = !! value

	# getters / setters : end

	getList: ()-> @_list
	getCount: ()-> @_list.length
	getListForRender: ()->
		list = []
		_.each @_list, ( item )=>
			if @filterForRender item
				list.push item
		list
	getCountForRender: ()->
		count = 0
		_.each @_list, ( item )=>
			if @filterForRender item
				count++
		count
	filterForRender:( )-> true

	get: (id)-> @_byId[id]
	has: (id)-> !! @_byId[id]
	at: (index)-> @_list[index]
	findFirst: ( properties )->
		result = false
		_.each @_list, ( model )=>
			if _.findWhere( [model._attributes], properties )
				result = model
				return false
		return result

	findByAttr: (attr, value)->
		return _.filter @getList(), (element)->
					return element.get(attr) == value

	indexOf: (id)-> _.find @_list, (element)=> element.getId() == id
	toJSON: (options)->
		_.map @_list, (model)-> model.toJSON(options)

	sync: ()->
		Sync.request.apply @, arguments

	setList: (list, options)->
		options = {} if ! options
		@clear() if ! @appending()

		list = [list] if ! _.isArray list
		_.each list, (element)=>
			id = element[@modelType.idName]
			if ! (_.isUndefined(id) || _.isNull(id))
				model = ModelManager.getModel @modelType, element
				@add model

		@loaded true if @getCount()

	add: (model)->
		if model instanceof Model || model instanceof Collection
			if ! @get model.getId()
				@_list.push(model)
				@_byId[model.getId()] = model
				if @appending()
					@trigger 'model_appended', model, @
				return model
		false

	addById: ( id )->
		model = @get id
		if ! model
			params = {}
			params[@modelType.idName] = id
			model = ModelManager.getModel @modelType, params
			@add model
		else
			model

	remove: (id)->
		index = @indexOf id
		delete @_byId[id]
		@_list.splice index, 1

	clear: ()->
		@_list = []
		@_byId = {}
		@loaded false

	save: ( elements, options )->
		list = @_list

		if ! _.isArray( elements ) && _.isObject( elements )
			options = elements
			elements = []

		options = _.extend {validate: true}, options

		if elements.length && ! options.wait
			if ! @setList elements, options
				return false

		callback = options.callback

		options.callback = (err, resp)=>

			if _.isArray(resp) && ! @setList( resp, options )
				return false

			if _.isFunction callback
				callback err, resp #@, resp, options

			@trigger 'sync', @, options, err, resp

		#wrapError @, options

		method = if options.patch then 'patch' else 'update' # if @isNew() then 'create' else ( if options.patch then 'patch' else 'update' )
		options.attrs = elements if method == 'patch'

		xhr = @sync method, @, options

		#if elements.length && options.wait
		#	@setList list

		xhr

module.exports = Collection
