process = require 'child_process'

q = require 'q'

PgBackups = ->

	generic_routine = (fn, id) ->
		list = if id then fn id else do fn

		capture_list = []

		deferred = do q.defer

		list.stdout.setEncoding 'utf8'
		list.stderr.setEncoding 'utf8'

		list.stdout.on 'data', (chunk) ->
			capture_list.push chunk

		list.stderr.on 'data', (e) ->
			uri.stderr.pipe process.stderr
			deferred.reject e

		list.stderr.on 'close', ->
			deferred.resolve capture_list.join ""

		deferred.promise

	get_snapshot_uri = (id) -> 
		process.spawn "heroku", [
			"pgbackups:url",
			"#{id or ''}"
			"-a", 
			"tsu-production"
		]

	list_snapshots = ->
		process.spawn "heroku", [
			"pgbackups",
			"-a",
			"tsu-production"
		]

	@list = -> generic_routine list_snapshots

	@uri = (id) -> generic_routine get_snapshot_uri, id

	return

module.exports = new PgBackups()