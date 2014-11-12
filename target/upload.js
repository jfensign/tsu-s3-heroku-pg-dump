(function() {
  var filename, filesource, fs, lib, request, zlib, _;

  lib = require('./lib');

  request = require('request');

  zlib = require('zlib');

  fs = require('fs');

  _ = require('underscore');

  filesource = process.env["SRC_URL"] || "https://s3.amazonaws.com/tsu-notifications-production-backup/bk20141111-195743-7621808-tsu-notifications-new-prod-db-1_of_1-30246-1-4096.rdb.gz";

  filename = _.last(filesource.split("/")).split(".");

  (function() {
    var upload, upload_error, upload_success;
    filename.pop();
    console.log(lib.config.s3.bucket.redis.notifications);
    upload = lib.aws.s3_upload_stream({
      Gunzip: true,
      Stream: request.get({
        url: filesource
      }),
      Bucket: lib.config.s3.bucket.redis.notifications,
      Key: filename.join('.'),
      PartCB: function(part) {
        return console.log(part);
      }
    });
    upload_success = function(fd) {
      console.log("Success");
      return console.log(fd);
    };
    upload_error = function(e) {
      console.error("Error");
      return console.error(e);
    };
    return upload.then(upload_success, upload_error);
  })();

}).call(this);
