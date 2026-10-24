// Volumetric Celestial Beam & Laser Drop (OpenBot / LaserFlow Engine)
// Calibrated for Retina / High-DPI screens with dynamic window collision

(function () {
  const canvas = document.createElement('canvas');
  canvas.id = 'ambient-beam-canvas';
  canvas.style.position = 'fixed';
  canvas.style.top = '0';
  canvas.style.left = '0';
  canvas.style.width = '100vw';
  canvas.style.height = '100vh';
  canvas.style.pointerEvents = 'none';
  canvas.style.zIndex = '1';
  canvas.style.opacity = '1.0';
  document.body.prepend(canvas);

  const gl = canvas.getContext('webgl', { alpha: true, antialias: false, depth: false });
  if (!gl) {
    console.warn('WebGL not supported');
    return;
  }

  const vsSource = `
    attribute vec2 a_position;
    void main() {
      gl_Position = vec4(a_position, 0.0, 1.0);
    }
  `;

  const fsSource = `
    precision highp float;
    uniform vec2 u_resolution;
    uniform float u_dpr;
    uniform float u_time;
    uniform vec2 u_beam_origin;
    uniform vec4 u_window_rect; // left, top, right, bottom in CSS screen pixels
    uniform float u_drop_progress; // 0.0 = not started, 0.0 -> 1.0 = dropping, 1.0 = impacted
    uniform float u_impact_time;   // elapsed time since impact

    float hash(vec2 p) {
      p = fract(p * vec2(123.34, 456.21));
      p += dot(p, p + 45.32);
      return fract(p.x * p.y);
    }

    float noise(vec2 p) {
      vec2 i = floor(p);
      vec2 f = fract(p);
      vec2 u = f * f * (3.0 - 2.0 * f);
      return mix(
        mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
        mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x),
        u.y
      );
    }

    float fbm(vec2 p) {
      float v = 0.0;
      float a = 0.5;
      mat2 m = mat2(1.6, 1.2, -1.2, 1.6);
      for (int i = 0; i < 4; i++) {
        v += a * noise(p);
        p = m * p;
        a *= 0.5;
      }
      return v;
    }

    float sq(float x) {
      return x * x;
    }

    float roundBox(vec2 p, vec2 b, float r) {
      vec2 q = abs(p) - b + r;
      return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
    }

    void main() {
      // Calibrated Retina Pixel-to-CSS mapping
      vec2 coord = vec2(gl_FragCoord.x, u_resolution.y * u_dpr - gl_FragCoord.y) / u_dpr;
      
      // If drop has not started, return totally black/transparent
      if (u_drop_progress <= 0.001) {
        gl_FragColor = vec4(0.0);
        return;
      }

      float t = u_time;
      float beamX = u_beam_origin.x;
      float sourceY = u_beam_origin.y;
      
      // Window bounds
      vec2 winTopLeft = u_window_rect.xy;
      vec2 winBottomRight = u_window_rect.zw;
      vec2 winCenter = (winTopLeft + winBottomRight) * 0.5;
      vec2 winHalfSize = (winBottomRight - winTopLeft) * 0.5;
      float radius = 16.0;

      float distToWindow = roundBox(coord - winCenter, winHalfSize, radius);

      // Palette: AntiGamba Signature Luminescence
      vec3 COLOR_WHITE = vec3(1.0, 1.0, 1.0);
      vec3 COLOR_ORANGE = vec3(0.98, 0.40, 0.22); // #FA6538
      vec3 COLOR_AMBER = vec3(1.0, 0.76, 0.42);  // #FFC26B
      vec3 COLOR_CYAN = vec3(0.45, 0.82, 1.0);   // Electric accent

      float dx = coord.x - beamX;
      float adx = abs(dx);

      // --- 1. ENTRANCE & DESCENT KINEMATICS ---
      // Head position of the falling laser dart
      float targetY = winTopLeft.y;
      float headY = mix(sourceY, targetY, u_drop_progress);

      // Strict downward cut: light only exists above or at the descending head
      float belowHead = coord.y - headY;
      if (u_drop_progress < 1.0 && belowHead > 20.0) {
        gl_FragColor = vec4(0.0);
        return;
      }

      // Smooth cutoff at the laser tip
      float headCutoff = 1.0 - smoothstep(-2.0, 16.0, belowHead);

      // Glowing comet dart head
      float distToHead = abs(coord.y - headY);
      float headBloom = exp(-sq(distToHead / 32.0)) * exp(-sq(dx / 14.0));
      float headCore = exp(-sq(distToHead / 10.0)) * exp(-sq(dx / 4.0));

      // --- 2. CONTINUOUS VERTICAL SHAFT ---
      float beamWidth = 2.6;
      float core = 14.0 * exp(-adx / (beamWidth * 2.2));
      float halo = 1.3 * exp(-adx / (beamWidth * 14.0)) + 0.3 * exp(-adx / (beamWidth * 42.0));

      // Drifting atmospheric smoke
      vec2 smokeUV = vec2(dx * 0.006, coord.y * 0.003 - t * 0.16);
      float smoke = fbm(smokeUV * 3.0);

      // Attenuation above window and at top button
      float aboveWin = smoothstep(winTopLeft.y + 35.0, winTopLeft.y - 25.0, coord.y);
      float topFade = smoothstep(0.0, 50.0, coord.y);

      // Trailing growth: beam brightness ramps up as head passes
      float trailRamp = smoothstep(headY - 260.0, headY, coord.y);

      vec3 col = vec3(0.0);

      // Main beam composition
      float beamIntensity = min(u_drop_progress * 1.5, 1.0);
      col += (COLOR_WHITE * core * 0.75 + mix(COLOR_ORANGE, COLOR_CYAN, smoke) * halo) 
             * topFade 
             * (0.6 + 0.4 * aboveWin) 
             * headCutoff 
             * beamIntensity;

      // Add intense comet dart head while dropping
      if (u_drop_progress < 1.0) {
        col += (COLOR_WHITE * headCore * 8.0 + COLOR_AMBER * headBloom * 5.0) * headCutoff;
      }

      // --- 3. IMPACT IGNITION & TITLEBAR HORIZON SPILL ---
      if (u_drop_progress >= 0.99) {
        float impT = u_impact_time;

        // A. Initial Impact Flash at (beamX, winTopLeft.y)
        float distToImpact = length(coord - vec2(beamX, winTopLeft.y));
        float impactFlash = exp(-distToImpact / (24.0 + impT * 40.0)) * exp(-impT * 3.5);
        col += (COLOR_WHITE * 6.0 + COLOR_AMBER * 4.0) * impactFlash;

        // B. Titlebar Horizon Light Spill
        float edgeDist = abs(coord.y - winTopLeft.y);
        
        // Spill runs along the top border from beamX to the left
        float withinWinX = smoothstep(winTopLeft.x - 12.0, winTopLeft.x + 40.0, coord.x)
                         * (1.0 - smoothstep(winBottomRight.x - 20.0, winBottomRight.x + 12.0, coord.x));

        if (withinWinX > 0.01 && edgeDist < 60.0) {
          float spillDist = abs(coord.x - beamX);
          float spillReach = 180.0 + min(impT * 400.0, 520.0);
          float sweep = exp(-spillDist / spillReach);

          // Thin bright specular wire along top border
          float wire = exp(-sq(edgeDist / 3.0));
          float glow = exp(-sq(edgeDist / 16.0));

          // Subtle moving photons along the wire
          float wave = 0.85 + 0.15 * sin(coord.x * 0.04 - t * 4.0);

          vec3 spillCol = COLOR_WHITE * wire * sweep * 2.2 * wave;
          spillCol += mix(COLOR_ORANGE, COLOR_AMBER, 0.6) * glow * sweep * 1.4;

          col += spillCol * withinWinX;
        }

        // C. Ambient Outer Perimeter Rim
        if (distToWindow >= -0.5 && distToWindow < 8.0) {
          float rimGlow = exp(-distToWindow / 2.5) * exp(-adx / 180.0);
          col += (COLOR_WHITE * 0.7 + COLOR_ORANGE * 0.5) * rimGlow;
        }
      }

      // --- 4. WINDOW MASK ---
      // Keep inside of the video preview 100% crisp and unpolluted
      if (distToWindow < -0.5) {
        col *= smoothstep(-0.5, 1.5, distToWindow);
      }

      // --- 5. SOURCE BLOOM AT TOP RIGHT BUTTON ---
      float distToSource = length(coord - vec2(beamX, sourceY));
      float sourceBloom = (exp(-distToSource / 24.0) * 2.2 + exp(-distToSource / 75.0) * 0.8) 
                        * min(u_drop_progress * 1.8, 1.0);
      col += mix(COLOR_ORANGE, COLOR_WHITE, 0.65) * sourceBloom;

      // Tone mapping & Dither
      vec3 emit = 1.0 - exp(-col);
      float dither = (hash(gl_FragCoord.xy) - 0.5) / 255.0;
      emit += dither;

      gl_FragColor = vec4(emit, max(emit.r, max(emit.g, emit.b)) * 0.95);
    }
  `;

  function createShader(gl, type, source) {
    const shader = gl.createShader(type);
    gl.shaderSource(shader, source);
    gl.compileShader(shader);
    if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
      console.error('Shader compile error:', gl.getShaderInfoLog(shader));
      gl.deleteShader(shader);
      return null;
    }
    return shader;
  }

  const vertexShader = createShader(gl, gl.VERTEX_SHADER, vsSource);
  const fragmentShader = createShader(gl, gl.FRAGMENT_SHADER, fsSource);
  const program = gl.createProgram();
  gl.attachShader(program, vertexShader);
  gl.attachShader(program, fragmentShader);
  gl.linkProgram(program);

  if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
    console.error('Program link error:', gl.getProgramInfoLog(program));
    return;
  }

  gl.useProgram(program);

  const positionBuffer = gl.createBuffer();
  gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);
  gl.bufferData(
    gl.ARRAY_BUFFER,
    new Float32Array([
      -1, -1,
       1, -1,
      -1,  1,
      -1,  1,
       1, -1,
       1,  1,
    ]),
    gl.STATIC_DRAW
  );

  const aPositionLocation = gl.getAttribLocation(program, 'a_position');
  gl.enableVertexAttribArray(aPositionLocation);
  gl.vertexAttribPointer(aPositionLocation, 2, gl.FLOAT, false, 0, 0);

  const uResolutionLocation = gl.getUniformLocation(program, 'u_resolution');
  const uDprLocation = gl.getUniformLocation(program, 'u_dpr');
  const uTimeLocation = gl.getUniformLocation(program, 'u_time');
  const uBeamOriginLocation = gl.getUniformLocation(program, 'u_beam_origin');
  const uWindowRectLocation = gl.getUniformLocation(program, 'u_window_rect');
  const uDropProgressLocation = gl.getUniformLocation(program, 'u_drop_progress');
  const uImpactTimeLocation = gl.getUniformLocation(program, 'u_impact_time');

  let width = 0;
  let height = 0;
  let dpr = 1;

  function resize() {
    width = window.innerWidth;
    height = window.innerHeight;
    dpr = window.devicePixelRatio || 1;
    canvas.width = Math.round(width * dpr);
    canvas.height = Math.round(height * dpr);
    gl.viewport(0, 0, canvas.width, canvas.height);
  }

  window.addEventListener('resize', resize);
  resize();

  // Entrance Sequence Timing:
  // 0.00s - 0.25s: Blank / Clean load
  // 0.25s - 1.25s: Laser drop descent (1.0s)
  // 1.25s+: Impact & continuous illumination
  const startTime = performance.now();
  const DELAY_SEC = 0.25;
  const DROP_DURATION = 1.0;

  function render() {
    const now = performance.now();
    const elapsed = (now - startTime) * 0.001;

    let dropProgress = 0.0;
    let impactTime = 0.0;

    if (elapsed > DELAY_SEC) {
      const dropRaw = (elapsed - DELAY_SEC) / DROP_DURATION;
      if (dropRaw < 1.0) {
        // Cubic ease-out descent
        dropProgress = 1.0 - Math.pow(1.0 - dropRaw, 3.0);
      } else {
        dropProgress = 1.0;
        impactTime = elapsed - (DELAY_SEC + DROP_DURATION);
      }
    }

    // Anchor beam directly to Download button
    const navBtn = document.querySelector('header a[href*="download"]');
    const macWindow = document.querySelector('.macos-window');

    let winRect = [width * 0.1, height * 0.5, width * 0.9, height * 0.95];
    if (macWindow) {
      const rect = macWindow.getBoundingClientRect();
      winRect = [rect.left, rect.top, rect.right, rect.bottom];
    }

    let beamX = width * 0.85;
    let beamY = 36;

    if (navBtn) {
      const rect = navBtn.getBoundingClientRect();
      beamX = rect.left + rect.width * 0.5;
      beamY = rect.bottom;
    }

    // Align beam safely onto the top rim of the window
    if (macWindow) {
      beamX = Math.min(Math.max(beamX, winRect[0] + 40), winRect[2] - 40);
    }

    gl.uniform2f(uResolutionLocation, width, height);
    gl.uniform1f(uDprLocation, dpr);
    gl.uniform1f(uTimeLocation, elapsed);
    gl.uniform2f(uBeamOriginLocation, beamX, beamY);
    gl.uniform4f(uWindowRectLocation, winRect[0], winRect[1], winRect[2], winRect[3]);
    gl.uniform1f(uDropProgressLocation, dropProgress);
    gl.uniform1f(uImpactTimeLocation, impactTime);

    gl.drawArrays(gl.TRIANGLES, 0, 6);

    requestAnimationFrame(render);
  }

  requestAnimationFrame(render);
})();
