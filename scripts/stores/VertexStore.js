define(['riot'], function(riot) {
  return function ModelStore(vertices, edges) {
    var self = riot.observable(this)

    self.vertices = vertices || []
    self.edges = edges || []

    self.on('canvas_init', function() {
      self.trigger('vertex_change', self.vertices)
    })

    self.on('vertex_add', function(vertex) {
      self.vertices.push(vertex)
      self.trigger('vertex_change', self.vertices)
    })
  }
});
