ejs = require 'ejs'
async = require 'async'

Event = require './event'
Utils = require './utils'
config = require '../config'
BaseRenderer = require './base_renderer'
TemplateManager = require './template_manager'

# template includes begin
includes =
	Utils: Utils
# template includes end

class ClientRenderer extends BaseRenderer

	# should be overriden in derived class
	submodules: {}

	# should be overriden in derived class
	model: null
	view: null

	prepare: (regionsData, callback) ->
		@_collectData (e, d) =>
			d.regionsData = regionsData || {}
			@_prepareCurrent d, (err, data) =>

				if err
					console.log err
					@view.show {}, err
				else
					@view.show {}, data
					@bindEvents()

				@_prepareChild callback

	_prepareChild: (callback) ->
		tasks = {}

		_.each @submodules, (module,region) =>
			module.setViewContext @view.context.find "[data-region=\"#{region}\"]"
			tasks[region] = _.bind @prepare, module, null

		async.parallel tasks, callback

	_collectData: (callback) ->
		tasks = {}

		if _.isEmpty(@model) == false
			# function to fetch model
			tasks.model = _.bind(@model.fetch, @model)
			# tasks.push @model.fetch

		if _.isEmpty(@submodules) == false
			# tasks to prepare submodules
			subTasks = {}

			_.each @submodules, (module, region)->
				subTasks[region] = _.bind module.getEmptyHtml, module, region

			# function to prepare all submodules in parallel
			tasks.submodules = (cb) ->
				async.parallel subTasks, cb

		async.series tasks, callback

	_prepareCurrent: (data, callback) ->
		#console.log 'Prepare current'
		# prepare current after all subrendering done
		templateName = @view.templateName

		TemplateManager.getTemplate templateName, (err, template) =>
			if err
				callback err, null
				return

			options = {} #filename: templateName

			if Utils.isCollection @model

				showParams = region: @getRegion(), type: @getName()

				tasksCollection = {}
				_.each @model.getListForRender(), (itemModel, iterator)=>
					itemView = @view.get( itemModel ) || @view.add itemModel
					itemRenderer = new ClientRenderer()
					itemRenderer.view = itemView
					itemRenderer.model = itemModel
					itemRenderer.setRegion showParams.region + '_item'
					tasksCollection[ iterator ] = (cb)=>
						itemRenderer._prepareCurrent { model: itemModel, isCollectionItem: true, collectionItemType: showParams.type + '_item', collectionItemRegion: showParams.region + '_item'}, cb

				async.parallel tasksCollection, (err, collection_data) =>
					if err
						console.log 'ERROR'
						console.log err
						return

					# listContent - collection html
					listContent = ''
					_.each collection_data, (elementHTML)->
						listContent += elementHTML

					# data.model - fetched model
					# data.submodules - submodules html
					_.extend options, data.model, data.submodules, data.regionsData , { moduleName: @getName(), moduleRegion: @getRegion(), listContent: listContent, model: data.model }

					try
						html = template options
					catch e
						html = @getErrorHtml e, options
						showParams.error = true

					result = Utils.insertDataAttrs html, showParams

					#console.log 'Success collection rendering: ' + @getRegion()

					callback null, result
			else
				showParams = {}
				if @model.getIdName()
					showParams.idName = @model.getIdName()
					showParams[@model.getIdName()]  = @model.getId()
				if data.isCollectionItem
					showParams.type = data.collectionItemType if data.collectionItemType
					showParams.region = data.collectionItemRegion if data.collectionItemRegion
				else
					showParams.type = @getName()
					showParams.region = @getRegion()

				# data.model - fetched model
				# data.submodules - submodules html
				attributes = data?.model?.getAttributes?()
				_.extend options, attributes, data.submodules, data.regionsData, {moduleName: @getName(), moduleRegion: @getRegion()}, includes

				try
					html = template options
				catch e
					html = @getErrorHtml e, options
					showParams.error = true

				result = Utils.insertDataAttrs html, showParams

				#console.log 'Success module rendering: ' + @getRegion()

				callback null, result

	# gets HTML to paste to view (module) placeholder.
	# Parameter name required to have access to this tag via jquery in future
	# to replace it with non-empty view
	getEmptyHtml: (region, callback) ->
		templateName = @view.emptyTemplateName
		TemplateManager.getTemplate templateName, (err, template) =>
			if err
				callback err
				return

			showParams = region: region, type: @getName()
			if Utils.isModel(@model) && @model.getIdName()
				showParams.idName = @model.getIdName()
				showParams[@model.getIdName()] = @model.getId()

			result = Utils.insertDataAttrs template(), showParams
			callback null, result

	render: (params, callback) ->
		# TODO: use series or invoke to make it easy to read
		@getEmptyHtml @view.context.data('region'), (err, data) =>

			if err
				callback err, null if callback
				@view.show null, err
				return

			@view.show null, data

			@prepare params, (err, result) =>
				callback null, result if callback

module.exports = ClientRenderer

