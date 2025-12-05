package main
import "fmt"

// Test de la plupart structures syntaxiques bizarres

type S struct { x, y int; z *S; }; // Point-virgule final optionnel dans struct

func main() {
    // Déclarations multiples et initialisations
    var a, b int = 1, 2;
    var c = 3
    d := 4
    
    // Assignations multiples
    a, b = c, d
    
    // Blocs et imbrication
    {
        var x int
        x = 0; // Point-virgule explicite
    }

    // Boucles 'for' (les 4 variantes de la grammaire)
    for { break }           // Boucle infinie
    for a < b { a++ }       // While
    for i:=0; i<10; i++ {};  // For classique
    for i:=0; i<10; {}      // Instruction simple manquante à la fin

    // If / Else et imbrication (Dangling else)
    if a == b {
        fmt.Print(a)
    } else if a < b {
        if true { a-- } else { b++ }
    } else {
        fmt.Print(b)
    }

    // Appels et expressions
    f(1, 2,) // Virgule traînante autorisée par votre grammaire (params)
}

func f(x, y int,) {} // Virgule traînante dans déclaration