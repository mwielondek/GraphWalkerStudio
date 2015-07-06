<vertex tabindex="0">
  <div class="label-div">
    <p class="label">{ label }</p>
  </div>

  <style>
  vertex {
    background-color: rgba(140, 208, 196, 0.85);
    background-clip: padding-box;
    border: 1px solid black;
    position: absolute;
    display: table;
    border-radius: 15px;
  }

  vertex:focus {
    outline: none;
  }

  vertex.selected {
    border: 1px solid #21cfdf;
  }

  .label-div {
    display: table-cell;
    vertical-align: middle;
    text-align: center;
    padding: 10px;
  }

  .label {
    margin: 0;
    display: inline-block;
    min-width: 20px;
    min-height: 10pt;
  }

  .label:hover, .label:focus {
    background-color: rgba(210, 245, 248, 0.75);
    background-clip: content-box;
    outline: none;
  }

  .label::selection {
    background-color: #00c7c0;
  }
  </style>

  var $ = require('jquery');

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
