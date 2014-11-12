// Generated by CoffeeScript 1.7.1
(function() {
  var PgBackups, process, q;

  process = require('child_process');

  q = require('q');

  PgBackups = function() {
    var generic_routine, get_snapshot_uri, list_snapshots;
    generic_routine = function(fn, id) {
      var capture_list, deferred, list;
      list = id ? fn(id) : fn();
      capture_list = [];
      deferred = q.defer();
      list.stdout.setEncoding('utf8');
      list.stderr.setEncoding('utf8');
      list.stdout.on('data', function(chunk) {
        return capture_list.push(chunk);
      });
      list.stderr.on('data', function(e) {
        uri.stderr.pipe(process.stderr);
        return deferred.reject(e);
      });
      list.stderr.on('close', function() {
        return deferred.resolve(capture_list.join(""));
      });
      return deferred.promise;
    };
    get_snapshot_uri = function(id) {
      return process.spawn("heroku", ["pgbackups:url", "" + (id || ''), "-a", "tsu-production"]);
    };
    list_snapshots = function() {
      return process.spawn("heroku", ["pgbackups", "-a", "tsu-production"]);
    };
    this.list = function() {
      return generic_routine(list_snapshots);
    };
    this.uri = function(id) {
      return generic_routine(get_snapshot_uri, id);
    };
  };

  module.exports = new PgBackups();

}).call(this);
