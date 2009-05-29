#
# Zeitgit makefile
#

PREFIX      ?= /usr/local
EXEC_PREFIX ?= $(PREFIX)
SHAREDIR    ?= $(PREFIX)/share/zeitgit
BINDIR      ?= $(EXEC_PREFIX)/bin

INSTALL     ?= install

all: hook-scripts zeitgit

hook-scripts:

zeitgit: 
	cat tools/zeitgit.in | sed 's#@SHAREDIR@#$(SHAREDIR)#g' > tools/zeitgit

install: all install-hooks install-tools

install-hooks:
	@if ! test -d $(SHAREDIR) ; then \
		echo "Creating directory $(SHAREDIR)" ; \
		$(INSTALL) -m 0755 -d $(SHAREDIR) ; \
	fi
	$(INSTALL) -C -m 0755 hooks/post-commit $(SHAREDIR)/

install-tools: tools
	@if ! test -d $(BINDIR) ; then \
		echo "Creating directory $(BINDIR)" ; \
		$(INSTALL) -m 0755 -d $(BINDIR) ; \
	fi
	$(INSTALL) -C -m 0755 tools/zeitgit $(BINDIR)/

clean:
	rm tools/zeitgit

