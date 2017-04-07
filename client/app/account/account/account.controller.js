function AccountComponent() {
   var ctrl = this;

   ctrl.select = function(action) {
      var event = {
         $event: {
            account: ctrl.account
         }
      }
      if (action === 'edit') {
         ctrl.onEdit(event);
      } else {
         ctrl.onDelete(event);
      }
   };
}

angular
   .module('components.account')
   .controller('AccountComponent', AccountComponent)