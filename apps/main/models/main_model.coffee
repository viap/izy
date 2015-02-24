Model = require '../../../framework/model'



class MainModel extends Model
	urlRoot: null

	fetch: (callback) ->
		callback null, @

module.exports = MainModel