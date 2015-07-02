<studio-canvas>

  <vertex each={ vertices } />

  var self = this

  self.vertices = []

  RiotControl.on('vertex_change', function(vertices) {
    self.vertices = vertices
    self.update()
  })

  self.on('mount', function() {
    // Load vertices from model store
    RiotControl.trigger('canvas_init')

    // Set up event listeners


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
