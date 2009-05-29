#
# Zeitgit makefile
#

PREFIX      ?= /usr/local
EXEC_PREFIX ?= $(PREFIX)
SHAREDIR    ?= $(PREFIX)/share/zeitgit
BINDIR      ?= $(EXEC_PREFIX)/bin

INSTALL ?= install -C

all:

install: install-hooks install-tools

install-hooks:
	@if ! test -d $(SHAREDIR) ; then \
		echo "Creating directory $(SHAREDIR)" ; \
		$(INSTALL) -o root -g wheel -m 0755 -d $(SHAREDIR) ; \
	fi
	$(INSTALL) -o root -g wheel -m 0755 hooks/post-commit $(SHAREDIR)/

install-tools:
	@if ! test -d $(BINDIR) ; then \
		echo "Creating directory $(BINDIR)" ; \
		$(INSTALL) -o root -g wheel -m 0755 -d $(BINDIR) ; \
	fi
	$(INSTALL) -o root -g wheel -m 0755 tools/zeitgit $(BINDIR)/

