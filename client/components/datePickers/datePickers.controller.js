'use strict';

angular.module('asrApp')
.controller('datePickersCtrl', function (
    $state,
    $stateParams,
    RestService,
    $moment) {

    var self = this;

    RestService.fetch('tags', {size: '10', index: '1'})
       .then(function (resource) {
          self.tags = resource.$subs('tags');
          self.tag = $stateParams.tag ? self.tags[$stateParams.tag] : self.tags[0];
       });
    
    self.endDate = $stateParams.end ? $moment($stateParams.end).toDate() :
        $moment().toDate();
    self.startDate = $stateParams.start ? $moment($stateParams.start).toDate() :
        $moment().subtract(15, 'days').toDate();

    self.maxDate = new Date();

    self.tooglePicker = function (picker) {
        self[picker] = !self[picker];
    };

    self.getDateParams = function () {
        var params = {};

        params.start = self.startDate.toISOString().split('T')[0];
        params.end = self.endDate.toISOString().split('T')[0];

        return params;
    };

    self.applyDate = function () {
        $state.go($state.current, self.getDateParams());
    };

    self.applyTag = function () {
        $state.go($state.current, { tag: self.tag });
    };

});