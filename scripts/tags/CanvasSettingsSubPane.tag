<canvas-settings-subpane>
  <h5>Canvas settings</h5>
  <ul>
    <li>
      Scroll zoom sensitivity
      <input name="sensitivity" type="range" onchange={ setSensitivity } />
      <span id="sensValue"></span>
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
  });

  setSensitivity() {
    var sensValue = this.sensValue.innerText = this.sensitivity.value;
    $.extend(this.opts.options, {canvas: {scrollIncrement: sensValue}})
  }

</canvas-settings-subpane>
