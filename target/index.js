(function() {
  var create_backup, fs, lib, missing_pg_backup_uri, request, skip, with_pg_backup_uri, zlib, _;

  lib = require('./lib');

  request = require('request');

  zlib = require('zlib');

  fs = require('fs');

  _ = require('underscore');

  skip = function(backup_id) {
    return console.log("%s %s", "Already Exists", backup_id);
  };

  create_backup = function(uri, opts) {
    var upload, upload_error, upload_success;
    console.log("%s %s", "Backup Up", opts.Key);
    upload = lib.aws.s3_upload_stream(_.extend(opts, {
      Stream: request.get({
        url: uri
      }),
      PartCB: function(part) {
        return console.log(part);
      }
    }));
    upload_success = function(fd) {
      console.log("Success");
      return console.log(fd);
    };
    upload_error = function(e) {
      console.error(e);
      return process.exit(1);
    };
    return upload.then(upload_success, upload_error);
  };

  with_pg_backup_uri = function(uri) {
    var opts;
    opts = {
      Bucket: lib.config.s3.bucket.pg.name,
      Key: uri.split("/").pop().split(".")[0]
    };
    return lib.aws.object_exists(opts, function(e, d) {
      if (e) {
        return create_backup(uri, opts);
      } else {
        return skip(opts.Key);
      }
    });
  };

  missing_pg_backup_uri = function(e) {
    return console.error(e);
  };

  (lib.pgbackups.list()).then(function(list) {
    var i, _i, _len, _ref, _results;
    _ref = _.compact((list.split('\n')).map(function(row, i) {
      if (i > 1 && i < list.length - 1) return _.first(row.split('  '));
    }));
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      i = _ref[_i];
      _results.push((function(i) {
        return (lib.pgbackups.uri(i)).then(with_pg_backup_uri, missing_pg_backup_uri);
      })(i));
    }
    return _results;
  });

}).call(this);
