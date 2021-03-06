CC=gcc
LEX=flex
YACC=bison

LFILE=lexical.l
YFILE=syntax.y
LCFILE=$(LFILE:.l=.c)
YCFILE=$(YFILE:.y=.c)
YHFILE=$(YFILE:.y=.h)
CFILES=$(shell find . -name "*.c")
HFILES=$(shell find . -name "*.h")
CFLAGS=-O2 -std=c99

OBJ_DIR=obj/
TEST_DIR=test/
COMPILER=compiler

#CMM=test/simple.cmm
CMM=test/token.cmm

all:$(COMPILER)

$(LCFILE):$(LFILE)
	$(LEX) -o $(LCFILE) $(LFILE)

$(YHFILE) $(YCFILE):$(YFILE)
	$(YACC) -v $(YFILE) --defines=$(YHFILE) -o $(YCFILE)

$(COMPILER):$(YFILE) $(LFILE) $(CFILES) $(HFILES)
	mkdir -p $(OBJ_DIR)
	$(CC) $(CFILES) -o $(COMPILER) -lfl

ast.h:syntax.y
	python genast.py > ast.h

.PHONY:run run-ast test test-lex clean

run:$(COMPILER)
	cat $(CMM) | ./$(COMPILER)

run-ast:$(COMPILER)
	cat $(CMM) | ./$(COMPILER) --print-ast

test:$(COMPILER)
	bash test.sh $(COMPILER)

test-lex:
	mkdir -p $(OBJ_DIR)
	$(LEX) -o $(LFILE:.l=.c) $(LFILE)
	$(CC) $(LFILE:.l=.c) component.c -o $(COMPILER) -lfl
	bash test.sh $(COMPILER)

clean:
	rm -rf $(COMPILER)
	rm -rf $(OBJ_DIR)
	rm -rf $(TEST_DIR)*.err $(TEST_DIR)*.out
