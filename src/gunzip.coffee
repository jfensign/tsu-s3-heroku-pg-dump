zlib = require 'zlib'

_ = require 'underscore'

fs = require 'fs'

request = require 'request'

do ->
	request_opts =
		url: process.env["ARCHIVE_URI"] or "https://s3.amazonaws.com/tsu-notifications-production-backup/bk20141111-195743-7621808-tsu-notifications-new-prod-db-1_of_1-30246-1-4096.rdb.gz"

	stream = request request_opts

	gunzip = do zlib.createGunzip

	gunzip.on 'open', ->
		console.log '%s', 'gunzip started'

	gunzip.on 'close', ->
		console.log '%s', 'GZ Extracted'

	writer = fs.createWriteStream do ->
    	tmp = _.last(request_opts.url.split '/').split '.'
    	do tmp.pop
    	tmp.join '.'

    writer.on 'data', (chunk) ->
    	console.log chunk

    writer.on 'error', (e) ->
    	console.error e

    writer.on 'close', ->
    	console.log 'done'

	(stream.pipe gunzip).pipe writer