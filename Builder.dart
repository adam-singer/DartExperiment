#import("dart:dom");
#source("Vec2.dart");
#source("Particle.dart");
#source("Constraint.dart");

class Builder
{
  // Constants
  static final double width = 1024.0;
  static final double height = 512.0;
  static final double left = 3.0;
  static final double right = width - 3.0;
  static final double bottom = height - 3.0;
  
  static final double targetDeltaTime = 0.02;
  
  static final double buttonRadius = 50.0;
  static final double particleRadius = 10.0;
  
  // HTML
  HTMLCanvasElement _canvas;
  CanvasRenderingContext2D _context;
  
  // Mouse
  Vec2 _mouse;
  bool _mouseButton = false;
  bool _lastMouseButton = false;
  bool _mouseDown = false;
  bool _mouseUp = false;
  
  // Timing
  double _accumulatedDeltaTime = 0.0;
  int _lastFrameTime = null;
  
  // General
  List<Particle> particles;
  List<Constraint> constraints;
  
  int _mode = 0;
  Particle _selectedParticle = null;
  
  Builder()
  {
    // Initialize canvas
    _canvas = window.document.getElementById("canvas");
    _context = _canvas.getContext("2d");
    
    // Initialize mouse input
    _mouse = new Vec2.zero();
    
    window.document.addEventListener("mousemove", (MouseEvent event)
    {
      _mouse = new Vec2(event.offsetX.toDouble(), event.offsetY.toDouble());
    });
    
    window.document.addEventListener("mousedown", (MouseEvent event)
    {
      _mouseButton = true;
      _lastMouseButton = false;
    });
    
    window.document.addEventListener("mouseup", (MouseEvent event)
    {
      _mouseButton = false;
      _lastMouseButton = true;
    });
  }
  
  void spawnBox(Vec2 target, int w, int h, double cellSize)
  {
    List<Particle> p = new List<Particle>(w * h);
    
    // Add width * height number of particles
    for (int j = 0; j < h; j++)
    {
      for (int i = 0; i < w; i++)
      {
        Particle particle = new Particle(target + new Vec2(i * cellSize, j * cellSize));
        
        p[j * w + i] = particle;
        
        particles.add(particle);
      }
    }
    
    // Add constraints to each cell
    for (int i = 0; i < w - 1; i++)
    {
      for (int j = 0; j < h - 1; j++)
      {
        // Add straight constraints
        addUniqueConstraint(p[(j + 0) * w + i + 0], p[(j + 0) * w + i + 1]);
        addUniqueConstraint(p[(j + 0) * w + i + 0], p[(j + 1) * w + i + 0]);
        addUniqueConstraint(p[(j + 1) * w + i + 1], p[(j + 0) * w + i + 1]);
        addUniqueConstraint(p[(j + 1) * w + i + 1], p[(j + 1) * w + i + 0]);
        
        // Add diagonals
        addUniqueConstraint(p[(j + 0) * w + i + 0], p[(j + 1) * w + i + 1]);
        addUniqueConstraint(p[(j + 1) * w + i + 0], p[(j + 0) * w + i + 1]);
      }
    }
  }
  
  Particle findClosestParticle(Vec2 target)
  {
    // Find the particle that is closest to the target
    Particle particle = null;
    double minDistance = 0.0;
    
    for (Particle p in particles)
    {
      double distance = Vec2.distance(target, p.position);
      
      if (distance < minDistance || particle == null)
      {
        particle = p;
        minDistance = distance;
      }
    }
    
    return particle;
  }
  
  void addUniqueConstraint(Particle a, Particle b)
  {
    for (Constraint c in constraints)
    {
      if ((c.a == a && c.b == b) ||
          (c.a == b && c.b == a))
      {
        return;
      }
    }
    
    constraints.add(new Constraint(a, b));
  }
  
  void handleMouse()
  {
    // Update per-frame dependent values
    _mouseDown = _mouseButton && !_lastMouseButton;
    _mouseUp = !_mouseButton && _lastMouseButton;
    
    _lastMouseButton = _mouseButton;
  }
  
  void handleStateChanges()
  {
    if (_mouseDown)
    {
      if (Vec2.distance(_mouse, new Vec2.zero()) <= buttonRadius)
      {
        // Change mode
        _mode++;
        
        if (_mode > 2)
        {
          _mode = 0;
        }
        
        // Reset selected particle
        _selectedParticle = null;
      }
    }
  }
  
  void handlePlayMode()
  {
    // Update particles
    for (Particle p in particles)
    {
      p.addAcceleration(new Vec2(0.0, 512.0));
      
      p.update();
    }
    
    // Apply constraints
    for (int i = 0; i < 3; i++)
    {
      for (Particle p in particles)
      {
        p.keepWithinBounds();
      }
      
      for (Constraint c in constraints)
      {
        c.apply();
      }
    }
    
    // Handle mouse interaction
    if (_mouseButton && _mouse.y > buttonRadius)
    {
      if (_selectedParticle == null)
      {
        _selectedParticle = findClosestParticle(_mouse);
      }
      else
      {
        // Move the selected particle
        _selectedParticle.position = _mouse;
      }
    }
    else
    {
      // Release the selected particle
      _selectedParticle = null;
    }
  }
  
