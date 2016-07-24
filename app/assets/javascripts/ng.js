var morrowindApp = angular.module('morrowindApp',
  ['angular.filter', 'as.sortable', 'siyfion.sfTypeahead',
    'textAngular', 'perfect_scrollbar', 'angular-bootstrap-select'])
    .config(["$httpProvider", function(provider) {
        provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
    }]);
morrowindApp.config(['$httpProvider', function($httpProvider) {
  $httpProvider.interceptors.push('ajaxInterceptor');
}]);
morrowindApp.config(['$provide', function ($provide) {
  $provide.decorator('taOptions', ['$delegate', function(taOptions) {
    taOptions.toolbar = [
      ['h2', 'h3', 'h4', 'h5', 'p', 'justifyLeft', 'justifyCenter', 'justifyRight'],
      ['insertImage'],
      ['bold', 'italics', 'underline', 'strikeThrough', 'ul', 'ol', 'redo', 'undo'],
      ['indent', 'outdent']
    ];
    taOptions.classes.textEditor = 'form-control';
    return taOptions;
  }]);
}]);

// Refresh angular manually (otherwise turbolinks gets in the way)
morrowindApp.run(['$rootScope', function ($rootScope) {
  $(document).on('ready page:load', function(arguments) {
    $rootScope.$digest();
  });

  if (!$rootScope.now) {
    if(typeof performance !== 'undefined' && performance.now) {
      $rootScope.now = function() {
        return performance.now();
      }
    } else {
      $rootScope.now = function() {
        return new Date().getTime();
      }
    }
  }
}]);

//angular.retainingMerge = function (dest, src) {
//  for(var key in src) {
//    if(src.hasOwnProperty(key)) {
//      var val = src[key];
//      if(Array.isArray(val)) {
//        if(!dest[key]) {
//          dest[key] = [];
//        }
//      }
//      switch(typeof val) {
//        case 'object':
//
//          break;
//      }
//    }
//  }
//};

if (!String.prototype.endsWith) {
  String.prototype.endsWith = function(searchString, position) {
    var subjectString = this.toString();
    if (typeof position !== 'number' || !isFinite(position) || Math.floor(position) !== position || position > subjectString.length) {
      position = subjectString.length;
    }
    position -= searchString.length;
    var lastIndex = subjectString.indexOf(searchString, position);
    return lastIndex !== -1 && lastIndex === position;
  };
}

if (!Array.prototype.remove) {
  Array.prototype.remove = function(val) {
    var i = this.indexOf(val);
    return i > -1 ? this.splice(i, 1) : [];
  };
}