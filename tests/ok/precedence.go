package main
import "fmt";

func main() {
    var x int
    // priorités : * et / avant + et -
    x = 1 + 2 * 3 - 4 / 2
    // 5
    fmt.Print(x)
    // Parenthèses
    x = (1 + 2) * 3
    // 9
    fmt.Print(x)
    // Comparaisons chaînées (doit rendre vrai)
    b := 1 < 2 && 3 >= 4 || 5 != 6
    //1
    fmt.Print(b)
    b = !true
    //0
    fmt.Print(b)
    x = -x
    //-9
    fmt.Print(x)
}
