// An immutable 2d vector class
// Intentionally not optimized to help/see dart compiler development.
// Most of the method calls should be inlined.
class Vec2
{
  double _x = 0.0;
  double _y = 0.0;
  
  Vec2.zero();
  
  Vec2(double this._x, double this._y);
  
  double get x() => _x;
  
  double get y() => _y;
  
  static double dot(Vec2 a, Vec2 b) => a._x * b._x + a._y * b._y;
  
  static double distance(Vec2 a, Vec2 b) => (a - b).length();
  
  Vec2 operator +(Vec2 other) => new Vec2(_x + other._x, _y + other._y);
  
  Vec2 operator -(Vec2 other) => new Vec2(_x - other._x, _y - other._y);
  
  Vec2 operator *(double other) => new Vec2(_x * other, _y * other);
  
  Vec2 operator /(double other) => this * (1.0 / other);
  
  double lengthSquared() => _x * _x + _y * _y;
  
  double length() => Math.sqrt(lengthSquared());
  
  Vec2 normalized()
  {
    double lenSquared = lengthSquared();
    
    if (lenSquared > 0.0)
    {
      return this / Math.sqrt(lenSquared);
    }
    
    return new Vec2.zero();
  }
}