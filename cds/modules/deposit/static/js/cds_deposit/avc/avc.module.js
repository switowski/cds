function cdsDepositsConfig(
  $locationProvider,
  depositStatesProvider,
  depositSSEEventsProvider,
  depositStatusesProvider,
  depositActions,
  inheritedPropertiesProvider,
  taskRepresentationsProvider,
  urlBuilderProvider,
  typeReducerProvider,
  localStorageServiceProvider,
  sfErrorMessageProvider
) {
  $locationProvider.html5Mode({
    enabled: true,
    requireBase: false,
    rewriteLinks: false,
  });
  sfErrorMessageProvider.setDefaultMessage(0, 'This field is required.');

  // Local storage configuration
  localStorageServiceProvider.setPrefix('cdsDeposit');

  var mainStatuses = [
    'file_upload',
    'file_download',
    'file_video_metadata_extraction',
    'file_video_extract_frames',
    'file_transcode',
  ];

  // Initialize the states
  depositStatesProvider.setValues(mainStatuses);

  var additionalEvents = [ 'update_deposit' ];

  // Extra SSE events to listen excluded from the statuses
  depositSSEEventsProvider.setValues(mainStatuses.concat(additionalEvents));

  // Initialize statuses provider
  depositStatusesProvider.setValues({
    PENDING: 'DEPOSIT_STATE/PENDING',
    STARTED: 'DEPOSIT_STATE/STARTED',
    FAILURE: 'DEPOSIT_STATE/FAILURE',
    SUCCESS: 'DEPOSIT_STATE/SUCCESS',
    REVOKED: 'DEPOSIT_STATE/REVOKED',
  });

  // Deposit actions' information
  depositActions.setValues(['project', 'video'])

  inheritedPropertiesProvider.setValues([
    'contributors',
    'date',
    'description.value',
    'keywords',
    'title.title',
  ]);

  taskRepresentationsProvider.setValues({
    file_upload: 'Video file upload',
    file_download: 'Video file download',
    file_transcode: 'Video transcoding',
    file_video_extract_frames: 'Video frame extraction',
    file_video_metadata_extraction: 'Video metadata extraction'
  });

  // Initialize url builder
  urlBuilderProvider.setBlueprints({
    iiif: '/api/iiif/v2/<%=deposit%>:<%=key%>/full/<%=res%>/0/default.png',
    sse: '/api/deposits/project/<%=id%>/sse',
    video: '/deposit/<%=deposit%>/preview/video/<%=key%>',
    eventInfo: '/hooks/receivers/avc/events/<%=eventId%>',
    restartEvent: '/hooks/receivers/avc/events/<%=eventId%>/tasks/<%=taskId%>',
    taskFeedback: '/hooks/receivers/avc/events/<%=eventId%>/feedback',
    selfVideo: '/api/deposits/video/<%=deposit%>',
    bucketVideo: '/api/files/<%=bucket%>',
    actionVideo: '/api/deposits/video/<%=deposit%>/actions/<%=action%>',
    record: '/record/<%=recid%>',
  });

  // Initialize type reducer
  typeReducerProvider.setBlueprints({
    SUCCESS: function(type, data) {
      if (type === 'update_deposit') {
        this.updateDeposit(data.meta.payload.deposit);
      }
    },
  });
}

// Inject the necessary angular services
cdsDepositsConfig.$inject = [
  '$locationProvider',
  'depositStatesProvider',
  'depositSSEEventsProvider',
  'depositStatusesProvider',
  'depositActionsProvider',
  'inheritedPropertiesProvider',
  'taskRepresentationsProvider',
  'urlBuilderProvider',
  'typeReducerProvider',
  'localStorageServiceProvider',
  'sfErrorMessageProvider',
];

// Register modules
angular.module('cdsDeposit.filters', []);
angular.module('cdsDeposit.providers', []);
angular.module('cdsDeposit.components', []);
angular.module('cdsDeposit.factories', []);

// Register all cdsDeposit module into one
angular.module('cdsDeposit.modules', [
  'cdsDeposit.filters',
  'cdsDeposit.providers',
  'cdsDeposit.factories',
  'cdsDeposit.components',
  'LocalStorageModule',
  'schemaForm',
]).config(cdsDepositsConfig);

angular
  .module('cdsDeposit.filters')
  .filter('taskRepr', function(taskRepresentations) {
    return function(input) {
      return taskRepresentations[input] || input;
    };
  });


angular.module('schemaForm')
  .controller('invenioDynamicSelectController', ['$scope', '$controller',
    function ($scope, $controller) {
      $controller('dynamicSelectController', {$scope: $scope});
      // If it is ui-select inside an array...
      if ($scope.modelArray) {
        $scope.$watchCollection('modelArray', function (newValue) {
          // If this is not the initial setting of the element...
          if (!angular.equals($scope.select_model, {})) {
            // Get the element's correct value from the array model
            var value = $scope.modelArray[$scope.arrayIndex][$scope.form.key.slice(-1)[0]];
            // Set ui-select's model to the correct value if needed
            if ($scope.insideModel !== value) {
              $scope.insideModel = value;
              var query = $scope.$eval($scope.form.options.processQuery || 'query', {query: value});
              $scope.populateTitleMap($scope.form, query);
              $scope.select_model.selected = $scope.find_in_titleMap(value);
            }
          }
        });
      }
    }]);
// Initialize the module
angular
  .module('cdsDeposit', [
    'cdsDeposit.modules',
    'schemaForm',
    'mgcrea.ngStrap',
    'mgcrea.ngStrap.modal',
    'pascalprecht.translate',
    'ui.sortable',
    'ui.select',
    'mgcrea.ngStrap.select',
    'mgcrea.ngStrap.datepicker',
    'mgcrea.ngStrap.helpers.dateParser',
    'mgcrea.ngStrap.tooltip',
    'ngFileUpload',
    'monospaced.elastic',
    'invenioFiles.filters',
    'afkl.lazyImage',
  ]);
