$(function() {
  $(`.navbar-nav > li > a[href="${location.pathname}"]`).parent().addClass('active')
  setTimeout(_ => $('.flash').fadeOut('slow'), 5000)
})
