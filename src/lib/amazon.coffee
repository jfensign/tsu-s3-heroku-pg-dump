aws = require 'aws-sdk'

zlib = require 'zlib'

fs = require 'fs'

aws.config.update {
	region: 'us-east-1', 
	accessKeyId: process.env["AWS_ACCESS_KEY_ID"], 
	secretAccessKey: process.env["AWS_SECRET_ACCESS_KEY"]
}

s3 = new aws.S3()

s3_stream = require('s3-upload-stream')(s3)

q = require 'q'

_ = require 'underscore'

request = require 'request'

Amazon = ->
	@sdk = aws

	@object_exists = (opts, next) ->
		s3.headObject opts, next

	@s3_upload_stream = (opts) ->
		deferred = do q.defer

		archive = do zlib.createGzip

		upload = s3_stream.upload _.pick opts, 'Bucket', 'Key'

		#upload.maxPartSize opts.maxPartSize or 20971520

		#upload.concurrentParts opts.concurrentParts or 25

		upload.on 'error', (e) ->
			deferred.reject e

		upload.on 'part', (details) ->
			console.log details

		upload.on 'uploaded', (fd) ->
			deferred.resolve fd

		(opts.Stream or request.get {url: opts.URI}).pipe(archive).pipe upload

		deferred.promise

	return

module.exports = new Amazon