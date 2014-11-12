(function() {

  module.exports = (function() {
    return {
      s3: {
        bucket: {
          pg: {
            name: "tsu-heroku-pg-backups"
          },
          redis: {
            notifications: "tsu-notifications-production-backup"
          }
        }
      }
    };
  })();

}).call(this);
