Event = require './event'
Utils = require './utils'

class BaseRenderer extends Event
	# response context. may be jquery el on client or response object on server
	context: null
	model: null
	view: null
	subrenderers: {}

	# The name of the module
	#name: ''
	region: ''

	setRegion: (region) ->
		@region = region

	getRegion: () ->
		@region

	constructor: (context) ->
		@context = context
		#@setName @getName()
		#console.log 'init renderer'

	clearSubrenderers: () ->
		@subrenderers = {}

	addSubrenderer: (name, renderer) ->
		@subrenderers[name] = renderer

	clear: ->
		delete @model
		delete @view
		delete @subRenderers

	getErrorHtml:(e)->
		#"<!--Error in "+( @setRegion() || '' )+"["+( @getName() || '' )+"] message:\r\n "+( e && e.message || '' )+"-->"
		"<div style='border: 1px solid red'>"+ Utils.escapeHtml( " Error in "+( @setRegion() || '' )+"["+( @getName() || '' )+"] message:\r\n "+( e && e.message || '' ) )+"</div>"

	# prepareErrorResult: (err)->
	# 	@result = "Error: #{err}"

module.exports = BaseRenderer
