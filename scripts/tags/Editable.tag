<editable onclick={ click }>
  <span show={ !editing }>
    <yield/>
  </span>

  <style scoped>
    span {
      cursor: pointer;
    }
    input[type='text'] {
      border: none;
      border-bottom: solid 4px #c9c9c9;
      outline: none;
    }
  </style>

  var ENTER_KEY = 13;
  var ESC_KEY = 27;

  var self = this;

  this.editing = false;

  self.on('mount', function() {
    // Create editable element
    var editControl = (function() {
      switch (self.opts.type) {
        case 'text':
          return $('<input>').attr({ type: 'text', name: 'editable', autofocus: true});
      }
    })();

    editControl.on('change blur keydown', function(e) {
      switch (e.type) {
        case 'keydown':
          if (e.keyCode == ENTER_KEY || e.keyCode == ESC_KEY) this.blur();
          break;
        case 'change':
          // Call callback with new value
          self.opts.callback(e.target.value);
        case 'blur':
          self.editing = false;
          self.update();
      }
    });

    $(self.root).append(editControl);
    editControl.hide();

    self.editControl = editControl;
  });

  self.on('updated', function() {
    if (self.isMounted) {
      self.editControl.toggle(self.editing);
      if (self.editing) self.editControl.select();
    }
  });

  click(e) {
    // Don't do anything when already editing
    if (self.editing) {
      e.preventUpdate = true;
      return;
    }

    // Otherwise switcht to edit mode
    self.editing = true;
    self.editControl.val(self.root.innerText);
  }
</editable>