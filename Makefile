EXE=_build/default/mgoc.exe

all: $(EXE)

$(EXE): *.ml*
	dune build @all

test: $(EXE) tests/test.go
	-./$(EXE) --parse-only tests/test.go

testmin: $(EXE) tests/min.go
	-./$(EXE) --parse-only tests/min.go

testarith: $(EXE) tests/arith.go
	-./$(EXE) --parse-only tests/arith.go

testvar: $(EXE) tests/var.go
	-./$(EXE) --parse-only tests/var.go

testpoint: $(EXE) tests/point.go
	-./$(EXE) --parse-only tests/point.go

testinstr: $(EXE) tests/instr.go
	-./$(EXE) --parse-only tests/instr.go

testdiv: $(EXE) tests/div.go
	-./$(EXE) --parse-only tests/div.go
.PHONY: clean
clean:
	dune clean
	rm -f *~ tests/*~
