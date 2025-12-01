package main;


// Doit passer
// Résultat attendu 3

func abs(x int) int {
  if x < 0 {
    return -x;
  } else {
    return x;
  }
};

func main() {
  var a int;
  a = 3;
  var b int;
  b = abs(a);
};
