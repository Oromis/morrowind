angular.module('morrowindApp').factory('ajaxInterceptor', ['$rootScope', '$timeout', '$q',
  function($rootScope, $timeout, $q) {
    var requests = 0;
    $rootScope.communicating = false;
    function decrementRequestCounter() {
      --requests;
      if(requests == 0) {
        // Last request finished -> Hide loading animation
        var loadingIndicator = document.getElementById('ajax-loading-indicator');
        loadingIndicator.style.opacity = '0';
        $rootScope.communicating = false;
      }
    }
    return {
      request: function(config) {
        if(requests == 0) {
          // Show loading animation
          var loadingIndicator = document.getElementById('ajax-loading-indicator');
          loadingIndicator.style.opacity = '1';
          $rootScope.communicating = true;
          $rootScope.requestStart = $rootScope.now();
        }
        ++requests;
        return config;
      },
      response: function(response) {
        // Successful request
        decrementRequestCounter();
        return response;
      },
      responseError: function(rejection) {
        // Request error -> Show an error message
        decrementRequestCounter();

        // Error display
        $('#ajax-error-display').text('Fehler für ' + rejection.config.url + ': ' + rejection.status + " - " + rejection.statusText);
        $timeout(function () {
          $('#ajax-error-display').text('');
        }, 5000);
        return $q.reject(rejection);
      }
    };
  }]);