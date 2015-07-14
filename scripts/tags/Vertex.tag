<vertex>
  <!-- TODO: remove dedicated vertex-div below and move attr to vertex tag above once riot/#924 fixed -->
  <div class="vertex { selected: opts.isselected } { status.toLowerCase() }" tabindex="0"
  id={ id } onclick={ onClickHandle }>
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
  var $root = $(self.root);

  self.defaults = {
    label: 'New Vertex',
    status: Constants.status.UNVERIFIED,
    view: {
      width: 120,
      height: 80
    }
  };

  self.one('update', function() {
    // TODO: write custom extend func without overwrite
    // (i.e. extend self with defaults but dont overwrite)
    var merged = $.extend(true, {}, self.defaults, self);
    $.extend(true, self, merged);
  });

  self.on('mount', function() {
    // Set style
    var css = {
      'height': self.view.height,
      'width': self.view.width,
      'top': self.view.centerY - (self.view.height / 2),
      'left': self.view.centerX - (self.view.width / 2)
    };
    $root.children('.vertex').css(css);

    // Make into jsPlumb source & target
    var vertexDiv = self.vertexDiv = $root.children('.vertex')[0];
    jsPlumb.makeSource(vertexDiv);
    jsPlumb.makeTarget(vertexDiv);

    // Make draggable
    jsp.draggable(vertexDiv, {
      start: function(params) {
        // Avoid setting listeners on vertices not being directly
        // dragged (i.e. dragged as part of selection but not under
        // the cursor => hence will not trigger click anyway)
        var isElementBeingDragged = params.e;
        if (!isElementBeingDragged) return;

        // Avoid resetting the selection by triggering the click
        // handler on mouseup.
        self.root.addEventListener('click', function handler(e) {
          e.stopPropagation();
          this.removeEventListener('click', handler, true);
        }, true);
      }
    });

    // MouseEvent multiplexing. Trigger click as usual, trigger
    // mousedown-n-drag only after the cursor has left the element.
    self.handleEvent = function(evt) {
      switch(evt.type) {
        case 'mousedown':
          // Stop propagation (i.e. triggering other handlers set by e.g. jsp)
          evt.stopPropagation();
          self.root.addEventListener('mouseleave', this, true);
          self.root.addEventListener('mouseup', this, true);
          break;

        case 'mouseup':
          self.root.removeEventListener('mouseleave', this, true);
          self.root.removeEventListener('mouseup', this, true);
          break;

        case 'mouseleave':
          // Don't trigger when hovering over child elements, e.g. label
          if (evt.target != vertexDiv) break;

          self.root.removeEventListener('mouseleave', this, true);
          self.root.removeEventListener('mouseup', this, true);

          // Allow the `mousedown` event to propagate
          self.root.removeEventListener('mousedown', this, true);

          // Re-trigger mousedown event
          vertexDiv.dispatchEvent(new MouseEvent('mousedown', evt));

          // Reactivate our event multiplexer
          self.root.addEventListener('mousedown', this, true);
          break;
      }
    };
    self.root.addEventListener('mousedown', this, true);

    // Trigger `updated` to set draggable/source/resize properties and
    // revalidate to set the correct offset for dragging connections.
    setTimeout(function() {
      // Run inside setTimeout to schedule it at the end of the
      // event queue so that the DOM redrawing has a chance to
      // catch up.
      jsp.revalidate(self.vertexDiv);
      self.trigger('updated');
    }, 0);
  });

  self.on('updated', function() {
    if (self.vertexDiv) {
      var selected = self.opts.isselected;
      // Default drag behaviour when selected is resize & move.
      jsp.setSourceEnabled(self.vertexDiv, !selected);
      jsp.setDraggable(self.vertexDiv, selected);
      var modifyEventListener = selected ? removeEventListener : addEventListener;
      modifyEventListener.call(self.root, 'mousedown', this, true);
    }
  });

  onClickHandle(e) {
    // Select vertex, or toggle its selection state
    // if meta key was down during the click.
    this.opts.onselect(this.id, e.metaKey);
  }
</vertex>
