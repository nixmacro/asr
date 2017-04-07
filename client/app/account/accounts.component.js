'use strict';

var accounts = {
   bindings: {
      accountsResource: '<'
   },
   templateUrl: 'app/account/accounts.html',
   controller: 'AccountsComponent'
};

angular
   .module('components.account')
   .component('accounts', accounts)
   .config(function ($stateProvider) {
      $stateProvider
         .state('list', {
            authenticate: true,
            url: '/accounts?size&index',
            component: 'accounts',
            params: {
                index: '1',
                size: '10'
            },
            resolve: {
                accountsResource: function($stateParams, RestService) {
                  return RestService.fetch('users', {
                      page: $stateParams.index,
                      size: $stateParams.size,
                  },
                  '/admin');
              }
            }
         })
   });