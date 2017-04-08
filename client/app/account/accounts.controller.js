'use strict';

function AccountsComponent(
    $log,
    $state,
    $stateParams,
    Notification) {

    var ctrl = this;

    function goToPage(size, index) {
        $state.go('list', {
            size: size,
            index: index,
        });
    };

    ctrl.accounts = [];
    ctrl.working = false;

    if (this.accountsResource.$has('users')) {
        ctrl.accounts = ctrl.accountsResource.$subs('users');
    } else {
        $log.debug('Account resource not found in server response.');
        Notification.error({
            title: 'Server Error',
            message: 'Error found while talking to server. Details logged to the console.'
        });
        return;
    }

    ctrl.index = $stateParams.index;
    ctrl.size = $stateParams.size;
    ctrl.totalItems = ctrl.accountsResource.page.totalItems;

    ctrl.pageChanged = function () {
        goToPage($stateParams.size, ctrl.index);
    };

    ctrl.onDelete = function (event) {
        ctrl.working = true;
        event.account.$delete()
            .$promise
            .then(function () {
                $log.debug('Successfully deleted the account.');
                Notification.success({
                    title: 'Success',
                    message: 'The account was correctly deleted.'
                })
            })
            .catch(function (error) {
                $log.debug(error);
                Notification.error({
                    title: 'Application error',
                    message: 'Error found while deleting the account. Details logged to the console.'
                });
            })
            .finally(function () {
                ctrl.working = false;
                var index = ctrl.accounts.indexOf(event.accout);
                if (0 <= index) {
                    ctrl.accounts.splice(index, 1);
                }
            });
    };

    ctrl.onEdit = function (event) {
        $state.go('edit', {
            id: event.account.id,
            account: event.account,
        });
    };
}

angular
    .module('components.account')
    .controller('AccountsComponent', AccountsComponent);
