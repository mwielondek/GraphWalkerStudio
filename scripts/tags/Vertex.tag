<vertex>
  <!-- TODO: remove dedicated vertex-div below and move attr to vertex tag above once riot/#924 fixed -->
  <div class="vertex { selected: opts.isselected } { status.toLowerCase() }" tabindex="0" onclick={ onClickHandle }>
    <div class="label-div">
      <p class="label">{ label }</p>
    </div>
  </div>

  <style>
  .vertex {
    background-clip: padding-box;
    border: 1px solid black;
    position: absolute;
    display: table;
    border-radius: 15px;
  }

  .vertex:focus {
    outline: none;
  }

  .vertex.selected {
    border: 1px solid #21cfdf;
  }

  .vertex.unverified {
    background-color: rgba(255, 163, 42, 0.85);
  }

  .vertex.verified {
    background-color: rgba(20, 187, 107, 0.85);
  }

  .vertex.error {
    background-color: rgba(221, 72, 72, 0.85);
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
  var jsp = require('jsplumb');
  var Constants = require('constants/VertexConstants');

  var self = this

  self.defaults = {
    label: 'New Vertex',
    status: Constants.status.UNVERIFIED,
    view: {
      width: 120,
      height: 80
    }
  };

  self.one('update', function() {
    // Merge defaults into self. Can't be done 'on mount' since the
    // attributes have not been computed yet (specifically self.view).

    // TODO: write custom extend func without overwrite
    // (i.e. extend self with defaults but dont overwrite)
    var merged = $.extend(true, {}, self.defaults, self);
    $.extend(true, self, merged);

    // Make into jsPlumb source & target
    jsPlumb.makeSource($(this.root).children('.vertex')[0]);
  });

  self.on('update', function() {
    var css = {
      'height': self.view.height,
      'width': self.view.width,
      'top': self.view.centerY - (self.view.height / 2),
      'left': self.view.centerX - (self.view.width / 2)
    };
    $(self.root).children('.vertex').css(css);
  });

  onClickHandle(e) {
    // Select vertex, or toggle its selection state
    // if meta key was down during the click.
    this.opts.onselect(this.id, e.metaKey);
  }
</vertex>
