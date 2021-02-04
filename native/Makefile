# Eradani Connect Template makefile

# Specify the development library by setting the environment variable "LIB" before
# running make.


# Variables
#
LIB?=ECNCTAPP

TGTRLS?=V7R4M0


MODS = dspjkr \
       dsptrfcr \
       dspvhclr \
       dspwfr \
       prtlblr

PGMS = dspjkr \
       dsptrfcr \
       dspvhclr \
       dspwfr \
       prtlblr

CMDS = dspjkr \
       dsptrfcr \
       dspvhclr \
       dspwfr \
       prtlblr

GENSRC = icndbapi \
         lblapi \
         trfcapi \
         vinapi \
         wthfrcapi

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
FQMODS = $(foreach mod, $(MODS), $(libdir)/$(mod).module)
FQCMDSRCMBRS = $(foreach srcmbr, $(CMDS), $(libdir)/qcmdsrc.file/$(srcmbr).mbr)
FQRPGSRCMBRS = $(foreach srcmbr, $(MODS), $(libdir)/qrpgsrc.file/$(srcmbr).mbr)
FQRPGGENSRCMBRS = $(foreach srcmbr, $(GENSRC), $(libdir)/qrpgsrc.file/$(srcmbr).mbr)
FQSRCMBRS = $(FQCMDSRCMBRS) \
	    $(FQRPGSRCMBRS) \
	    $(FQRPGGENSRCMBRS)
LCLRPGGENMODSRC = $(foreach src, $(GENSRC), $(src).rpgle)

# Rules
#

all: $(FQCMDS)


# Programs
#

ecnctc.rpgleinc: ../node_modules/@eradani-inc/ec-client/native/ecnctc.rpgleinc
	cp $< $@

ifeq ($(TGTRLS), V7R4M0)

$(libdir)/%.cmd: %.cmd  $(libdir)/%.pgm
	system "CRTCMD CMD($(LIB)/$(basename $(@F))) PGM($(LIB)/$(basename $(@F))) SRCSTMF('$<')"

$(libdir)/dspjkr.pgm: $(libdir)/dspjkr.module $(libdir)/icndbapi.module
	system "CRTPGM PGM($(LIB)/$(basename $(@F))) MODULE($(LIB)/$(basename $(@F)) $(LIB)/icndbapi)"

$(libdir)/dsptrfcr.pgm: $(libdir)/dsptrfcr.module $(libdir)/trfcapi.module
	system "CRTPGM PGM($(LIB)/$(basename $(@F))) MODULE($(LIB)/$(basename $(@F)) $(LIB)/trfcapi)"

$(libdir)/dspvhclr.pgm: $(libdir)/dspvhclr.module $(libdir)/vinapi.module
	system "CRTPGM PGM($(LIB)/$(basename $(@F))) MODULE($(LIB)/$(basename $(@F)) $(LIB)/vinapi)"

$(libdir)/%.module: %.rpgle
	system "CRTRPGMOD MODULE($(LIB)/$(basename $(@F))) SRCSTMF('$<') TGTCCSID(37) TGTRLS($(TGTRLS)) DBGVIEW(*LIST)"

$(libdir)/dspjkr.module: icndbapi.rpgleinc ecnctc.rpgleinc

$(libdir)/dsptrfcr.module: trfcapi.rpgleinc ecnctc.rpgleinc

$(libdir)/dspvhclr.module: vinapi.rpgleinc ecnctc.rpgleinc

$(libdir)/dspwfr.module: wthfrcapi.rpgleinc ecnctc.rpgleinc

else

$(libdir)/%.cmd: $(libdir)/qcmdsrc.file/%.mbr  $(libdir)/%.pgm
	system "CRTCMD CMD($(LIB)/$(basename $(@F))) PGM($(LIB)/$(basename $(@F)))\
	  SRCFILE($(LIB)/QCMDSRC)"

$(libdir)/%.pgm: $(libdir)/qrpgsrc.file/%.mbr
	system "CRTBNDRPG PGM($(LIB)/$(basename $(@F))) SRCFILE($(LIB)/QRPGSRC) TGTRLS($(TGTRLS))"

$(libdir)/qcmdsrc.file/%.mbr: %.cmd
	system "CPYFRMSTMF FROMSTMF('$<') TOMBR('$@') MBROPT(*REPLACE)"

$(libdir)/qrpgsrc.file/%.mbr: %2.rpgle
	system "CPYFRMSTMF FROMSTMF('$<') TOMBR('$@') MBROPT(*REPLACE)"

$(libdir)/qrpgsrc.file/%.mbr: %.rpgle
	system "CPYFRMSTMF FROMSTMF('$<') TOMBR('$@') MBROPT(*REPLACE)"

$(libdir)/qrpgsrc.file/%.mbr: %.rpgleinc
	system "CPYFRMSTMF FROMSTMF('$<') TOMBR('$@') MBROPT(*REPLACE)"

$(libdir)/dspjkr.pgm: $(libdir)/qrpgsrc.file/icndbapi.mbr $(libdir)/qrpgsrc.file/ecnctc.mbr

$(libdir)/dspwfr.pgm: $(libdir)/qrpgsrc.file/wthfrcapi.mbr $(libdir)/qrpgsrc.file/ecnctc.mbr

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

icndbapi.rpgle icndbapi.rpgleinc icndbapi.ts icndbapi.js: icndbapi.yaml
	npm run generate -- -f $<
	cp icndbapi.js ../src/services

trfcapi.rpgle trfcapi.rpgleinc trfcapi.ts trfcapi.js: trfcapi.yaml
	npm run generate -- -f $<
	cp trfcapi.js ../src/services

vinapi.rpgle vinapi.rpgleinc vinapi.ts vinapi.js: vinapi.yaml
	npm run generate -- -f $<
	cp vinapi.js ../src/services

wthfrcapi.rpgle wthfrcapi.rpgleinc wthfrcapi.ts wthfrcapi.js: wthfrcapi.yaml
	npm run generate -- -f $<
	cp wthfrcapi.js ../src/services

lblapi.rpgle lblapi.rpgleinc lblapi.ts lblapi.js: lblapi.yaml
	npm run generate -- -f $<
	cp lblapi.js ../src/services


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
	-rm $(LCLRPGGENMODSRC)
	-rm *.rpgleinc *.js *.ts
