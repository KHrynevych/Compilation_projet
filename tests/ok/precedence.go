package main

func main() {
    var x int
    // Priorités : * et / avant + et -
    x = 1 + 2 * 3 - 4 / 2
    
    // Parenthèses
    x = (1 + 2) * 3
    
    // Comparaisons chaînées (syntaxiquement valide même si sémantiquement douteux parfois)
    b := 1 < 2 && 3 >= 4 || 5 != 6
    
    // Unaires
    b = !true
    x = -x
}
