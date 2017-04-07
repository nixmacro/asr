'use strict';

var edit = {
   templateUrl: 'app/account/edit/edit.html',
   controller: 'AccountEditComponent'
};

angular.module('components.account')
   .component('edit', edit)
   .config(function ($stateProvider) {
      $stateProvider
         .state('edit', {
           authenticate: true,
           url: '/edit',
           component: 'edit',
           params: {
              accountResource: null
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