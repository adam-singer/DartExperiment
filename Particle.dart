// A particle class
// Simulated using verlet integration.
class Particle
{
  Vec2 _pos;
  Vec2 _lastPos;
  Vec2 _acceleration;
  
  Particle(Vec2 pos)
  {
    _pos = pos;
    _lastPos = pos;
    _acceleration = new Vec2.zero();
  }
  
  Vec2 get position() => _pos;
  
  void set position(Vec2 value)
  {
    _pos = value;
  }
  
  Vec2 getVelocity()
  {
    return (_pos - _lastPos) / Builder.targetDeltaTime;
  }
  
  void setVelocity(Vec2 value)
  {
    _lastPos = _pos - value * Builder.targetDeltaTime;
  }
  
  void addAcceleration(Vec2 acceleration)
  {
    _acceleration += acceleration;
  }
  
  void update()
  {
    Vec2 velocity = getVelocity();
    
    // Update velocity
    velocity += _acceleration * Builder.targetDeltaTime;
    
    // Update position
    _lastPos = _pos;
    _pos += velocity * Builder.targetDeltaTime;
    
    // Clear frame acceleration
    _acceleration = new Vec2.zero();
  }
  
  void keepWithinBounds()
  {
    // Handle left and right walls
    if (_pos.x < Builder.left)
    {
      _pos = new Vec2(Builder.left, _pos.y);
    }
    else if (_pos.x > Builder.right)
    {
      _pos = new Vec2(Builder.right, _pos.y);
    }
    
    // Handle bottom floor
    if (_pos.y > Builder.bottom)
    {
      Vec2 normal = new Vec2(1.0, 0.0);
      double depth = _pos.y - Builder.bottom;
      
      // Apply bounds constraint
      _pos = new Vec2(_pos.x, Builder.bottom);
      
      // Apply friction
      double friction = depth * 15.0;
      
      Vec2 velocity = getVelocity();
      Vec2 tangentVelocity = velocity - normal * Vec2.dot(normal, velocity);
      
      if (friction < tangentVelocity.length())
      {
        velocity -= tangentVelocity.normalized() * friction;
      }
      else
      {
        velocity = new Vec2.zero();
      }
      
      setVelocity(velocity);
    }
  }
}