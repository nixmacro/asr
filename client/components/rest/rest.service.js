'use strict';

angular.module('asrApp')
   .service('RestService', function ($q, hrRoot) {

      var restApiRoot = '/api';

      // Public API here
      return {
         fetch: function (rel, params, adminRoot) {
            var root = adminRoot ? (restApiRoot + adminRoot) : restApiRoot;
            return hrRoot(root).follow().$promise
               .then(function (rootResource) {
                  if (rootResource.$has(rel)) {
                     return rootResource
                        .$followOne(rel, { data: params }).$promise;
                  } else {
                     throw Error('Requested relation not found in the root resource.');
                  }
               });
         },
         fetchPages: function (pagedHalResource, params) {
            var page = pagedHalResource.page;
            var totalPages = Math.ceil(page.totalItems / page.size);
            var promises = [];

            for (var i = 1; i <= totalPages; i++) {
               params.index = i;
               var promise = pagedHalResource
               .$followOne('self', { data: params }).$promise
                  .then(function (resource) {
                     return resource;
                  });

               promises.push(promise);
            }

            return $q.all(promises);
         },
         fetchAllPages: function fetchAllPages(pagedResource, params, pageSize) {
            var totalPages = Math.ceil(pagedResource.page.totalItems / pageSize);
            var promises = [];
            params.size = pageSize;

            for (var i = 1; i <= totalPages; i++) {
               params.index = i;
               var promise = pagedResource
               .$followOne('self', { data: params }).$promise
                  .then(function (resource) {
                     return resource;
                  });

               promises.push(promise);
            }

            return $q.all(promises);
         },
         search: function (rel, params, searchRel) {
            return hrRoot(restApiRoot).follow().$promise
               .then(function (rootResource) {
                  if (rootResource.$has(rel)) {
                     return rootResource
                        .$followOne(rel, { data: params }).$promise;
                  } else {
                     throw Error('Requested relation not found in API root resource.');
                  }
               }).then(function (resource) {
                  if (resource.$has('search')) {
                     return resource.$followOne('search').$promise;
                  } else {
                     throw Error('Requested relation has no search resources.');
                  }
               }).then(function (searchResource) {
                  if (searchResource.$has(searchRel)) {
                     return searchResource
                        .$followOne(searchRel, { data: params }).$promise;
                  } else {
                     throw Error('Requested relation %s has no search %s');
                  }
               });
         },
         create: function (rel, data) {
            return hrRoot('/api/admin').follow().$promise
               .then(function (rootResource) {
                if (rootResource.$has(rel)) {
                   return rootResource
                      .$followOne(rel, { protocol: 
                                          { method: 'POST', data: data } 
                                       }).$promise;
                } else {
                   throw Error('Requested relation not found in the root resource.');
                }
            });
         },
         update: function (resource, data) {
            return resource.$followOne('self',
                  { protocol: 
                        { method: 'PUT', data: data }
                  }).$promise
         }
      };
   });
