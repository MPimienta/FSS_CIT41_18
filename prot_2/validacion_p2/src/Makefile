MAIN = main
GNATMAKE = sparc-ork-gnatmake
GF = -g -gnata
LF = -k -specs ork_specs -mcpu=cypress

all:
	$(GNATMAKE) $(MAIN) -cargs $(GF) -largs $(LF)

clean:
	rm -f *.o *.ali b~* *.nm *.map main test_rules

.PHONY: all clean
