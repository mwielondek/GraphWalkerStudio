<vertex tabindex="0">
  <div class="label-div">
    <p class="label">{ label }</p>
  </div>


  var self = this

  self.defaults = {
    label: 'New Vertex',
    view: {
      width: 120,
      height: 80
    }
  };
  // Merge options with defaults into self
  $.extend(true, self, self.defaults, self.opts.options);

  self.on('update', function() {
    var css = {
      'height': self.view.height,
      'width': self.view.width,
      'top': self.view.centerY - (self.view.height / 2),
      'left': self.view.centerX - (self.view.width / 2)
    };
    $(self.root).css(css)
  })
</vertex>
