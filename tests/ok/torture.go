package main
import "fmt"

// Test de la plupart structures syntaxiques bizarres (!!ne peut pas s'exécuter car boucle infinie!!)

type S struct { x, y int; z *S; };

func main() {
    var a, b int = 1, 2;
    var c = 3
    d := 4
    
    a, b = c, d

    {
        var x int
        x = 0; 
    }

    for { c++ }           // Boucle infinie
    for a < b { a++ }       
    for i:=0; i<10; i++ {};  
    for i:=0; i<10; {}      

    if a == b {
        fmt.Print(a)
    } else if a < b {
        if true { a-- } else { b++ }
    } else {
        fmt.Print(b)
    }

    f(1, 2) 
}

func f(x, y int) {return 5} 
