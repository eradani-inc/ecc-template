# Eradani Connect Template makefile

# Specify the development library by setting the environment variable "LIB" before
# running make.


# Variables
#
LIB?=ECNCTAPP

TGTRLS?=V7R4M0

CLPGMS = dspjkc

RPGPGMS = dspwfr \
          dspjkr

PGMS = $(CLPGMS) \
       $(RPGPGMS)

CMDS = dspwfr \
       dspjkc \
       dspjkr


# Calculated variables
#
ifndef LIB
   $(error LIB, the development library, is not defined)
else
   libdir = /qsys.lib/$(LIB).lib
endif

rootdir = $(shell cd ..; pwd)
ecclient = $(rootdir)/bin/ec-client

FQPGMS = $(foreach pgm, $(PGMS), $(libdir)/$(pgm).pgm)
FQCMDS = $(foreach cmd, $(CMDS), $(libdir)/$(cmd).cmd)
FQCMDSRCMBRS = $(foreach srcmbr, $(CMDS), $(libdir)/qcmdsrc.file/$(srcmbr).mbr)
FQCLSRCMBRS = $(foreach srcmbr, $(CLPGMS), $(libdir)/qclsrc.file/$(srcmbr).mbr)
FQRPGSRCMBRS = $(foreach srcmbr, $(RPGPGMS), $(libdir)/qrpgsrc.file/$(srcmbr).mbr)
FQSRCMBRS = $(FQCMDSRCMBRS) \
	    $(FQCLSRCMBRS) \
	    $(FQRPGSRCMBRS)


# Rules
#

all: $(FQPGMS) $(FQCMDS)


# Programs
#

ecnctc.rpgleinc: ../node_modules/@eradani-inc/ec-client/native/ecnctc.rpgleinc
	cp $< $@

ifeq ($(TGTRLS), V7R4M0)

$(libdir)/%.cmd: %.cmd  $(libdir)/%.pgm
	system "CRTCMD CMD($(LIB)/$(basename $(@F))) PGM($(LIB)/$(basename $(@F)))\
	  SRCSTMF('$<')"

$(libdir)/%.pgm: %.rpgle
	system "CRTBNDRPG PGM($(LIB)/$(basename $(@F))) SRCSTMF('$<') TGTCCSID(37) TGTRLS($(TGTRLS))"

$(libdir)/%.pgm: %.clle
	system "CRTBNDCL PGM($(LIB)/$(basename $(@F))) SRCSTMF('$<') TGTRLS($(TGTRLS))"

$(libdir)/dspwfr.pgm: wthfrcapi.rpgleinc ecnctc.rpgleinc

$(libdir)/dspjkr.pgm: icndbapi.rpgleinc ecnctc.rpgleinc

$(libdir)/dspjkc.pgm: icndbapi.clleinc

else

$(libdir)/%.cmd: $(libdir)/qcmdsrc.file/%.mbr  $(libdir)/%.pgm
	system "CRTCMD CMD($(LIB)/$(basename $(@F))) PGM($(LIB)/$(basename $(@F)))\
	  SRCFILE($(LIB)/QCMDSRC)"

$(libdir)/%.pgm: $(libdir)/qrpgsrc.file/%.mbr
	system "CRTBNDRPG PGM($(LIB)/$(basename $(@F))) SRCFILE($(LIB)/QRPGSRC) TGTRLS($(TGTRLS))"

$(libdir)/%.pgm: $(libdir)/qclsrc.file/%.mbr
	system "CRTBNDCL PGM($(LIB)/$(basename $(@F))) SRCFILE($(LIB)/QCLSRC) TGTRLS($(TGTRLS))"

$(libdir)/qcmdsrc.file/%.mbr: %.cmd
	system "CPYFRMSTMF FROMSTMF('$<') TOMBR('$@') MBROPT(*REPLACE)"

$(libdir)/qrpgsrc.file/%.mbr: %2.rpgle
	system "CPYFRMSTMF FROMSTMF('$<') TOMBR('$@') MBROPT(*REPLACE)"

$(libdir)/qrpgsrc.file/%.mbr: %.rpgle
	system "CPYFRMSTMF FROMSTMF('$<') TOMBR('$@') MBROPT(*REPLACE)"

$(libdir)/qrpgsrc.file/%.mbr: %.rpgleinc
	system "CPYFRMSTMF FROMSTMF('$<') TOMBR('$@') MBROPT(*REPLACE)"

$(libdir)/qclsrc.file/%.mbr: %2.clle
	system "CPYFRMSTMF FROMSTMF('$<') TOMBR('$@') MBROPT(*REPLACE)"

$(libdir)/qclsrc.file/%.mbr: %.clle
	system "CPYFRMSTMF FROMSTMF('$<') TOMBR('$@') MBROPT(*REPLACE)"

$(libdir)/qclsrc.file/%.mbr: %.clleinc
	system "CPYFRMSTMF FROMSTMF('$<') TOMBR('$@') MBROPT(*REPLACE)"

$(libdir)/dspwfr.pgm: $(libdir)/qrpgsrc.file/wthfrcapi.mbr $(libdir)/qrpgsrc.file/ecnctc.mbr

$(libdir)/dspjkr.pgm: $(libdir)/qrpgsrc.file/icndbapi.mbr $(libdir)/qrpgsrc.file/ecnctc.mbr

$(libdir)/dspjkc.pgm: $(libdir)/qclsrc.file/icndbapi.mbr

# Prevent gmake from deleting intermediate source members
.PRECIOUS: $(FQSRCMBRS)

endif


# Modules
#



# Miscellaneous objects
#



# Files
#


# Miscelaneous rules and dependencies
#

icndbapi.clleinc icndbapi.rpgleinc icndbapi.js: icndbapi.yaml
	npm run generate -- -f $<
	cp icndbapi.js ../src/services

wthfrcapi.clleinc wthfrcapi.rpgleinc wthfrcapi.js: wthfrcapi.yaml
	npm run generate -- -f $<
	cp wthfrcapi.js ../src/services


.PHONY: library
library:
	-system "CRTLIB $(LIB)"
	-system "CRTSRCPF FILE($(LIB)/QCLSRC)"
	-system "CRTSRCPF FILE($(LIB)/QCMDSRC)"
	-system "CRTSRCPF FILE($(LIB)/QRPGSRC)"


.PHONY: clean
clean:
	-rm $(FQPGMS) $(FQCMDS)
	-rm $(FQSRCMBRS)
	-rm *.clleinc *.rpgleinc *.js *.ts
