<vertex tabindex="0">
  <div class="label-div">
    <p class="label">{ label }</p>
  </div>


  var self = this

  self.on('update', function() {
    // only update the css if view property present
    if (!self.view) return
    var css = $.extend({},self.view,{'position':'absolute'})
    $(self.root).css(css)
  })
</vertex>
