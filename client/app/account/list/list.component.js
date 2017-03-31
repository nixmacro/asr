'use strict';

angular.module('asrApp')
  .component('list', {
    templateUrl: 'app/account/list/list.html',
    bindings: {
        accountsResource: '<'
    },
    controller: 'AccountListCtrl'
  });