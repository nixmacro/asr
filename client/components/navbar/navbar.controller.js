'use strict';

angular.module('asrApp')
.controller('NavbarCtrl', function ($scope, $location, Auth, $state, $stateParams, $moment, RestService) {
   $scope.menu = [{
      'title': 'Users',
      'link': 'users'
   },{
      'title': 'Sites',
      'link': 'sites'
   }];

   $scope.adminMenu = [{
       'title': 'Accounts',
       'parent': 'account',
       'target': 'account.list'
   }];
   
   $scope.endDate = $stateParams.end;
   $scope.startDate = $stateParams.start;
   $scope.tag = $stateParams.tag;

   $scope.isCollapsed = true;
   $scope.isLoggedIn = Auth.isLoggedIn;
   $scope.isAdmin = Auth.isAdmin;
   $scope.getCurrentUser = Auth.getCurrentUser;

   $scope.logout = function() {
      Auth.logout();
      $location.path('/login');
   };

   $scope.isActive = function(route) {
      return route === $location.path();
   };   
});
