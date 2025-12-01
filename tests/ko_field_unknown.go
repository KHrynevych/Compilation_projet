package main;

// Doit échouer (accès à un champ inexistant dans une struct)

type Point struct {
  x int;
  y int;
};

func main() {
  var p Point;
  p.x = 1;
  p.y = 2;
  p.z = 3;
};
