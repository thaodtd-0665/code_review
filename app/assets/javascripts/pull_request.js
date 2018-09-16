if (location.pathname == '/pull_requests') {
  $(function() {
    $('time.timeago').timeago()
    $('[data-toggle="tooltip"]').tooltip()

    $('.filter form').submit(function() {
      let query = $(this).serialize()
      let path = `${location.pathname}?${query}`
      history.pushState(null, null, path)
    })
  })

  App.pull_request = App.cable.subscriptions.create("PullRequestChannel", {
    connected: function() {
      console.log('connected')
    },
    disconnected: function() {
      console.log('disconnected')
    },
    received: function(data) {
      if ($(data.node).length) {
        $(data.node).replaceWith(data.html)
        $(`${data.node} time.timeago`).timeago()
        $(`${data.node} [data-toggle="tooltip"]`).tooltip()
      }
    }
  })
}
