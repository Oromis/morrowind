// Shake plugin that rejects values if they are invalid
$.fn.shake = function(o) {
  if (typeof o === 'function')
    o = {callback: o};
  // Set options
  var o = $.extend({
    direction: "left",
    distance: 20,
    times: 3,
    speed: 100,
    easing: "swing"
  }, o);

  return this.each(function() {
    // Create element
    var el = $(this), props = {
      top: el.css("top"),
      bottom: el.css("bottom"),
      left: el.css("left"),
      right: el.css("right")
    };

    // Adjust
    var ref = (o.direction == "up" || o.direction == "down") ? "top" : "left";
    var motion = (o.direction == "up" || o.direction == "left") ? "pos" : "neg";

    // Animation
    var animation = {}, animation1 = {}, animation2 = {};
    animation[ref] = (motion == "pos" ? "-=" : "+=")  + o.distance;
    animation1[ref] = (motion == "pos" ? "+=" : "-=")  + o.distance * 2;
    animation2[ref] = (motion == "pos" ? "-=" : "+=")  + o.distance * 2;

    // Animate
    el.animate(animation, o.speed, o.easing);
    for (var i = 1; i < o.times; i++) { // Shakes
      el.animate(animation1, o.speed, o.easing).animate(animation2, o.speed, o.easing);
    }
    el.animate(animation1, o.speed, o.easing).
      animate(animation, o.speed / 2, o.easing, function(){ // Last shake
        el.css(props); // Restore
        if(o.callback) o.callback.apply(this, arguments); // Callback
      });
  });
};

angular.module("morrowindApp").directive('editable', function() {
  return {
    restrict: 'A',
    scope: {
      model: '=',   // The angular model variable this directive edits
      element: '@', // Whether a child element should actually be replaced (default null)
      number: '=',  // If the input should be parsed as a number
      style: '@',   // 'popover' or 'seamless' (default)
      offset: '=',  // A value to add to the displayed model value
      onConfirm: '&'// Called when a new value is successfully entered
    },
    link: function (scope, element) {
      var width = 100;
      var height = 34;
      var animDistance = 30;

      var originalElement = element;
      if(scope.element) {
        // The actual target to replace is a child
        element = element.find(scope.element);
      }

      originalElement.addClass('editable');
      originalElement.click(function () {
        if(scope.dialog) {
          // Already showing, don't show twice
          return;
        }

        createPopoverDialog();

        scope.dialog.blur(disposeDialog);
        scope.dialogInput.keypress(function (event) {
          if(event.which == '13') { // Enter pressed
            newValue(scope.dialogInput.value());
          }
          event.stopPropagation();
        });

        $('body').append(scope.dialog);

        // Show the input
        scope.dialog.activate();
      });

      function newValue(value) {
        if(scope.number) {
          var relative = false;
          if(/^[+-]/.test(value)) {
            // Starts with + or - => relative change
            relative = true;
          }
          // Replace german ',' with '.'
          value = value.replace(/,/g, '.');

          // Try to turn the input into a number
          var number = parseFloat(value);
          if(isNaN(number)) {
            // Invalid number -> Reject value
            scope.dialog.shake();
          } else {
            var target;
            if(relative) {
              var model = scope.model;
              if(typeof model === 'string') {
                model = parseFloat(model.replace(/,/g, '.'));
              }
              target = model + number;
            } else {
              if(scope.offset) {
                number -= scope.offset;
              }
              target = number;
            }
            acceptValue(target);
          }
        } else {
          // Just normal text -> accept anything
          acceptValue(value);
        }
      }

      function acceptValue(value) {
        scope.$apply(function() {
          scope.model = value;
        });
        scope.$apply(function() {
          scope.onConfirm({value: value});
        });
        disposeDialog();
      }

      function disposeDialog() {
        if(scope.dialog) {
          scope.dialog.dispose();
        }
      }

      function createPopoverDialog() {
        scope.dialog = $('<input class="editable-edit-box form-control" type="text" />');
        scope.dialogInput = scope.dialog;
        var displayVal = scope.model;
        if(scope.offset) {
          displayVal += scope.offset;
        }
        scope.dialogInput.val(displayVal);

        scope.dialog.css('top', (element.offset().top - height) + animDistance + 'px');
        var parentCenter = element.offset().left + element.innerWidth() / 2;
        scope.dialog.css('left', parentCenter - width / 2 + 'px');
        scope.dialog.css('opacity', 0);

        scope.dialog.activate = function() {
          // Fade in and slightly move upwards
          scope.dialog.animate({
            top: '-=' + animDistance + 'px',
            opacity: 1
          }, 'fast');

          // Select the new field to allow the user to start typing away
          scope.dialogInput.focus();
          scope.dialogInput.select();
        };

        scope.dialog.dispose = function() {
          scope.dialog.animate({
            top: '+=' + animDistance + 'px',
            opacity: 0
          }, {
            duration: 'fast',
            complete: function() {
              scope.dialog.remove();
              scope.dialog = null;
            }
          });
        };

        scope.dialog.value = function() {
          return scope.dialog.val();
        }
      }
    }
  };
});
