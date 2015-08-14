<graphwalker-pane>
  <ul>
    <li if={ errorMessage }>
      <div class="bg-warning"><span class="octicon octicon-alert"></span> { errorMessage }</div>
    </li>
    <li><b>Status:</b><br> { opts.connected ? 'Connected' : 'Disconnected' }</li>
    <li>
      <button show={ opts.connected && opts.model.id && !running } onclick={ startRunning } class="green">
        <span class="octicon octicon-rocket"></span>
        Run model
      </button>
      <button show={ opts.connected && running } onclick={ stopRunning } class="red">
        <span class="octicon octicon-primitive-square"></span>
        Stop
      </button>
    </li>
  </ul>

  var Actions = require('actions/GraphWalkerActions');

  var self = this;

  self.running = false;

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

  startRunning() {
    delete self.errorMessage;
    var modelId = opts.model.id;
    Actions.startRunningModel(modelId, function(success, response) {
      if (!success) {
        self.errorMessage = response;
        self.update();
      } else {
        // TODO
        self.running = true;
      }
    });
  }

  stopRunning() {
    self.running = false;
    Actions.stopRunningModel();
  }

</graphwalker-pane>
