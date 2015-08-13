<graphwalker-pane>
  <ul>
    <li>Status: { opts.connected ? 'Connected' : 'Disconnected' }</li>
  </ul>

  this.on('mount', function() {
    var headerElement = $(this.root).parents('sidebar-pane').find('h4');
    this.statusIcon = $('<span>')
      .addClass('octicon octicon-primitive-dot')
      .css('transition', 'color 400ms ease-out 100ms')
      .css('color', '#cd2828')
      .appendTo(headerElement);
  });

  this.on('updated', function() {
    if (this.isMounted) {
      this.statusIcon.css({
        'color': opts.connected ? '#15da52' : '#cd2828'
      });
    }
  });

</graphwalker-pane>
