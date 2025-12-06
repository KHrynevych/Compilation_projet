package main;


func f(a, b, c int) {
	return 8
}

func g(a, b, c int) {
	return  2
}

func main() {
	var a int = 5
	b, c:= 8, 9
	//ne marche plus ici (virgule en trop)
	f(a, b, c,)
};


