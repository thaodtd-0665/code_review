if (location.pathname == '/admin/pull_requests') {
  $(function() {
    $('time.timeago').timeago()
    $('[data-toggle="tooltip"]').tooltip()
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
