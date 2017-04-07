var detail = {
   bindings: {
      account: '<',
      editing: '<',
      saving: '<',
      onCreate: '&',
      onUpdate: '&'
   },
   templateUrl: 'app/account/detail/detail.html',
   controller: 'AccountDetailComponent'
};

angular
   .module('components.account')
   .component('detail', detail);