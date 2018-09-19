$(function() {
  $('.last-session').click(function(event) {
    event.preventDefault()
    location.href = localStorage.getItem('last-session') || '/'
  })
})
