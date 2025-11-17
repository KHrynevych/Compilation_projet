EXE=_build/default/mgoc.exe

all: $(EXE)

$(EXE): *.ml*
	dune build @all

test: $(EXE) tests/test.go
	-./$(EXE) --parse-only tests/test.go

test2: $(EXE) tests/min.go
	-./$(EXE) --parse-only tests/min.go

.PHONY: clean
clean:
	dune clean
	rm -f *~ tests/*~
