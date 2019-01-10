$(document).ready(function() {
  $('.char-image-field').on('change', function() {
    $('#char-image-form').submit();
  });

  $('.char-image-delete-btn').on('click', function () {
    $('.char-image-field').val(null);
    $('.char-image-delete-field').val('1');
    $('#char-image-form').submit();
  });
});
