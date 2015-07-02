<vertex>
  <p>V: { label }</p>

  var self = this

  self.on('update', function() {
    console.log("vertex on update called");
    // only update the css if view property present
    if (!self.view) return
    var css = $.extend({},self.view,{'position':'absolute'})
    $(self.root).find("p").css(css)
  })
</vertex>
