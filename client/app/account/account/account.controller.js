function AccountComponent() {
   var ctrl = this;

   ctrl.select = function select(action) {
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
   .module('components.admin.management')
   .controller('AccountComponent', AccountComponent)
