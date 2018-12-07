$(function() {
  $(`.navbar-nav > li > a[href="${location.pathname}"]`).parent().addClass('active')
})
