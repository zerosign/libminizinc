PLATFORM=macosx

TARGETS=mzn2fzn

GENERATE=yes

SOURCES=allocator ast context lexer.yy parser.tab  \
	print printer/Document printer/Line printer/PrettyPrinter printer \
	typecheck solver_interface/solver_interface solver_interface/cplex_interface \
	solver_interface/cpopt_interface

HEADERS=allocator ast context exception model parser parser.tab print type typecheck printer \
	solver_interface/solver_interface solver_interface/cplex_interface \
	solver_interface/cpopt_interface

GENERATED=include/minizinc/parser.tab.hh lib/parser.tab.cpp lib/lexer.yy.cpp

ifeq ($(PLATFORM),windows)
CXXFLAGS=/nologo /Ox /EHsc /DNDEBUG /MD /Iinclude
INPUTSRC=/Tp
OUTPUTOBJ=-c /Fo
OUTPUTEXE=/Fe
CXX=cl
OBJ=obj
EXE=.exe
else
CXX=/opt/stlfilt/gfilt
CC=clang
#cplex options
CPLEXDIR = /opt/ibm/ILOG/CPLEX_Studio124/cplex
CONCERTDIR = /opt/ibm/ILOG/CPLEX_Studio124/concert
COPTDIR = /opt/ibm/ILOG/CPLEX_Studio124/cpoptimizer

CPLEXBINDIR   = $(CPLEXDIR)/bin/$(SYSTEM)

CPLEXLIBDIR   = $(CPLEXDIR)/lib/$(SYSTEM)/$(LIBFORMAT)
CONCERTLIBDIR = $(CONCERTDIR)/lib/$(SYSTEM)/$(LIBFORMAT)
COPTLIBDIR    = $(COPTDIR)/lib/$(SYSTEM)/$(LIBFORMAT)

SYSTEM     = x86-64_sles10_4.1
LIBFORMAT  = static_pic

CCOPT = -m64 -O0 -fPIC -DIL_STD -DILOUSEMT -D_REENTRANT -DILM_REENTRANT
CCLNFLAGS = -L$(COPTLIBDIR) -lcp -L$(CPLEXLIBDIR) -lilocplex -lcplex -L$(CONCERTLIBDIR) -lconcert -lm -pthread 

CONCERTINCDIR = $(CONCERTDIR)/include
CPLEXINCDIR   = $(CPLEXDIR)/include
COPTINCDIR   = $(COPTDIR)/include

CCFLAGS = $(CCOPT) $(CCLNFLAGS) -I$(COPTINCDIR) -I$(CPLEXINCDIR) -I$(CONCERTINCDIR)
CXXFLAGS=-std=c++0x -Wall -g -rdynamic -Iinclude $(CCFLAGS)
#CXXFLAGS=-Wall -g -O2 -DNDEBUG -Iinclude
OUTPUTOBJ=-c -o 
OUTPUTEXE=-o 
OBJ=o
EXE=
endif


all: $(TARGETS:%=%$(EXE))

$(SOURCES:%=lib/%.$(OBJ)): %.$(OBJ): %.cpp 
	$(CXX) $(CXXFLAGS) $(OUTPUTOBJ)$@ $<

%.$(OBJ): %.cpp 
	$(CXX) $(CXXFLAGS) $(OUTPUTOBJ)$@ $<

ifeq ($(PLATFORM),windows)
mzn2fzn$(EXE): mzn2fzn.$(OBJ) $(SOURCES:%=lib/%.$(OBJ))
	$(CXX) $(CXXFLAGS) $(OUTPUTEXE)$@ $^
	mt.exe -nologo -manifest $@.manifest -outputresource:$@\;1
else
mzn2fzn$(EXE): mzn2fzn.$(OBJ) $(SOURCES:%=lib/%.$(OBJ))
	$(CXX) $^ $(CXXFLAGS) $(OUTPUTEXE)$@ 
endif

ifeq ($(GENERATE), yes)
lib/lexer.yy.cpp: lib/lexer.lxx include/minizinc/parser.tab.hh
	flex -o$@ $<

include/minizinc/parser.tab.hh lib/parser.tab.cpp: lib/parser.yxx include/minizinc/parser.hh
	bison -t -o lib/parser.tab.cpp --defines=include/minizinc/parser.tab.hh $<
endif

.PHONY: clean
clean:
	rm -f mzn2fzn.$(OBJ) $(SOURCES:%=lib/%.$(OBJ))

.PHONY: veryclean
veryclean: clean
	rm -f $(TARGETS:%=%$(EXE)) 
	rm -f $(GENERATED)

# Dependencies
mzn2fzn.$(OBJ): $(HEADERS:%=include/minizinc/%.hh)