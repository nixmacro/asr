'use strict';

angular.module('asrApp')
.config(function ($stateProvider) {
   $stateProvider
   .state('users', {
      url: '/users?size&index&start&end&sort&site&tag',
      templateUrl: 'app/users/users.html',
      controller: 'UsersCtrl as ctrl',
      params: {
         size: '10',
         index: '1',
         sort: 'bytes.desc',
         tag: '0'
      },
      resolve: {
         usersResource: function($stateParams, RestService) {
            if ($stateParams.site) {
               return RestService.search('users', {
                  index: $stateParams.index,
                  size: $stateParams.size,
                  site: $stateParams.site,
                  sort: $stateParams.sort,
                  start: $stateParams.start,
                  end: $stateParams.end,
                  tag: $stateParams.tag
               },
               'findBySite');
            } else {
               return RestService.fetch('users', {
                  index: $stateParams.index,
                  size: $stateParams.size,
                  sort: $stateParams.sort,
                  start: $stateParams.start,
                  end: $stateParams.end,
                  tag: $stateParams.tag
               });
            }
         },
         chartResourceBytes: function($stateParams, RestService) {
            if ($stateParams.site) {
               return RestService.search('users', {
                  site: $stateParams.site,
                  size: 3,
                  sort: 'bytes.desc',
                  start: $stateParams.start,
                  end: $stateParams.end,
                  tag: $stateParams.tag
               },
               'findBySite');
            } else {
               return RestService.fetch('users', {
                  size: 3,
                  sort: 'bytes.desc',
                  start: $stateParams.start,
                  end: $stateParams.end,
                  tag: $stateParams.tag
               });
            }
         },
         chartResourceTime: function($stateParams, RestService) {
            if ($stateParams.site) {
               return RestService.search('users', {
                  site: $stateParams.site,
                  size: 3,
                  sort: 'time.desc',
                  start: $stateParams.start,
                  end: $stateParams.end,
                  tag: $stateParams.tag
               },
               'findBySite');
            } else {
               return RestService.fetch('users', {
                  size: 3,
                  sort: 'time.desc',
                  start: $stateParams.start,
                  end: $stateParams.end,
                  tag: $stateParams.tag
               });
            }
         }
      }
   });
});
