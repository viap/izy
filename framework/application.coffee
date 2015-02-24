RendererFactory = require './renderer_factory'
Renderer = RendererFactory.getClass()
ModelManager = require './model_manager'
Event = require './event'
Router =  require './router'
Utils = require  './utils'
config = require '../config'

# class Application extends RendererFactory.create()
class Application extends Renderer

	# view for this module, contains layout and placeholders for submodules
	view: null

	# model with data for this module
	model: null

	# list of submodules to paste to placeholders
	submodules: {}
	meta: {}

	constructor: ( params ) ->
		@_prepareAttr 'meta', {}

		if _.isString params
			params = { region: params }
		else if ! _.isObject params
			params = {}

		if params.region
			@setRegion params.region

		console.log 'starting app ' + @getName()

		super params

	destroy: ()->

	init: (params)->
		@setViewContext params.context if params?.context
		@setRegion params.name if params?.name
		@setModelParams params.attributes if params?.attributes

		@bindEvents()

		# init collection models
		if Utils.isCollection( @model ) && @view.context && @view.context.size()
			idName = @model.modelType.idName
			region = @getRegion()
			@view.context.find("[data-region=\"#{region}_item\"][data-#{idName}]").each (indx, element) =>
				@model.addById $(element).attr('data-' + idName)

		_.each @submodules, (submodule, name)=>
			params = {}
			if @view.context
				params.context = @view.context.find "[data-region=\"#{name}\"]"
			params.name = name
			submodule.init params

	addSubmodule: (region, module) ->
		@_prepareAttr 'submodules'
		@submodules[region] = module
		module.setRegion region
		if config.isBrowser() and @view?.context?.size()
			module.setViewContext @view.context.find('[data-region="'+region+'"]')

		_.extend @meta, module.meta

		module
		#@model.set region, '[default_content]' if @model && @model.set

	setViewContext: (context) ->
		@view.context = context

	setModelParams: (params) ->
		@model.set params
		#_.each params, (val, key) =>
		#	@model.set key, val

	bindEvents: ->
		@view.bindEvents()

		# bind collection item events
		if Utils.isCollection @model
			idName = @model.modelType.idName
			region = @getRegion()
			if @view.context && @view.context.size()
				@view.context.find("[data-region=\"#{region}_item\"][data-#{idName}]").each (indx, element) =>
					#appending = @model.appending()
					#@model.appending false
					model = @model.addById $(element).attr "data-#{idName}"
					#@model.appending appending
					itemView = @view.get( model ) || @view.add model
					itemView.context = $(element)
					itemView.bindEvents()

	clear: ->
		for name, module of @submodules
			module.clear()

		@submodules = {}

	changeMeta: (meta)=>
		@meta = meta
		if config.isBrowser()
			Router.meta[@getName()] = meta

	reRender:( callback )->
		if config.isBrowser()
			#@prepare null, (err, data)=>
			@render null, (err, data)=>
				if err
					console.log '!!!!!!!!!! ERROR on reRender'
				if _.isFunction callback
					callback err, data

module.exports = Application
