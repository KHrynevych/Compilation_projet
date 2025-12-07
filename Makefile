EXE=_build/default/mgoc.exe
OK = tests/ok/
KOT = tests/ko_type/
KOS = tests/ko_syntaxe/

all: $(EXE)

$(EXE): *.ml*
	dune build @all

test: $(EXE) $(OK)test.go
	-./$(EXE) --parse-only $(OK)test.go

testok: $(EXE) $(OK)test.go $(OK)min.go $(OK)arith.go $(OK)var.go $(OK)point.go $(OK)instr.go $(OK)div.go $(OK)abs.go $(OK)print.go $(OK)struct.go $(OK)precedence.go
	-./$(EXE) --type-only $(OK)test.go
	-./$(EXE) --type-only $(OK)min.go
	-./$(EXE) --type-only $(OK)arith.go
	-./$(EXE) --type-only $(OK)var.go
	-./$(EXE) --type-only $(OK)point.go
	-./$(EXE) --type-only $(OK)instr.go
	-./$(EXE) --type-only $(OK)div.go
	-./$(EXE) --type-only $(OK)abs.go
	-./$(EXE) --type-only $(OK)print.go
	-./$(EXE) --type-only $(OK)struct.go
	-./$(EXE) --type-only $(OK)precedence.go


testkot: $(EXE) $(KOT)ko_assign_type.go $(KOT)ko_field_unknown.go $(KOT)ko_print_no_import.go $(KOT)ko_return_arity.go
	-./$(EXE) $(KOT)ko_assign_type.go
	-./$(EXE) $(KOT)ko_field_unknown.go
	-./$(EXE) $(KOT)ko_print_no_import.go
	-./$(EXE) $(KOT)ko_return_arity.go

testkos: $(EXE) $(KOS)accolade.go $(KOS)mauvaise_decl.go $(KOS)nomain.go $(KOS)nopars.go $(KOS)nofunction.go $(KOS)virgule.go
	-./$(EXE) $(KOS)accolade.go
	-./$(EXE) $(KOS)mauvaise_decl.go
	-./$(EXE) $(KOS)nomain.go
	-./$(EXE) $(KOS)nopars.go
	-./$(EXE) $(KOS)nofunction.go
	-./$(EXE) $(KOS)virgule.go

.PHONY: clean
clean:
	dune clean
	rm -f *~ tests/*~
