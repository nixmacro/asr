'use strict';

angular.module('asrApp')
   .controller('SitesCtrl', function (
      $state,
      $stateParams,
      $q,
      sitesResource,
      Format,
      chartResourceBytes,
      chartResourceTime,
      RestService,
      ExportPDF) {

      var self = this;
      self.startDate = $stateParams.start;
      self.endDate = $stateParams.end;
      self.sort = $stateParams.sort;
      self.index = $stateParams.index;
      self.size = $stateParams.size;
      self.viewTitle = $stateParams.user ? ['Sites of User', $stateParams.user].join(' ') : 'Sites';
      self.chartBytesTitle = 'Top 3 Sites by Bytes';
      self.chartTimeTitle = 'Top 3 Sites by Time';

      self.columns = {
         'site': {
            label: 'Site',
            format: Format.none,
            order: 0,
            remoteColumn: 'site',
            sortDir: null
         },
         'bytes': {
            label: 'Bytes',
            format: Format.formatBytes,
            order: 1,
            remoteColumn: 'bytes',
            sortDir: null
         },
         'bytes_percent': {
            label: 'Bytes %',
            format: Format.formatPercent,
            order: 2,
            remoteColumn: 'bytes_percent',
            sortDir: null
         },
         'time': {
            label: 'Time',
            format: Format.formatDurationInSeconds,
            order: 3,
            remoteColumn: 'time',
            sortDir: null
         },
         'time_percent': {
            label: 'Time %',
            format: Format.formatPercent,
            order: 4,
            remoteColumn: 'time_percent',
            sortDir: null
         }
      };

      self.columnNames = Object.keys(self.columns).sort(function (a, b) {
         return self.columns[a].order - self.columns[b].order;
      });

      self.sortColumn = function ($event, column) {
         var params = {};
         var sortDir;

         switch (self.columns[column].sortDir) {
            case 'asc':
               sortDir = null;
               break;
            case 'desc':
               sortDir = 'asc';
               break;
            default:
               sortDir = 'desc';
         }

         if (sortDir) {
            params.sort = [self.columns[column].remoteColumn, sortDir].join('.');
         } else {
            params.sort = sortDir;
         }

         $state.go('sites', params);
      };

      self.newIndex = function () {
         $state.go('sites', { index: self.index });
      };

      var caretDir = function () {
         Object.keys(self.columns).forEach(function (columnName) {
            var splitSort = self.sort.split('.');
            if (splitSort[0] === self.columns[columnName].remoteColumn) {
               self.columns[columnName].sortDir = splitSort[1];
            }
         });
      };

      var chartTopBytes = function () {
         self.labelsBytes = [];
         self.dataBytes = [];
         self.chartBytes.forEach(function (data) {
            self.labelsBytes.push(data.site);
            self.dataBytes.push(data.bytes);
         });

         self.bytesChartOptions = {
            tooltipTemplate: function (data) {
               return data.label + ': ' + Format.formatBytes(data.value);
            }
         };
      };

      var chartTopTime = function () {
         self.labelsTime = [];
         self.dataTime = [];
         self.chartTime.forEach(function (data) {
            self.labelsTime.push(data.site);
            self.dataTime.push(data.time);
         });

         self.timeChartOptions = {
            tooltipTemplate: function (data) {
               return data.label + ': ' + Format.formatDurationInSeconds(data.value);
            }
         };
      };

      // TODO: Abstract this functionality into a service
      self.makePDF = function () {
         RestService.fetchPages(sitesResource, $stateParams)
            .then(function (resources) {
               var promises = [];

               resources.forEach(function (resource) {
                  var promise = resource.$subs('sites').$promise
                     .then(function (sites) {
                        return sites;
                     });

                  promises.push(promise);
               });

               return $q.all(promises);
            })
            .then(function (data) {
               // Object that holds names for exportPDF
               var columnsName = [];
               var names = {};
               var siteName = $stateParams.user ? ['sites_of_user', $stateParams.user].join('_') : 'sites';
               names.pdfName = [siteName, self.startDate, self.endDate].join('_');
               names.chartBytesTitle = self.chartBytesTitle;
               names.chartTimeTitle = self.chartTimeTitle;
               names.relation = 'site';
               names.header = ['Report for', self.viewTitle, 'from', self.startDate, 'to', self.endDate].join(' ');

               // Columns name for table
               Object.keys(self.columns).forEach(function (columnName) {
                  columnsName.push(self.columns[columnName].label);
               });

               // Turn the graph into an image
               var bytesImg = document.getElementById('chartBytes').toDataURL();
               var timeImg = document.getElementById('chartTime').toDataURL();

               // Send data to exportPDF
               ExportPDF.createPDF(names, columnsName, data, self.labelsBytes, self.labelsTime, bytesImg, timeImg);
            });
      }; // makePDF end

      if (sitesResource.$has('sites')) {
         self.sites = sitesResource.$subs('sites');
         self.totalItems = sitesResource.page.totalItems;

         if (self.sort) {
            // Set column sort direction from sort param
            caretDir();
         }
      }

      if (chartResourceBytes.$has('sites')) {
         self.chartBytes = chartResourceBytes.$subs('sites');

         // Generates the data for bytes chart
         chartTopBytes();
      }

      if (chartResourceTime.$has('sites')) {
         self.chartTime = chartResourceTime.$subs('sites');

         // Generates the data for time chart
         chartTopTime();
      }
   });
