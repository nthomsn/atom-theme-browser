$(document).ready(function() {

  // Handle the clicking of themes
  $('div.theme-preview').click(function() {
    $(this).toggleClass('light-hover');
    $(this).find('img').toggleClass('theme-clicked');
    $(this).find('div.theme-details').toggle();
    $(this).find('.auto-select').select();
  });

});
