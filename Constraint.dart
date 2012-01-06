// A simple stick constraint class
class Constraint
{
  Particle _a, _b;
  double distance;
  
  Constraint(Particle a, Particle b)
  {
    _a = a;
    _b = b;
    distance = Vec2.distance(_a.position, _b.position);
  }
  
  Particle get a() => _a;
  
  void set a(Particle v) { a = v; }
  
  Particle get b() => _b;
  
  void set b(Particle v) { b = v; }
  
  void apply()
  {
    Vec2 posA = _a.position;
    Vec2 posB = _b.position;
    
    Vec2 delta = posB - posA;
    
    double correction = (delta.length() - distance) * 0.5 * 0.2;
    
    Vec2 direction = delta.normalized();
    
    _a.position = posA + direction * correction;
    _b.position = posB - direction * correction;
  }
}