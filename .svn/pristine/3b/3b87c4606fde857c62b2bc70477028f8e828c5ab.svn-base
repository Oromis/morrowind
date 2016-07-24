angular.module("morrowindApp").directive('buttonGroup', function() {
  return {
    restrict: 'AE',
    scope: {
      model: '=',
      onChange: '&'
    },
    link: function(scope, element) {
      element.children().click(function(event) {
        scope.$apply(function() {
          var btn = $(event.delegateTarget);
          scope.model = btn.attr('data-value');
          element.children().removeClass('active');
          btn.addClass('active');
          scope.onChange();
        });
      });
    }
  };
});