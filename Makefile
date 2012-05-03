# Makefile - for the TRR19 distribution.
# Last modified on Sun Jun 30 03:10:31 1996

# Edit the Makefile, type `make', and follow the instructions.

##----------------------------------------------------------------------
##  You MUST edit the following lines
##----------------------------------------------------------------------

# Your Full name or E-mail address
installer = trr-installer@where.you.are

# Default message type (t or nil)
japanese = t

# Where TRR directory is found
TRRDIR = /usr/local/trr

# Where TRR directory is found
LISPDIR=/usr/local/share/emacs/site-lisp

# Where info files go.
INFODIR = /usr/local/info
#INFODIR = /usr/local/lib/emacs/info

# Where TRR binary files go.
BINDIR = /usr/local/bin

# Name of your emacs binary
EMACS = emacs
#EMACS = mule

# Which C Compiler will you use?
CC = gcc

# What Options will you use?
OPTIONS = -O2 -DHAVE_STRING_H -DHAVE_SYS_TIME_H -DHAVE_FCNTL_H
# -DHAVE_SYS_FCNTL_H

# Name of your sed
SED = /usr/bin/sed
#SED = /bin/sed

# Name of your grep
GREP = /usr/bin/grep
#GREP = /bin/grep

##----------------------------------------------------------------------
## You MAY need to edit these
##----------------------------------------------------------------------

# BSD compatible install
INSTALL = ./install-sh
#INSTALL = /usr/bin/install
#INSTALL = /usr/ucb/install

# Specify the byte-compiler for compiling TRR files
ELC = $(EMACS) -batch -q -no-site-file -eval\
	'(setq load-path (cons (expand-file-name ".") load-path))'\
	-f batch-byte-compile

# Specify makeinfo program
MAKEINFO = $(EMACS) -batch -l texinfmt -funcall batch-texinfo-format 
#MAKEINFO = makeinfo

LDFLAGS =

##----------------------------------------------------------------------
##  BELOW THIS LINE ON YOUR OWN RISK!
##----------------------------------------------------------------------

.SUFFIXES:
.SUFFIXES: .el .elc .c .o .texi .info

TEXT_DIR = $(TRRDIR)/text/
RECORD_DIR = $(TRRDIR)/record/

CFLAGS = $(OPTIONS) -DTEXT_DIR=\"$(TEXT_DIR)\" -DRECORD_DIR=\"$(RECORD_DIR)\" \
	-DSED=\"$(SED)\" -DGREP=\"$(GREP)\"

SHELL = /bin/sh

TRRSRC = trr.el trr-mesg.el trr-files.el trr-menus.el \
	 trr-graphs.el trr-sess.el

TRRELC = trr.elc trr-mesg.elc trr-files.elc trr-menus.elc \
	 trr-graphs.elc trr-sess.elc

SOURCES = trr_update.c trr_format.c

SUBPROGS = trr_update trr_format

CONTENTS = CONTENTS

TEXIFILES = trr.texi

INFO = trr.info

TEXTS = The_Constitution_Of_JAPAN Constitution_of_the_USA Iccad_90

EXTRAFILES = Makefile README.euc ChangeLog

first:
	@echo ""
	@echo "	 First of all, edit the Makefile to suit your needs."
	@echo "	 Then run:"
	@echo
	@echo "	  make all"
	@echo
	@echo "	 and follow the instructions."
	@echo

all: main

main: elc $(SUBPROGS)

install: main install-dir
	for i in $(SUBPROGS); do $(INSTALL) -c -m 6755 $$i $(BINDIR); done
	$(INSTALL) -c -m 644 CONTENTS $(TRRDIR)
	for i in $(TRRELC); \
		do $(INSTALL) -c -m 644 $$i $(LISPDIR); done
	(cd text; for i in $(TEXTS); \
			do $(INSTALL) -c -m 644 $$i $(TRRDIR)/text; done)
	$(INSTALL) -c -m 644 $(INFO) $(INFODIR)
	@echo 
	@echo "** TRR installation is almost completed."
	@echo "**"
	@echo "** Now edit \`CONTENTS' in the directory where you put"
	@echo "** TRR files ($(TRRDIR)/), and insert"
	@echo "** (autoload 'trr \"$(TRRDIR)/trr\" nil t)"
	@echo "** in your \`.emacs' or \`site-start.el' file."
	@echo "** then edit $(INFODIR)/dir to add TRR entry."
	@echo "**"
	@echo "** You may want to add some texts to TRR text directory."
	@echo "** Put them into $(TRRDIR)/text and edit \`CONTENTS'"
	@echo

install-dir:
	if [ ! -d $(BINDIR) ]; \
	then rm -f $(BINDIR); \
	     mkdir -p $(BINDIR); \
	     chmod 755 $(BINDIR); \
	fi
	if [ ! -d $(LISPDIR) ]; \
	then rm -f $(LISPDIR); \
	     mkdir -p $(LISPDIR); \
	     chmod 755 $(LISPDIR); \
	fi
	if [ ! -d $(TRRDIR) ]; \
	then rm -f $(TRRDIR); \
	     mkdir -p $(TRRDIR); \
	     chmod 755 $(TRRDIR); \
	fi
	if [ ! -d $(TRRDIR)/text ]; \
	then rm -f $(TRRDIR)/text; \
	     mkdir -p $(TRRDIR)/text; \
	     chmod 755 $(TRRDIR)/text; \
	fi
	if [ ! -d $(TRRDIR)/record ]; \
	then rm -f $(TRRDIR)/record; \
	     mkdir -p $(TRRDIR)/record; \
	     chmod 755 $(TRRDIR)/record; \
	fi
	if [ ! -d $(INFODIR) ]; \
	then rm -f $(INFODIR); \
	     mkdir -p $(INFODIR); \
	     chmod 755 $(INFODIR); \
	fi

.texi.info:
	$(MAKEINFO) $<

info: $(TEXIFILES)

trr.el: trr.el.base
	rm -f $@
	$(SED)  -e 's,TRRELCINSTALLDIR,$(TRRDIR),' \
		-e 's,TRRBININSTALLDIR,$(BINDIR),' \
		-e 's,TRRINSTALLER,$(installer),' \
		-e 's,TRRDEFAULTJAPANESE,$(japanese),' trr.el.base > $@

.el.elc:
	$(ELC) $<

elc: $(TRRELC)

.c.o:
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $<

trr_format: trr_format.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ trr_format.o

trr_update: trr_update.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ trr_update.o

clean:
	rm -f *.o *~ $(TRRELC) $(SUBPROGS) trr.el

distclean: clean
	rm -f *.info
