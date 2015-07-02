function ModelStore(vertices, edges) {
  riot.observable(this)

  var self = this

  self.vertices = vertices || []
  self.edges = edges || []

  self.on('canvas_init', function() {
    self.trigger('vertex_change', self.vertices)
  })

  self.on('vertex_add', function(vertex) {
    console.log("vertex_add: ", vertex);
    self.vertices.push(vertex)
    self.trigger('vertex_change', self.vertices)
  })
}
