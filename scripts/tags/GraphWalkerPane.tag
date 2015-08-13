<graphwalker-pane>
  <ul>
    <li>Status: { opts.connected ? 'Connected' : 'Disconnected' }</li>
  </ul>

  var self = this;

  self.on('mount', function() {
    var headerElement = $(self.root).parents('sidebar-pane').find('h4');
    self.statusIcon = $('<span>')
      .addClass('octicon octicon-primitive-dot')
      .css('transition', 'color 400ms ease-out 100ms')
      .css('color', '#cd2828')
      .appendTo(headerElement);
  });

  self.on('updated', function() {
    if (self.isMounted) {
      self.statusIcon.css({
        'color': opts.connected ? '#15da52' : '#cd2828'
      });
    }
  });

</graphwalker-pane>
