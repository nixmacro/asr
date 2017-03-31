'use strict';

describe('Component: AccountComponent', function() {
  // load the controller's module
  beforeEach(module('asrApp'));

  var AccountComponent;

  // Initialize the controller and a mock scope
  beforeEach(inject(function($componentController) {
    AccountComponent = $componentController('account', {});
  }));

  it('should ...', function() {
  });
});
