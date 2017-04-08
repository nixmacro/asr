/**
 *
 * @ngdoc module
 * @name components.account
 *
 * @requires ui.router
 * @requires ui-notification
 * @requires ui.bootstrap
 * @requires ngMessages
 *
 * @description
 *
 * This is the account module. It includes all the components for the account management feature.
 *
 */
'use strict';

angular
   .module('components.account', [
      'ui.router',
      'ui-notification',
      'ui.bootstrap',
      'ngMessages',
      'ngResource',
   ]);
