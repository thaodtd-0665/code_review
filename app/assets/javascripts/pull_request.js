if (location.pathname == '/') {
  $(function() {
    function debounce(cb, time = 250, interval) {
      return function(...args) {
        clearTimeout(interval)
        interval = setTimeout(cb, time, ...args)
      }
    }

    let title = document.title
    let notify = debounce(function() {
      $.ajax({
        url: '/pull_requests/status',
        method: 'GET',
        data: {
          room: $('.filter #room').val(),
          repository: $('.filter #repository').val().concat('')
        },
        dataType: 'json'
      }).done(function(data) {
        document.title = data.count > 0 ? `(${data.count}) ${title}` : title
      })
    }, 1000)

    $('time.timeago').timeago()

    $('.filter select').change(debounce(function() {
      $.ajax({
        url: $('.filter form').attr('action'),
        method: 'GET',
        data: {
          state: $('.filter #state').val().concat(''),
          room: $('.filter #room').val(),
          repository: $('.filter #repository').val().concat('')
        },
        dataType: 'script'
      })
    }))

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

    App.pull_request = App.cable.subscriptions.create("PullRequestChannel", {
      connected: function() {
        $('.offline-notification').hide(), notify()
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

        $(`${data.node} time.timeago`).timeago(), notify()
      }
    })
  })
}
