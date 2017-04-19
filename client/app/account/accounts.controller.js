'use strict';

function AccountsComponent(
   $log,
   $state,
   $stateParams,
   Account,
   Notification) {

   var ctrl = this;

   function goToPage(size, index) {
      $state.go('admin.list', {
         size: size,
         index: index,
      });
   };

   ctrl.accounts = [];
   ctrl.working = false;

   if (ctrl.accountsResource._embedded.users) {
      if (Array.isArray(ctrl.accountsResource._embedded.users)) {
         ctrl.accounts = ctrl.accountsResource._embedded.users;
      } else {
         ctrl.accounts.push(ctrl.accountsResource._embedded.users);
      }
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

   ctrl.pageChanged = function pageChanged() {
      goToPage($stateParams.size, ctrl.index);
   };

   ctrl.onDelete = function onDelete(event) {
      ctrl.working = true;
      var index = ctrl.accounts.indexOf(event.account);

      // Delete account to the backend
      new Account(event.account).$delete()
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
            if (0 <= index) {
               ctrl.accounts.splice(index, 1);
            }
         });
   };

   ctrl.onEdit = function onEdit(event) {
      $state.go('admin.edit', {
         id: event.account.id,
         account: event.account,
      });
   };
}

angular
   .module('components.admin.management')
   .controller('AccountsComponent', AccountsComponent);
