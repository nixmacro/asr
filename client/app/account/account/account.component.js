'use strict';

var account = {
   bindings: {
       account: '<',
       onEdit: '&',
       onDelete: '&'
   },
   templateUrl: 'app/account/account/account.html',
   controller: 'AccountComponent'
};

angular
   .module('components.account')
   .component('account', account);