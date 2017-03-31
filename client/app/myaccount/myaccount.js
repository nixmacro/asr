'use strict';

angular.module('asrApp')
.config(function ($stateProvider) {
   $stateProvider
   .state('login', {
      url: '/login',
      templateUrl: 'app/myaccount/login/login.html',
      controller: 'LoginCtrl'
   })
   // .state('signup', {
   //    url: '/signup',
   //    templateUrl: 'app/account/signup/signup.html',
   //    controller: 'SignupCtrl'
   // })
   .state('settings', {
      url: '/settings',
      templateUrl: 'app/myaccount/settings/settings.html',
      controller: 'SettingsCtrl as settingsVM',
      authenticate: true
   });
});
