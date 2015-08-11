<canvas-settings-subpane>
  <h5>Canvas settings</h5>
  <ul>
    <li>
      Scroll zoom sensitivity<br>
      <input name="sensitivity" type="range" onchange={ setSensitivity } />
      <span id="sensValue"></span>
    </li>
    <li>
      Show minimap
      <input name="minimap" type="checkbox" onchange={ setMinimap } />
    </li>
  </ul>

  this.on('mount', function() {
    $.extend(this.sensitivity, {
      max: 1,
      min: 0.01,
      step: 0.01,
      value: opts.options.canvas && opts.options.canvas.scrollIncrement || 0.3
    });
    this.setSensitivity();

    this.minimap.checked = this.opts.options.canvas.minimap;
  });

  setSensitivity() {
    var sensValue = this.sensValue.innerHTML = this.sensitivity.value;
    $.extend(true, this.opts.options, {canvas: {scrollIncrement: sensValue}})
  }

  setMinimap() {
    $.extend(true, this.opts.options, {canvas: {minimap: this.minimap.checked}})
    riot.update();
  }

</canvas-settings-subpane>
