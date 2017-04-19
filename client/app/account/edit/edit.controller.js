'use strict';

function AccountEditComponent(
   $log,
   $state,
   $stateParams,
   $window,
   Account,
   Notification) {

   var ctrl = this;

   // True if we are editing an account, false otherwise.
   ctrl.editing = !!$stateParams.id;

   // True when a background task (e.g. backend communication) is active.
   ctrl.working = false;

   ctrl.roles = [];

   if (ctrl.rolesResource._embedded.roles) {
      if (Array.isArray(ctrl.rolesResource._embedded.roles)) {
         ctrl.roles = ctrl.rolesResource._embedded.roles;
      } else {
         ctrl.roles.push(ctrl.rolesResource._embedded.roles);
      }
      // Default tag
      ctrl.role = ctrl.roles[0];
   } else {
      $log.debug('Role resource not found in server response.');
      Notification.error({
         title: 'Server Error',
         message: 'Error found while talking to server. Details logged to the console.'
      });
      return;
   }

   if (ctrl.editing) {
      // Prepare for editing
      if (ctrl.accountResource._embedded) {
         ctrl.account = ctrl.accountResource._embedded.users;
      } else {
         ctrl.account = angular.copy(ctrl.accountResource);
      }
      ctrl.currentAction = 'Edit';
   } else {
      // Prepare for creating
      ctrl.account = new Account();
      ctrl.currentAction = 'Create';
   }

   ctrl.save = function save() {
      ctrl.working = true;

      if (ctrl.editing) {
         //Update account to the backend
         delete ctrl.account._links;
         new Account(ctrl.account).$update()
            .then(function () {
               $log.debug('Account updated.');
               Notification.success({
                  title: 'Success',
                  message: 'The account was updated.',
               });
               $state.go('admin.list');
            })
            .catch(function (error) {
               $log.debug(error);
               Notification.error({
                  title: 'Server Error',
                  message: 'Error found while talking to server. Details logged to the console.'
               });
            })
            .finally(function () {
               ctrl.working = false;
            });
      } else {
         // Save account to the backend
         ctrl.account.$save()
            .then(function () {
               $log.debug('Account created.');
               Notification.success({
                  title: 'Success',
                  message: 'The account was created.',
               });
               $state.go('admin.list');
            })
            .catch(function (error) {
               $log.debug(error);
               Notification.error({
                  title: 'Server Error',
                  message: 'Error found while talking to server. Details logged to the console.'
               });
            })
            .finally(function () {
               ctrl.working = false;
            });
      }
   };
}

angular
   .module('components.admin.management')
   .controller('AccountEditComponent', AccountEditComponent);
