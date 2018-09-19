if (location.pathname == '/') {
  $(function() {
    $('time.timeago').timeago()
    $('[data-toggle="tooltip"]').tooltip()

    $('.filter select').change(function() {
      let form = document.getElementById('filter-form')
      Rails.fire(form, 'submit')

      let query = $(form).serialize()
      let path = `${location.pathname}?${query}`
      history.pushState(null, null, path)
    })

    $('.js-states').select2({
      placeholder: '',
      allowClear: true,
      theme: 'bootstrap4'
    })

    $('.js-repositories').select2({
      placeholder: '',
      allowClear: true,
      theme: 'bootstrap4'
    })
  })

  App.pull_request = App.cable.subscriptions.create("PullRequestChannel", {
    connected: function() {
      $('.offline-notification').hide()
    },
    disconnected: function() {
      $('.offline-notification').show()
    },
    received: function(data) {
      if ($(data.node).length) {
        $(data.node).replaceWith(data.html)
      } else {
        let states = $('.filter #state').val(),
            room_id = $('.filter #room').val(),
            repository_ids = $('.filter #repository').val()

        if (!states.includes(data.state))
          return

        if (!(room_id.length == 0 || room_id == data.room_id))
          return

        if (!(repository_ids.length == 0 || repository_ids.includes(data.repository_id)))
          return

        $('tbody').prepend(data.html)
      }

      $(`${data.node} time.timeago`).timeago()
      $(`${data.node} [data-toggle="tooltip"]`).tooltip()
    }
  })
}
