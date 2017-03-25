'use strict';

angular.module('asrApp')
.controller('AccountListCtrl', function (
    $log, 
    $state, 
    $stateParams,
    RestService,
    Notification) {

    var self = this;

    function goToPage(size, index, searchFilter) {
        $state.go('account.list', {
            size: size,
            index: index,
            searchFilter: searchFilter
        });
    };

    self.accounts = [];
    self.working = false;

    if (this.accountsResource.$has('users')) {
        self.accounts = this.accountsResource.$subs('users');
    } else {
        $log.debug('Account resource not found in server response.');
        Notification.error({
            title: 'Server Error',
            message: 'Error found while talking to server. Details logged to the console.'
        });
    }

    self.index = $stateParams.index;
    self.size = $stateParams.size;
    self.totalItems = this.accountsResource.page.totalItems;
    self.filter = $stateParams.searchFilter;

    self.pageChanged = function() {
        goToPage($stateParams.size, self.index, self.filter);
    };

    self.filterChanged = function() {
        goToPage($stateParams.size, 1, self.filter);
    };

    self.clearSearchFilter = function() {
        goToPage($stateParams.size, 1);
    };

    self.unlink = function(account) {
        self.working= true;
        account.$delete()
        .then(function () {
            account.$hasCustomer = false;
            $log.debug('Successfully unlinked the account.');
            Notification.success({
                title: 'Success',
                message: 'The account was correctly unlinked.'
            })
        })
        .catch(function (error) {
            $log.debug(error);
            Notification.error({
                title: 'Application error',
                message: 'Error found while talking to unlink the account. Details logged to the console.'
            });
        })
        .finally(function() {
            self.working = false;
        });
    };

    self.edit = function(account) {
        $state.go('account.edit', {
            size: $stateParams.size,
            index: $stateParams.index,
            searchFilter: $stateParams.searchFilter,
            accountResource: account
        });
    };
});