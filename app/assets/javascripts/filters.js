angular.module("morrowindApp").filter('count', [function() {
  return function(input) {
    if(input == null) {
      return 0;
    }
    if(Array.isArray(input)) {
      return input.length;
    } else {
      return Object.keys(input).length;
    }
  };
}]);

angular.module("morrowindApp").filter('stripResistance', [function() {
  return function(input) {
    if(input == null) {
      return '';
    }
    if(input.endsWith('resistenz')) {
      input = input.substr(0, input.length - 'resistenz'.length);
    }
    if(input.endsWith('s')) {
      input = input.substr(0, input.length - 1);
    }
    return input;
  };
}]);

angular.module("morrowindApp").filter('num', [function() {
  return function(input, precision) {
    if(input == null) {
      return '';
    }
    if(typeof input !== 'number') {
      return input;
    }
    precision = precision || 3;
    var postfix = '';
    if(input >= 1000000) {
      input /= 1000000;
      postfix = ' m';
    } else if(input >= 1000) {
      input /= 1000;
      postfix = ' k';
    }

    var number = input.toPrecision(precision);
    if(number.indexOf('.') != -1) {
      while(number[number.length - 1] == '0') {
        number = number.substr(0, number.length - 1);
      }
    }
    if(number[number.length - 1] == '.') {
      number = number.substr(0, number.length - 1);
    }
    number = number.replace(/\./g, ',');

    return number + postfix;
  };
}]);

angular.module("morrowindApp").filter('filterItems', [function() {
  return function(items, term) {
    if(typeof term !== 'string' || term == '') {
      term = null;
    } else {
      term = term.toLowerCase();
    }
    var out = [];
    if(term == null) {
      out = items;
    } else {
      if(items != null) {
        for (var i = 0; i < items.length; ++i) {
          var strings = [items[i].name, items[i].desc];
          for (var j = 0; j < strings.length; ++j) {
            if (strings[j] != null && strings[j].toLowerCase().indexOf(term) != -1) {
              out.push(items[i]);
              break;
            }
          }
        }
      }
    }
    return out;
  };
}]);