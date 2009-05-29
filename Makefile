#
# Zeitgit makefile
#

SHAREDIR ?= /usr/local/share/zeitgit
TOOLDIR  ?= /usr/local/bin

INSTALL ?= install -C

install: install-hooks install-tools

install-hooks:
	$(INSTALL) -o root -g wheel -m 0755 -d $(SHAREDIR)
	$(INSTALL) -o root -g wheel -m 0755 hooks/post-commit $(SHAREDIR)/

install-tools:
	$(INSTALL) -o root -g wheel -m 0755 -d $(TOOLDIR)
	$(INSTALL) -o root -g wheel -m 0755 tools/zeitgit $(TOOLDIR)/

