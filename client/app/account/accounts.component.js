'use strict';

var accounts = {
   bindings: {
      accountsResource: '<'
   },
   templateUrl: 'app/account/accounts.html',
   controller: 'AccountsComponent'
};

angular
   .module('components.admin.management')
   .component('accounts', accounts)
   .config(function ($stateProvider) {
      $stateProvider
         .state('admin', {
            abstract: 'true',
            url: '/admin',
            template: "<div data-ng-include=\"'components/navbar/navbar.html'\"></div>"
                     + "<div ui-view></div>"
         })
         .state('admin.list', {
            authenticate: true,
            url: '/accounts?size&index',
            component: 'accounts',
            params: {
               index: '1',
               size: '10'
            },
            resolve: {
               accountsResource: function accountsResource($stateParams, Account) {
                  return Account.query().$promise;
               }
            }
         })
   });
