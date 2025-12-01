package main;

// Résultat attendu 25

type Point struct {
  x int;
  y int;
};

func normSquared(p Point) int {
  return p.x * p.x + p.y * p.y;
};

func main() {
  var p Point;
  p.x = 3;
  p.y = 4;
  var n int;
  n = normSquared(p);
};
