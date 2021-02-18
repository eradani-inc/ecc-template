# Eradani Connect Template makefile

# Specify the development library by setting the environment variable "LIB" before
# running make.


# Variables
#
LIB?=ECNCTAPP

TGTRLS?=V7R4M0


MODS = dspjk \
       dsptrfc \
       dspvhcl \
       dspwf \
       prtlbl

PGMS = dspjk \
       dsptrfc \
       dspvhcl \
       dspwf \
       prtlbl

CMDS = dspjk \
       dsptrfc \
       dspvhcl \
       dspwf \
       prtlbl

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

FQCMDS = $(foreach cmd, $(CMDS), $(libdir)/$(cmd).cmd)
FQPGMS = $(foreach pgm, $(PGMS), $(libdir)/$(pgm).pgm)
FQMODS = $(foreach mod, $(MODS), $(libdir)/$(mod).module)
FQGENMODS = $(foreach mod, $(GENSRC), $(libdir)/$(mod).module)
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

$(libdir)/dspjk.pgm: $(libdir)/dspjk.module $(libdir)/icndbapi.module
	system "CRTPGM PGM($(LIB)/$(basename $(@F))) MODULE($(LIB)/$(basename $(@F)) $(LIB)/icndbapi)"

$(libdir)/dsptrfc.pgm: $(libdir)/dsptrfc.module $(libdir)/trfcapi.module
	system "CRTPGM PGM($(LIB)/$(basename $(@F))) MODULE($(LIB)/$(basename $(@F)) $(LIB)/trfcapi)"

$(libdir)/dspvhcl.pgm: $(libdir)/dspvhcl.module $(libdir)/vinapi.module
	system "CRTPGM PGM($(LIB)/$(basename $(@F))) MODULE($(LIB)/$(basename $(@F)) $(LIB)/vinapi)"

$(libdir)/dspwf.pgm: $(libdir)/dspwf.module $(libdir)/wthfrcapi.module
	system "CRTPGM PGM($(LIB)/$(basename $(@F))) MODULE($(LIB)/$(basename $(@F)) $(LIB)/wthfrcapi)"

$(libdir)/prtlbl.pgm: $(libdir)/prtlbl.module $(libdir)/lblapi.module
	system "CRTPGM PGM($(LIB)/$(basename $(@F))) MODULE($(LIB)/$(basename $(@F)) $(LIB)/lblapi)"

$(libdir)/%.module: %.rpgle
	system "CRTRPGMOD MODULE($(LIB)/$(basename $(@F))) SRCSTMF('$<') TGTCCSID(37) TGTRLS($(TGTRLS)) DBGVIEW(*LIST)"

$(libdir)/dspjk.module: icndbapi.rpgleinc ecnctc.rpgleinc

$(libdir)/dsptrfc.module: trfcapi.rpgleinc ecnctc.rpgleinc

$(libdir)/dspvhcl.module: vinapi.rpgleinc ecnctc.rpgleinc

$(libdir)/dspwf.module: wthfrcapi.rpgleinc ecnctc.rpgleinc

$(libdir)/prtlbl.module: lblapi.rpgleinc ecnctc.rpgleinc

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

$(libdir)/dspjk.pgm: $(libdir)/qrpgsrc.file/icndbapi.mbr $(libdir)/qrpgsrc.file/ecnctc.mbr

$(libdir)/dspwf.pgm: $(libdir)/qrpgsrc.file/wthfrcapi.mbr $(libdir)/qrpgsrc.file/ecnctc.mbr

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
	npm run generate -- $<
	cp icndbapi.ts ../src/interfaces

trfcapi.rpgle trfcapi.rpgleinc trfcapi.ts trfcapi.js: trfcapi.yaml
	npm run generate -- $<
	cp trfcapi.ts ../src/interfaces

vinapi.rpgle vinapi.rpgleinc vinapi.ts vinapi.js: vinapi.yaml
	npm run generate -- $<
	cp vinapi.ts ../src/interfaces

wthfrcapi.rpgle wthfrcapi.rpgleinc wthfrcapi.ts wthfrcapi.js: wthfrcapi.yaml
	npm run generate -- $<
	cp wthfrcapi.ts ../src/interfaces

lblapi.rpgle lblapi.rpgleinc lblapi.ts lblapi.js: lblapi.yaml
	npm run generate -- $<
	cp lblapi.ts ../src/interfaces


.PHONY: library
library:
	-system "CRTLIB $(LIB)"
	-system "CRTSRCPF FILE($(LIB)/QCLSRC)"
	-system "CRTSRCPF FILE($(LIB)/QCMDSRC)"
	-system "CRTSRCPF FILE($(LIB)/QRPGSRC)"


.PHONY: clean
clean:
	-rm $(FQCMDS)
	-rm $(FQPGMS)
	-rm $(FQMODS)
	-rm $(FQGENMODS)
	-rm $(FQSRCMBRS)
	-rm $(LCLRPGGENMODSRC)
	-rm *.rpgleinc *.js *.ts
