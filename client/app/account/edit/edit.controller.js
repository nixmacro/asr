'use strict';

angular.module('asrApp')
.controller('AccountEditCtrl', function (
    $log,
    $state,
    $stateParams,
    $window,
    RestService,
    Notification) {

    var self = this;

    // Common headers used to post to an association resources.
    var assocOptions = {
        headers: {
            'Content-Type': 'text/uri-list',
        },
    };

    // True if we are editing an account, false otherwise.
    self.editing = !!$stateParams.accountResource;

    // True when a background task (e.g. backend communication) is active.
    self.saving = false;

    if (self.editing) {
        // Prepare for editing
        self.currentAction = 'Edit';
        self.accountResource = $stateParams.accountResource;
        self.account = angular.copy(self.accountResource);
    } else {
        // Prepare for creating
        self.currentAction = 'Create';
        self.account = {};
    }

    self.errorMessages = {
        server: {},
    };

    // Enum for possible gender values
    self.genderEnum = {
        MALE: 'Male',
        FEMALE: 'Female',
    };

    // Enum for possible status values
    self.rolesEnum = {
        ADMIN: 'Admin',
        REGULAR: 'Regular',
    };

    self.fieldSets = {
        accountInfo: {
            visible: true,
        },
        personalInfo: {
            visible: true,
        },
        extraInfo: {
            visible: false,
        },
    };

    // Returns all users that match the filter
    self.getUsers = function getUsers(filter) {
        return RestService.searchAdmin({
            rel: 'customers',
            searchRel: 'findByNameOrid',
            urlParams: { filter: filter },
        }).then(function (customersResource) {
            if (customersResource.$has('customers')) {
                return customersResource.$get('customers');
            } else {
                return [];
            }
        });
    };

    // Formats a user for display
    self.userFormatter = function userFormatter(user) {
        if (user && typeof user == 'object') {
            return $window.sprintf('%(id)s : %(name)s', user);
        } else {
            return user;
        }
    };

    // Toggles the visibility of a fieldSet
    self.toggleFieldsetVisibility = function toggleFieldsetVisibility(fieldSet) {
        self.fieldSets[fieldSet].visible = !self.fieldSets[fieldSet].visible;
    };

    // Save an account to the backend
    self.save = function save() {
        self.saving = true;

        if (self.editing) {
            var delta = {};

            // Save the changed fields to the delta object
            Object.keys(self.account).forEach(function (key) {
                if (self.accountForm[key] && self.accountForm[key].$dirty) {
                    delta[key] = self.account[key];
                }
            });
            // accountResource.$followOne('search', {protocol: {method: 'PUT', data: delta} });
            self.accountResource.$patch('self', null, delta)
            .then(function () {
                $log.debug('Account updated.');
                Notification.success({
                    title: 'Success',
                    message: 'The account was updated.',
                });
                $state.go('account.list');
            })
            .catch(restServiceErrorHandler)
            .finally(function () {
                self.saving = false;
            });
        } else {
            RestService.apiRoot()
            .then(function (rootResource) {
                if (rootResource.$has('accounts')) {
                    rootResource.$post('accounts', null, self.account)
                    // rootResource.$followOne('search', {protocol: {method: 'POST', data: self.account} });
                    // rootResource.$followOne('post', { data: self.account });
                    .then(function (newAccount) {
                        if (self.customer) {
                            return newAccount.$put('customer', assocOptions, self.customer.$href('self'));
                        }
                    })
                    .then(function () {
                        $log.debug('Account created.');
                        Notification.success({
                            title: 'Success',
                            message: 'The account was created.',
                        });
                        $state.go('account.list');
                    })
                    .catch(restServiceErrorHandler)
                    .finally(function () {
                        self.saving = false;
                    });
                } else {
                    var error = new Error('Server does not contain the required resources.');
                    throw error;
                }
            })
            .catch(restServiceErrorHandler)
            .finally(function () {
                self.saving = false;
            });
        }
    };

    /**
     * Error handling function that reacts to some well known error codes. Also logs to the console and
     * notifies the user using the Notification service.
     * @param err {Error} The error object from the rest service interaction.
     */
    function restServiceErrorHandler(err) {
        $log.debug(err);

        switch (err.status) {
            case 409:
            case 422:
                err.data.errors.forEach(function (error) {
                    self.accountForm[error.field].$setValidity('server', false);
                    self.errorMessages.server[error.field] = error.defaultMessage;
                });

                Notification.error({
                    title: err.data.title,
                    message: err.data.detail,
                });
                break;
            default:
                Notification.error({
                    title: 'Server Error',
                    message: 'Error found while talking to server. Details logged to the console.',
                });
                break;
        }
    }
});