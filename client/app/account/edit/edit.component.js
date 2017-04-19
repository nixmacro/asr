'use strict';

var edit = {
   bindings: {
      rolesResource: '<',
      accountResource: '<'
   },
   templateUrl: 'app/account/edit/edit.html',
   controller: 'AccountEditComponent'
};

angular.module('components.admin.management')
   .component('edit', edit)
   .config(function ($stateProvider) {
      $stateProvider
         .state('admin.edit', {
            authenticate: true,
            url: '/accounts/:id/edit',
            component: 'edit',
            params: {
               account: null,
               id: null,
            },
            resolve: {
               accountResource: function editAccountResource($stateParams, Account) {
                  if ($stateParams.account) {
                     return $stateParams.account;
                  } else {
                     return Account.get({ id: $stateParams.id}).$promise;
                  }
               },
               rolesResource: function rolesResource(Role) {
                  return Role.query().$promise;
               }
            }
         })
         .state('admin.create', {
            authenticate: true,
            url: '/accounts/new',
            component: 'edit',
            params: {
               accountResource: null
            },
            resolve: {
               rolesResource: function rolesResource(Role) {
                  return Role.query().$promise;
               }
            }
         })
   });
