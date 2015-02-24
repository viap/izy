Model = require '../../../framework/model'

class UserModel extends Model
	urlRoot: '/api/users/me'

	@idName: 'id'
	urlInfo: '/api/users/me'
	urlLogin: '/api/users/login'

	currentUser: null

	constructor: ( params )->
		@_idToUrl = false
		super params

module.exports = UserModel