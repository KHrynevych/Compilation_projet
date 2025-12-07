package main;
import "fmt";


// Doit passer
// Résultat attendu 3

func abso(x int) int {
  if x < 0 {
    return -x;
  } else {
    return x;
  }
};

func main() {
  var a int;
  a = -3;
  var b int;
  b = abso(a);
  fmt.Print(b);
};
