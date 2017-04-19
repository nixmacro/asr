function AdminResourceBuilder(collection) {
   return function AdminResource($resource) {
      var root = '/api/admin';
      var itemUrl = root + '/:collection/:id';
      var searchUrl = root + '/:collection/search/:search';

      return $resource(itemUrl, { id: '@id', collection: collection }, {
         query: {
            isArray: false,
         },
         update: {
            url: itemUrl,
            method: 'PUT',
         },
         search: {
            url: searchUrl,
            method: 'GET',
         }
      });
   }
}

angular
   .module('components.admin.management')
   .factory('Account', AdminResourceBuilder('users'))
   .factory('Role', AdminResourceBuilder('roles'));
