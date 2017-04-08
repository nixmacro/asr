'use strict';

var edit = {
   bindings: {
      accountResource: '<'
   },
   templateUrl: 'app/account/edit/edit.html',
   controller: 'AccountEditComponent'
};

angular.module('components.account')
   .component('edit', edit)
   .config(function ($stateProvider) {
      $stateProvider
         .state('edit', {
            authenticate: true,
            url: '/edit/:id',
            component: 'edit',
            params: {
               account: null,
               id: null,
            },
            resolve: {
               accountResource: function ($stateParams) {
                  if ($stateParams.account) {
                     return $stateParams.account;
                  } else {
                     return {};
                  }
               }
            }
         })
         .state('create', {
            authenticate: true,
            url: '/create',
            component: 'edit',
            params: {
               accountResource: null
            }
         })
   });
