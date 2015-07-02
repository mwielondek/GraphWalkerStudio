<studio-canvas>
  <p>Canvas</p>

  <vertex each={ vertices } />

  var self = this

  self.debug = true

  self.vertices = []

  RiotControl.on('vertex_change', function(vertices) {
    console.log("vertex change");
    self.vertices = vertices
    self.update()
  })

  self.on('mount', function() {
    RiotControl.trigger('canvas_init')
  })

  addVertex(e) {
    // sa[0].tags['studio-canvas'].addVertex()
    var vertex = {
      view: {
        top: 10,
        left: 200
      },
      label: 'New'
    }
    RiotControl.trigger('vertex_add', vertex)
  }
</studio-canvas>
