if (location.pathname == '/') {
  $(function() {
    $('time.timeago').timeago()
    $('[data-toggle="tooltip"]').tooltip()

    $('.filter form').submit(function() {
      let query = $(this).serialize()
      let path = `${location.pathname}?${query}`
      history.pushState(null, null, path)
    })

    $('.js-repositories').select2({
      allowClear: true,
      theme: 'bootstrap4'
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
      } else {
        let state = $('.filter #state').val(),
            room_id = $('.filter #room').val(),
            repository_ids = $('.filter #repository').val()

        if (!(state == data.state))
          return

        if (!(room_id.length || room_id == data.room_id))
          return

        if (!(repository_ids.length || repository_ids.includes(data.repository_id)))
          return

        $('tbody').prepend(data.html)
      }

      $(`${data.node} time.timeago`).timeago()
      $(`${data.node} [data-toggle="tooltip"]`).tooltip()
    }
  })
}
