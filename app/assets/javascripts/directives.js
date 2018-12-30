angular.module('morrowindApp').directive('numberInput', ['$filter', function ($filter) {
  return {
    require: '?ngModel',
    link: function (scope, elem, attrs, ctrl) {
      if (!ctrl) {
        return;
      }

      ctrl.$formatters.unshift(function () {
        return $filter('num')(ctrl.$modelValue);
      });

      ctrl.$parsers.unshift(function (viewValue) {
        var plainNumber = parseFloat(viewValue.replace(/,/, '.'));
        //elem.val(plainNumber);
        return plainNumber;
      });
    }
  };
}]);