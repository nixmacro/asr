'use strict';

function AccountEditComponent (
    $log,
    $state,
    $stateParams,
    $window,
    RestService,
    Notification) {

    var ctrl = this;
    
    // True if we are editing an account, false otherwise.
    ctrl.editing = !!$stateParams.accountResource;

    // True when a background task (e.g. backend communication) is active.
    ctrl.saving = false;

    if (ctrl.editing) {
        // Prepare for editing
        ctrl.accountResource = $stateParams.accountResource;
        ctrl.account = angular.copy(ctrl.accountResource);
    } else {
        // Prepare for creating
        ctrl.account = {};
    }

    // Save account to the backend
    ctrl.create = function create(event) {
        RestService.create('addUser', event.account)
        .then(function () {
            $log.debug('Account created.');
            Notification.success({
                title: 'Success',
                message: 'The account was created.',
            });
            $state.go('list');
        })
        .catch(restServiceErrorHandler)
        .finally(function () {
            ctrl.saving = false;
        });
    };

    //Update account to the backend
    ctrl.update = function update(event) {
        RestService.update(ctrl.accountResource, event.account)
        .then(function () {
            $log.debug('Account updated.');
            Notification.success({
                title: 'Success',
                message: 'The account was updated.',
            });
            $state.go('list');
        })
        .catch(restServiceErrorHandler)
        .finally(function () {
            ctrl.saving = false;
        });
    };
}

angular
   .module('components.account')
   .controller('AccountEditComponent', AccountEditComponent);