  void handleBuildMode()
  {
    if (_mouseDown && _mouse.y > buttonRadius)
    {
      Particle closestParticle = findClosestParticle(_mouse);
      
      // Did the user click on a particle?
      if (Vec2.distance(_mouse, closestParticle.position) <= particleRadius)
      {
        if (_selectedParticle == null)
        {
          // Select the closest particle
          _selectedParticle = closestParticle;
        }
        else
        {
          // Create a constraint between the two particles
          if (_selectedParticle != closestParticle)
          {
            addUniqueConstraint(_selectedParticle, closestParticle);
            
            _selectedParticle = null;
          }
        }
      }
      else
      {
        // The user didn't click on a particle
        if (_selectedParticle == null)
        {
          // Create a new particle
          particles.add(new Particle(_mouse));
        }
        else
        {
          _selectedParticle = null;
        }
      }
    }
  }
  
  void handleBoxMode()
  {
    if (_mouseDown && _mouse.y > buttonRadius)
    {
      spawnBox(_mouse, 3, 2, 40.0);
    }
  }
  
  void setup()
  {
    // Setup
    particles = new List<Particle>();
    constraints = new List<Constraint>();
    
    // Spawn 2 boxes
    spawnBox(new Vec2(100.0, 200.0), 2, 2, 80.0);
    spawnBox(new Vec2(300.0, 100.0), 3, 3, 40.0);
  }
  
  void update()
  {
    handleMouse();
    
    handleStateChanges();
    
    if (_mode == 0)
    {
      handlePlayMode();
    }
    else if (_mode == 1)
    {
      handleBuildMode();
    }
    else if (_mode == 2)
    {
      handleBoxMode();
    }
  }
  
  void drawCircle(Vec2 position, double radius)
  {
    _context.beginPath();
    _context.arc(position.x, position.y, radius, 0, Math.PI * 2.0, false);
    _context.stroke();
    _context.fill();
    _context.closePath();
  }
  
  void drawOutline()
  {
    _context.setFillColor("BLACK");
    _context.fillRect(0, 0, 2.0, height);
    _context.fillRect(width - 2.0, 0, 2, height);
    _context.fillRect(0, height - 2.0, width, 2);
  }
  
  void drawConstraints()
  {
    _context.setStrokeColor("BLACK");
    _context.setLineWidth(2);
    
    _context.beginPath();
    
    for (Constraint c in constraints)
    {
      _context.moveTo(c.a.position.x, c.a.position.y);
      _context.lineTo(c.b.position.x, c.b.position.y);
      _context.stroke();
    }
    
    _context.closePath();
  }
  
  void drawParticles()
  {
    _context.setFillColor("WHITE");
    _context.setStrokeColor("BLACK");
    _context.setLineWidth(4);
    
    // Only render the particles in the build and box modes
    if (_mode != 0)
    {
      for (Particle p in particles)
      {
        drawCircle(p.position, particleRadius);
      }
    }
    
    // Render the selected particle
    if (_selectedParticle != null)
    {
      _context.setFillColor("LIGHTBLUE");
      
      drawCircle(_selectedParticle.position, particleRadius);
    }
  }
  
  void drawUserInterface()
  {
    // Draw button
    _context.setFillColor("WHITE");
    _context.setStrokeColor("BLACK");
    _context.setLineWidth(4);
    
    drawCircle(new Vec2.zero(), buttonRadius);
    
    // Draw button text
    _context.setFillColor("BLACK");
    
    // A static list won't compile at the moment
    String text = "";
    
    if (_mode == 0)
    {
      text = "PLAY";
    }
    else if (_mode == 1)
    {
      text = "BUILD";
    }
    else if (_mode == 2)
    {
      text = "BOX";
    }
    
    _context.fillText(text, 5, 20, 100);
  }
  
  void draw()
  {
    _context.clearRect(0, 0, width, height);
    
    drawOutline();
    
    drawConstraints();
    
    drawParticles();
    
    drawUserInterface();
  }
  
  void run()
  {
    setup();
    
    // Start the game loop
    window.webkitRequestAnimationFrame(gameLoop, _canvas);
  }
  
  void gameLoop(int time)
  {
    // Handle the first frame
    if (_lastFrameTime == null)
    {
      _lastFrameTime = time;
    }
    
    // Calculate delta time
    double deltaTime = (time - _lastFrameTime) * 0.001;
    _lastFrameTime = time;
    
    // Update when necessary (fixed time step)
    _accumulatedDeltaTime += deltaTime;
    
    if (_accumulatedDeltaTime >= targetDeltaTime)
    {
      update();
      
      _accumulatedDeltaTime -= targetDeltaTime;
    }
    
    // Always draw
    draw();
    
    // Register for the next frame
    window.webkitRequestAnimationFrame(gameLoop, _canvas);
  }
}

void main()
{
  Builder builder = new Builder();
  
  builder.run();
}