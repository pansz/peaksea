# Makefile

target=pwdtool
objs=pwdtool.o
prefix=$(HOME)

CFLAGS=-Wall -pedantic -std=c99 -g -O2
LDFLAGS=-lcrypt

all: $(target)

.PHONY: clean depend lint install

pwdtool: pwdtool.o
	$(CC) $^ $(LDFLAGS) -o $@
	@$(RM) $^

.INTERMEDIATE: $(objs)

clean:
	$(RM) $(target) $(target).exe

lint:
	splint +posixlib -retvalint *.c

depend:
	makedepend -Y *.c
	@$(RM) Makefile.bak

install: $(target) $(prefix)/bin $(prefix)/bin/p

$(prefix)/bin:
	install -d $(prefix)/bin

$(prefix)/bin/p: $(target)
	install -s $(target) $(prefix)/bin/p

# DO NOT DELETE THIS LINE -- make depend depends on it.

pwdtool.o: config.h
