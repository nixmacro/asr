'use strict';

angular.module('asrApp')
.config(function ($stateProvider) {
  $stateProvider
    .state('account', {
      abstract: true,
      url: '/account',
      component: 'account'
    })
    .state('account.list', {
        authenticate: true,
        url: '/list?size&index&searchFilter',
        component: 'list',
        params: {
            index: '1',
            size: '10',
        },
        resolve: {
            accountsResource: function($stateParams, RestService) {
                if ($stateParams.searchFilter) {
                    return RestService.searchAdmin('users', {
                        page: $stateParams.index,
                        size: $stateParams.size,
                        filter: $stateParams.searchFilter,
                    },
                    'findByNameOrEmailOrLogin');
                } else {
                    return RestService.fetchAdmin('users', {
                        page: $stateParams.index,
                        size: $stateParams.size,
                    });
                }
            }
        }
    })
    .state('account.edit', {
        authenticate: true,
        url: '/edit',
        component: 'edit',
        params: {
            accountResource: null
        }
    })
    .state('account.create', {
        authenticate: true,
        url: '/create',
        component: 'edit',
        params: {
            accountResource: null
        }
    });
});