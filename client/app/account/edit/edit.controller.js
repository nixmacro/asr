'use strict';

function AccountEditComponent(
   $log,
   $state,
   $stateParams,
   $window,
   RestService,
   Notification) {

   var ctrl = this;

   // True if we are editing an account, false otherwise.
   ctrl.editing = !!$stateParams.id;

   // True when a background task (e.g. backend communication) is active.
   ctrl.working = false;

   // Default tag
   ctrl.roles = ctrl.rolesResource.$subs('roles');
   ctrl.role = ctrl.roles[0];

   if (ctrl.editing) {
      // Prepare for editing
      ctrl.account = angular.copy(ctrl.accountResource);
      ctrl.currentAction = 'Edit';
   } else {
      // Prepare for creating
      ctrl.account = {};
      ctrl.currentAction = 'Create';
   }

   ctrl.save = function save() {
      ctrl.working = true;

      if (ctrl.editing) {
         var delta = {};

         // Save the changed fields to the delta object
         Object.keys(ctrl.account).forEach(function (key) {
            if (ctrl.accountForm[key] && ctrl.accountForm[key].$dirty) {
               delta[key] = ctrl.account[key];
            }
         });

         //Update account to the backend
         RestService.update(ctrl.accountResource, delta)
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
               ctrl.working = false;
            });
      } else {
         // Save account to the backend
         RestService.create('addUser', ctrl.account)
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
               ctrl.working = false;
            });
      }
   };
}

angular
   .module('components.account')
   .controller('AccountEditComponent', AccountEditComponent);
