angular.module("morrowindApp").directive('popover', function() {
  return {
    restrict: 'A',
    scope: {
      popoverTitle: '=',
      popoverContent: '=',
      popoverCondition: '='
    },
    link: function (scope, element) {
      element.hover(function() {
        if(scope.popover) 
          scope.popover.remove();

        if(scope.popoverCondition) {
          var html = '<div class="morrowind-popover">';
          if(scope.popoverTitle && scope.popoverTitle.length > 0)
            html += '<h4>' + scope.popoverTitle + '</h4>';
          if(scope.popoverContent && scope.popoverContent.length > 0) 
            html += '<p>' + scope.popoverContent + '</p>';
          html += '</div>';
          scope.popover = $(html);
          scope.popover.width(element.outerWidth());
          element.after(scope.popover);
        }
      }, function() {
        if(scope.popover) {
          scope.popover.remove();
          scope.popover = null;
        }
      });
    }
  };
});
