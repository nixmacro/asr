'use strict';

var edit = {
   bindings: {
      rolesResource: '<',
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
               accountResource: function editAccountResource($stateParams) {
                  if ($stateParams.account) {
                     return $stateParams.account;
                  } else {
                     return {};
                  }
               },
               rolesResource: function rolesResource(RestService) {
                  return RestService.fetch('roles', {
                     size: '10', index: '1'
                  },
                  '/admin')
               }
            }
         })
         .state('create', {
            authenticate: true,
            url: '/create',
            component: 'edit',
            params: {
               accountResource: null
            },
            resolve: {
               rolesResource: function rolesResource(RestService) {
                  return RestService.fetch('roles', {
                     size: '10', index: '1'
                  },
                  '/admin')
               }
            }
         })
   });
