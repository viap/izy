config = require '../config'
ClientRenderer = require './client_renderer'
ServerRenderer = require './node/server_renderer'

exports.create = () ->
	if config.isBrowser() == true
		return new ClientRenderer()
	else
		return new ServerRenderer()

exports.getClass = () ->
	if config.isBrowser() == true
		return ClientRenderer
	else
		return ServerRenderer
