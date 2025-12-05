EXE=_build/default/mgoc.exe
OK = tests/ok/
KOT = tests/ko_type/
KOS = tests/ko_syntaxe/

all: $(EXE)

$(EXE): *.ml*
	dune build @all

test: $(EXE) $(OK)test.go
	-./$(EXE) --parse-only $(OK)test.go

testok: $(EXE) $(OK)test.go $(OK)min.go $(OK)arith.go $(OK)var.go $(OK)point.go $(OK)instr.go $(OK)div.go $(OK)abs.go $(OK)print.go $(OK)struct.go $(OK)torture.go $(OK)precedence.go
	-./$(EXE) $(OK)test.go
	-./$(EXE) $(OK)min.go
	-./$(EXE) $(OK)arith.go
	-./$(EXE) $(OK)var.go
	-./$(EXE) $(OK)point.go
	-./$(EXE) $(OK)instr.go
	-./$(EXE) $(OK)div.go
	-./$(EXE) $(OK)abs.go
	-./$(EXE) $(OK)print.go
	-./$(EXE) $(OK)struct.go
	-./$(EXE) $(OK)precedence.go
	-./$(EXE) $(OK)torture.go


testkot: $(EXE) $(KOT)ko_assign_type.go $(KOT)ko_field_unknown.go $(KOT)ko_print_no_import.go $(KOT)ko_return_arity.go
	-./$(EXE) $(KOT)ko_assign_type.go
	-./$(EXE) $(KOT)ko_field_unknown.go
	-./$(EXE) $(KOT)ko_print_no_import.go
	-./$(EXE) $(KOT)ko_return_arity.go

testkos: $(EXE) $(KOS)accolade.go $(KOS)mauvaise_decl.go
	-./$(EXE) $(KOS)accolade.go
	-./$(EXE) $(KOS)mauvaise_decl.go

.PHONY: clean
clean:
	dune clean
	rm -f *~ tests/*~
