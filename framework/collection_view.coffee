config = require '../config'
View = require './view'
Utils = require './utils'
ClientRenderer = require './client_renderer'

class CollectionView extends View

	itemViewType: null

	# private attributes
	_list = null # elements list
	_byId = null

	constructor: (params)->
		@_prepareAttr '_list', []
		@_prepareAttr '_byId', {}

		if params && params.model && Utils.isCollection params.model
			@reListenTo params.model, 'model_appended', @renderElement
			@on 'append_element', @appendElement, @ if _.isFunction @appendElement

		super params

	destroy: ()->

	#show: ->

	add: ( model )->
		if Utils.isModel( model ) || Utils.isCollection( model )
			itemView = new @itemViewType model: model
			@_list.push itemView
			@_byId[ model.getName()+"_"+model.getId() ] = itemView
			itemView
		else
			false

	get: ( model )-> @_byId[ model.getName()+"_"+model.getId() ]
	has: ( model )-> !! @_byId[ model.getName()+"_"+model.getId() ]
	at: ( index )-> @_list[ index ]

	bindEvent2: ()->
		if @model && @context
			idName = @model.modelType.idName
			region = @context.attr 'data-region' #@getRegion()
			@context.find("[data-region=\"#{region}_item\"][data-#{idName}]").each (indx, element) =>
				model = @model.addById $(element).attr "data-#{idName}"
				itemView = @get( model ) || @add model
				itemView.context = $(element)
				itemView.bindEvents()

	renderElement: ( model, collection )->

		args = arguments
		if config.isBrowser()
			type = @context.attr 'data-type'
			region = @context.attr 'data-region'
			#itemView = new @itemViewType model: model
			itemView = @add model
			itemRenderer = new ClientRenderer()
			itemRenderer.view = itemView
			itemRenderer.model = model
			itemRenderer._prepareCurrent {model: model, isCollectionItem: true, collectionItemType: type+'_item', collectionItemRegion: region+'_item'}, (err, data)=>
				@trigger 'append_element', data, model, itemView, collection

	appendElement:(data, model, collection)-> @

module.exports = CollectionView