<graphwalker-pane>
  <ul>
    <li>Status: { opts.connected ? 'Connected' : 'Disconnected' }</li>
  </ul>

  <style>
    #connection-status {
      color: #cc0f0f;
      font-size: 8pt;
      vertical-align: text-top;
      margin-right: 5px;
    }
    #connection-status.connected {
      color: #15da52;
    }
  </style>

  this.on('mount', function() {
    var headerElement = $(this.root).parents('sidebar-pane').find('h4');
    headerElement.prepend('<span id="connection-status">\u2B24</span>');
  });

  this.on('updated', function() {
    if (this.isMounted) {
      var headerElement = $(this.root).parents('sidebar-pane').find('h4');
      headerElement.find('#connection-status').toggleClass('connected', opts.connected);
    }
  });

</graphwalker-pane>
