(function() {
  var Amazon, aws, fs, q, request, s3, s3_stream, zlib, _;

  aws = require('aws-sdk');

  zlib = require('zlib');

  fs = require('fs');

  aws.config.update({
    region: 'us-east-1',
    accessKeyId: process.env["AWS_ACCESS_KEY_ID"],
    secretAccessKey: process.env["AWS_SECRET_ACCESS_KEY"]
  });

  s3 = new aws.S3();

  s3_stream = require('s3-upload-stream')(s3);

  q = require('q');

  _ = require('underscore');

  request = require('request');

  Amazon = function() {
    this.sdk = aws;
    this.object_exists = function(opts, next) {
      return s3.headObject(opts, next);
    };
    this.s3_upload_stream = function(opts) {
      var archive, deferred, upload;
      deferred = q.defer();
      archive = zlib[opts.Gunzip ? 'createGzip' : 'createGunzip']();
      upload = s3_stream.upload(_.pick(opts, 'Bucket', 'Key'));
      upload.on('error', function(e) {
        return deferred.reject(e);
      });
      upload.on('part', function(details) {
        return console.log(details);
      });
      upload.on('uploaded', function(fd) {
        return deferred.resolve(fd);
      });
      (opts.Stream || request.get({
        url: opts.URI
      })).pipe(archive).pipe(upload);
      return deferred.promise;
    };
  };

  module.exports = new Amazon();

}).call(this);
