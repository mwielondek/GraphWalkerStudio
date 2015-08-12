<graphwalker-pane>
  <ul>
    <li>Status: { opts.connected ? 'Connected' : 'Disconnected' }</li>
  </ul>

  this.on('mount', function() {
    this.headerElement = $(this.root).parents('sidebar-pane').find('span.icon');
    this.headerElement.css({
      'font-size': '18pt',
      'vertical-align': 'middle'
    });
  });

  this.on('updated', function() {
    if (this.isMounted) {
      this.headerElement.css({
        'color': opts.connected ? '#15da52' : '#cc0f0f'
      });
    }
  });

</graphwalker-pane>
