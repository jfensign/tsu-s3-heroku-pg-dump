#!/usr/bin/node

lib = require './lib'

request = require 'request'

zlib = require 'zlib'

fs = require 'fs'

_ = require 'underscore'

skip = (backup_id) ->
	console.log "%s %s", "Already Exists", backup_id

create_backup = (uri, opts) ->
	console.log "%s %s", "Backup Up", opts.Key
	upload = lib.aws.s3_upload_stream _.extend opts,
		Stream: request.get({url: uri})
		PartCB: (part) ->
			console.log part

	upload_success = (fd) ->
		console.log "Success"
		console.log fd

	upload_error = (e) ->
		console.error e
		process.exit 1

	upload.then upload_success, upload_error

with_pg_backup_uri = (uri) ->
	opts = 
		Bucket: lib.config.s3.bucket.name,
		Key: uri.split("/").pop().split(".")[0]

	lib.aws.object_exists opts, (e, d) ->
		if e then create_backup uri, opts else skip opts.Key

missing_pg_backup_uri = (e) -> 
	console.error e

(do lib.pgbackups.list).then (list) -> 
	((i)-> 
		(lib.pgbackups.uri i).then with_pg_backup_uri, missing_pg_backup_uri) i for i in _.compact (list.split '\n').map (row, i) -> _.first row.split '  ' if i > 1 and i < list.length - 1
	

#(do lib.pgbackups.uri).then success, failure #request.get({url: uri}).pipe process.stdout