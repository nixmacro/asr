'use strict';

angular.module('asrApp')
.factory('Format', function ($moment) {
   var k = 1024;
   var sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];

   // Public API here
   return {
      formatBytes: function (value, size) {
         var k = size || 1024;
         var bytes = parseInt(value);
         if(bytes === 0) { return '0 ' + sizes[0]; }
         var i = Math.floor(Math.log(bytes) / Math.log(k));
         return (bytes / Math.pow(k, i)).toFixed(1) + ' ' + sizes[i];
      },
      formatPercent: function (value, digits) {
         var percent = parseFloat(value);
         return percent.toFixed(digits || 2) + '%';
      },
      formatDurationInSeconds: function (value) {
         var milis = parseInt(value);
         return $moment.duration(milis / 1000, 'seconds').humanize();
      },
      floor: function (value) {
         return Math.floor(value);
      },
      none: function(data) {
         return data;
      }
   };
});
