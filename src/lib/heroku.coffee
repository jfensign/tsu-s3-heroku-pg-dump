process = require 'child_process'

Heroku = ->

	@app = "tsu-production"#process.env["HEROKU_APP"] or "tsu-production"

	@get_snapshot_uri = (id) -> 
		process.spawn "heroku", [
			"pgbackups:url",
			"#{id or ''}"
			"-a", 
			@app
		]

	@list_snapshots = ->
		process.spawn "heroku", [
			"pgbackups",
			"-a",
			@app
		]

	@list_dynos = ->
		process.spawn "heroku", [
			"ps",
			"-a",
			@app
		]

	@restart_dyno = (dyno) ->
		process.spawn "heroku", [
			"restart",
			dyno,
			"-a",
			@app
		]

	return

module.exports = new Heroku