package main;
import "fmt";

// Doit passer

func main() {
  var x int;
  var y int;
  var flag bool;
  var msg string;

  x = 1;
  y = 2;
  flag = x < y;
  msg = "hello";
  //on ne peut pas print le message de cette façon

  fmt.Print(x);
  fmt.Print(y);
  fmt.Print(flag);
  fmt.Print("hello");
};
