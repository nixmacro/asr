'use strict';

describe('Component: list', function() {
  // load the component's module
  beforeEach(module('asrApp'));

  var listComponent;

  // Initialize the component and a mock scope
  beforeEach(inject(function($componentController) {
    listComponent = $componentController('list', {});
  }));

  it('should ...', function() {
  });
});
