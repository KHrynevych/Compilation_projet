package main
import "fmt";

func main() {
    var x int
    // Priorités : * et / avant + et -
    x = 1 + 2 * 3 - 4 / 2
    fmt.Print(x)
    // Parenthèses
    x = (1 + 2) * 3
    fmt.Print(x)
    // Comparaisons chaînées (syntaxiquement valide même si sémantiquement douteux parfois)
    b := 1 < 2 && 3 >= 4 || 5 != 6
    fmt.Print(b)
    // Unaires
    b = !true
    fmt.Print(b)
    x = -x
    fmt.Print(x)
}
