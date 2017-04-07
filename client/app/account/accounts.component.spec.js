'use strict';

describe('Component: AccountsComponent', function() {
  // load the controller's module
  beforeEach(module('asrApp'));

  var AccountComponent;

  // Initialize the controller and a mock scope
  beforeEach(inject(function($componentController) {
    AccountsComponent = $componentController('account', {});
  }));

  it('should ...', function() {
  });
});
