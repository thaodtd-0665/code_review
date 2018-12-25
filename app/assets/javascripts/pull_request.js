if (location.pathname == '/pull_requests') {
  $(function() {
    FaviconNotification.init({
      color: '#ffc700',
      lineColor:'#feecad'
    })

    function debounce(cb, time = 250, interval) {
      return function(...args) {
        clearTimeout(interval)
        interval = setTimeout(cb, time, ...args)
      }
    }

    let title = document.title
    let ready = new Audio('ready.ogg')

    let notify = debounce(function() {
      $.ajax({
        url: '/pull_requests/status',
        method: 'GET',
        data: {
          room: $('.filter #room').val().concat(''),
          repository: $('.filter #repository').val().concat('')
        },
        dataType: 'json'
      }).done(function(data) {
        if (data.count > 0) {
          FaviconNotification.add()
          document.title = `(${data.count}) ${title}`
        } else {
          FaviconNotification.remove()
          document.title = title
        }
      })
    }, 1000)

    $('time.timeago').timeago()

    $('.filter select').change(debounce(function() {
      $.ajax({
        url: $('.filter form').attr('action'),
        method: 'GET',
        data: {
          state: $('.filter #state').val().concat(''),
          room: $('.filter #room').val().concat(''),
          repository: $('.filter #repository').val().concat('')
        },
        dataType: 'script'
      })
    })).change(notify)

    $('.js-states').select2({
      placeholder: '',
      allowClear: true,
      theme: 'bootstrap4'
    })

    $('.js-rooms').select2({
      placeholder: '',
      allowClear: true,
      theme: 'bootstrap4'
    })

    $('.js-repositories').select2({
      placeholder: '',
      allowClear: true,
      theme: 'bootstrap4',
      ajax: {
        delay: 500,
        url: '/repositories'
      }
    })

    App.pull_request = App.cable.subscriptions.create("PullRequestChannel", {
      connected: function() {
        notify()
      },
      disconnected: function() {
        location.reload()
      },
      received: function(data) {
        let elm = `#pull-request-${data.id}`

        if ($(elm).length) {
          data.deleted ? $(elm).remove() : $(elm).replaceWith(data.html)
        } else {
          let states = $('.filter #state').val(),
              room_ids = $('.filter #room').val(),
              repository_ids = $('.filter #repository').val()

          if (!states.includes(data.state))
            return

          if (!(room_ids.length == 0 || room_ids.includes(data.room_id)))
            return

          if (!(repository_ids.length == 0 || repository_ids.includes(data.repository_id)))
            return

          $('tbody').prepend(data.html)
        }

        $(`${elm} time.timeago`).timeago(), notify()

        if (data.state == "1")
          ready.play().catch(err => {
            // console.log(err)
          })
      }
    })
  })
}
