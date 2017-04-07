'use strict';

function AccountDetailComponent (RestService) {
   var ctrl = this;
   
   ctrl.currentAction = ctrl.editing ? 'Edit' : 'Create';
   
   RestService.fetch('roles', { size: '10', index: '1' }, '/admin')
      .then(function (resource) {
         ctrl.roles = resource.$subs('roles');
         ctrl.role = ctrl.roles[0];
      });

   ctrl.save = function() {
      ctrl.saving = true;
      
      if (ctrl.editing) {
         var delta = {};

         // Save the changed fields to the delta object
         Object.keys(ctrl.account).forEach(function (key) {
            if (ctrl.accountForm[key] && ctrl.accountForm[key].$dirty) {
               delta[key] = ctrl.account[key];
            }
         });
         
         ctrl.onUpdate({
            $event: {
                  account: delta
            }
         });
      } else {
         ctrl.onCreate({
            $event: {
                  account: ctrl.account
            }
         });
      }
   };
}

angular
   .module('components.account')
   .controller('AccountDetailComponent', AccountDetailComponent);