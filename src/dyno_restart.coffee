lib = require './lib'

_ = require 'underscore'

do ->
	output = []

	to = 60000

	shell = do lib.heroku.list_dynos

	shell.stdout.setEncoding = 'utf8'
	shell.stderr.setEncoding = 'utf8'
	shell.stderr.pipe process.stderr

	shell.stdout.on 'data', (chunk) ->
		output.push chunk

	shell.stdout.on 'close', ->
		raw = (output.join '').split '==='

		do raw.shift #do away with empty string

		summary = _.extend.apply({}, ((ps) -> 
			tmp = {}
			titular = _.first (_.first ps).split ':'

			do ps.shift #do away with tagging/title

			tmp[(titular.split ' ')[1]] = _.compact ps.map (instance) ->
				worker = _.first instance.split ':'
				worker if worker.length > 0

			tmp) i.split '\n' for i in raw)

		restart_dyno = (i) ->
			setTimeout (-> 
				console.log 'RESTARTING %s', summary.web[i]
				restart = lib.heroku.restart_dyno summary.web[i]), to * i

		restart_dyno i for web, i in summary.web



		