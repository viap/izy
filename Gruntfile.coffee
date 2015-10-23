module.exports = (grunt) ->
	grunt.initConfig
		express:
			options:
				background: true
				output: 'Server listening on port.*'
				port: 5000
			dev:
				options:
					script: 'app.js'
			prod:
				options:
					script: 'app.js'
					node_env: 'production'

		browserify:
			dist:
				files:
					'build/app.js': ['app.js']
				options:
					browserifyOptions:
						debug: true
						extensions: ['.coffee']
					transform: ['coffeeify']
					ignore: ['framework/node/*.coffee', 'node_init.coffee', 'node_modules/coffee-script/register.js', 'node_modules/moment/moment.js']

		watch:
			options:
				spawn: false
				livereload: true
			src:
				# files: ['**/*']
				files: ['apps/**/*.coffee', 'apps/**/*.ejs', 'framework/**/*.coffee', 'app.js', '*.coffee', 'assets/css/less/*.less', 'js_modules/*.js', 'assets/css/main.css', 'assets/css/sass/*.sass', 'assets/img/*']
				tasks: ['restart']
				
		less:
			dev:
				options:
					paths: ["assets/css"] # for @import command
				files:
					"assets/css/main.css": "assets/css/less/main.less"
			prod:
				options:
					paths: ["assets/css"]  # for @import command
					cleancss: true
					modifyVars:
						bgColor: 'red'
				files:
					"assets/css/main.css": "assets/css/less/main.less"

	grunt.loadNpmTasks 'grunt-contrib-watch'
	grunt.loadNpmTasks 'grunt-express-server'
	grunt.loadNpmTasks 'grunt-browserify'
	grunt.loadNpmTasks 'grunt-contrib-less'

	grunt.registerTask 'build', ['browserify']
	grunt.registerTask 'restart', ['browserify', 'express:dev', 'less']
	grunt.registerTask 'default', ['browserify', 'express:dev', 'watch', 'less']
