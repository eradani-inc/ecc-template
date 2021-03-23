# Eradani Connect Template makefile

# Specify the development library by setting the environment variable "LIB" before
# running make.


# Variables
#
LIB?=ECNCTAPP


MODS = dspjk \
       dsptrfc \
       dspvhcl \
       dspwf \
       prtlbl

GENMODS = icndbapi \
            lblapi \
            trfcapi \
            vinapi \
            wthfrcapi

GENHDRS = icndbapi_h \
            lblapi_h \
            trfcapi_h \
            vinapi_h \
            wthfcapi_h

SRVPGMS = ecctmpgen

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

# Calculated variables
#
ifndef LIB
   $(error LIB, the development library, is not defined)
else
   libdir = /qsys.lib/$(LIB).lib
endif

rootdir = $(shell cd ..; pwd)
ecclient = $(rootdir)/bin/ec-client

# List of natively qualified (NQ) generated modues
NQGENMODS = $(foreach mod, $(GENMODS), $(LIB)/$(mod))

# List of fully qualified commands, programs and modules
FQCMDS = $(foreach cmd, $(CMDS), $(libdir)/$(cmd).cmd)
FQPGMS = $(foreach pgm, $(PGMS), $(libdir)/$(pgm).pgm)
FQSRVPGMS = $(foreach srvpgm, $(SRVPGMS), $(libdir)/$(srvpgm).srvpgm)
FQMODS = $(foreach mod, $(MODS), $(libdir)/$(mod).module)
FQGENMODS = $(foreach mod, $(GENMODS), $(libdir)/$(mod).module)

# List of fully qualified source members
FQCMDSRCMBRS = $(foreach srcmbr, $(CMDS), $(libdir)/qcmdsrc.file/$(srcmbr).mbr)
FQMODSRCMBRS = $(foreach srcmbr, $(MODS), $(libdir)/qrpglesrc.file/$(srcmbr).mbr)
FQGENMODSRCMBRS = $(foreach srcmbr, $(GENMODS), $(libdir)/qrpglesrc.file/$(srcmbr).mbr)
FQGENHDRSRCMBRS = $(foreach srcmbr, $(GENHDRS), $(libdir)/qrpglesrc.file/$(srcmbr).mbr)

# List of all fully qualified source members
FQSRCMBRS = $(FQCMDSRCMBRS) \
	    $(FQMODSRCMBRS) \
	    $(FQGENMODSRCMBRS) \
	    $(FQGENHDRSRCMBRS)

# Local (IFS) generated source
LCLGENMODSRC = $(foreach src, $(GENMODS), $(src).rpgle)
LCLGENHDRSRC = $(foreach src, $(GENHDRS), $(src).rpgleinc)
LCLGENTSSRC = $(foreach src, $(GENMODS), $(src).ts)
LCLGENJSSRC = $(foreach src, $(GENMODS), $(src).js)
FQTSGENSRC = $(foreach src, $(GENMODS), ../src/interfaces/$(src).ts)

# Rules
#

all: $(FQCMDS)


# Command, program and module recipes
$(libdir)/%.cmd: $(libdir)/qcmdsrc.file/%.mbr  $(libdir)/%.pgm
	system "CRTCMD CMD($(LIB)/$(basename $(@F))) PGM($(LIB)/$(basename $(@F))) SRCFILE($(LIB)/QCMDSRC)"

$(libdir)/dspjk.pgm: $(libdir)/dspjk.module $(libdir)/ecctmpgen.srvpgm
	system "CRTPGM PGM($(LIB)/$(basename $(@F))) MODULE(*PGM) BNDSRVPGM((ECCTMPGEN) (ECNCTC))"

$(libdir)/dsptrfc.pgm: $(libdir)/dsptrfc.module $(libdir)/ecctmpgen.srvpgm
	system "CRTPGM PGM($(LIB)/$(basename $(@F))) MODULE(*PGM) BNDSRVPGM((ECCTMPGEN) (ECNCTC))"

$(libdir)/dspvhcl.pgm: $(libdir)/dspvhcl.module $(libdir)/ecctmpgen.srvpgm
	system "CRTPGM PGM($(LIB)/$(basename $(@F))) MODULE(*PGM) BNDSRVPGM((ECCTMPGEN) (ECNCTC))"

$(libdir)/dspwf.pgm: $(libdir)/dspwf.module $(libdir)/ecctmpgen.srvpgm
	system "CRTPGM PGM($(LIB)/$(basename $(@F))) MODULE(*PGM) BNDSRVPGM((ECCTMPGEN) (ECNCTC))"

$(libdir)/prtlbl.pgm: $(libdir)/prtlbl.module $(libdir)/ecctmpgen.srvpgm
	system "CRTPGM PGM($(LIB)/$(basename $(@F))) MODULE(*PGM) BNDSRVPGM((ECCTMPGEN) (ECNCTC))"

$(libdir)/ecctmpgen.srvpgm: $(FQGENMODS)
	system "CRTSRVPGM SRVPGM($(LIB)/$(basename $(@F))) MODULE($(NQGENMODS)) EXPORT(*ALL)"

$(libdir)/%.module: $(libdir)/qrpglesrc.file/%.mbr
	system "CRTRPGMOD MODULE($(LIB)/$(basename $(@F))) SRCFILE($(LIB)/QRPGLESRC) DBGVIEW(*LIST)"

# Source member recipes
$(libdir)/qcmdsrc.file/%.mbr: %.cmd
	system "CPYFRMSTMF FROMSTMF('$<') TOMBR('$@') MBROPT(*REPLACE)"

$(libdir)/qrpglesrc.file/%.mbr: %.rpgle
	system "CPYFRMSTMF FROMSTMF('$<') TOMBR('$@') MBROPT(*REPLACE)"

$(libdir)/qrpglesrc.file/%.mbr: %.rpgleinc
	system "CPYFRMSTMF FROMSTMF('$<') TOMBR('$@') MBROPT(*REPLACE)"

# Non-wildcard dependencies
$(libdir)/dspjk.module: $(libdir)/qrpglesrc.file/icndbapi_h.mbr $(libdir)/qrpglesrc.file/ecnctc.mbr

$(libdir)/dsptrfc.module: $(libdir)/qrpglesrc.file/trfcapi_h.mbr $(libdir)/qrpglesrc.file/ecnctc.mbr

$(libdir)/dspvhcl.module: $(libdir)/qrpglesrc.file/vinapi_h.mbr $(libdir)/qrpglesrc.file/ecnctc.mbr

$(libdir)/dspwf.module: $(libdir)/qrpglesrc.file/wthfcapi_h.mbr $(libdir)/qrpglesrc.file/ecnctc.mbr

$(libdir)/prtlbl.module: $(libdir)/qrpglesrc.file/lblapi_h.mbr $(libdir)/qrpglesrc.file/ecnctc.mbr

# Prevent gmake from deleting intermediate source members
.PRECIOUS: $(FQSRCMBRS)


# Modules
#



# Miscellaneous objects
#

# Copy the Eradani Connect EccSndReq and EccRcvRes prototypes
ecnctc.rpgleinc: ../node_modules/@eradani-inc/ec-client/native/ecnctc.rpgleinc
	cp $< $@



# Files
#


# Miscelaneous rules and dependencies
#

.PHONEY: generatedtssrc
generatedtssrc: $(FQTSGENSRC)

$(libdir)/qrpglesrc.file/icndbapi.mbr $(libdir)/qrpglesrc.file/icndbapi_h.mbr ../src/interfaces/icndbapi.ts: icndbapi.yaml
	npx ec-generate -f $<
	cp icndbapi.ts ../src/interfaces/icndbapi.ts
	system "CPYFRMSTMF FROMSTMF('icndbapi.rpgle') TOMBR('$(libdir)/qrpglesrc.file/icndbapi.mbr') MBROPT(*REPLACE)"
	system "CPYFRMSTMF FROMSTMF('icndbapi_h.rpgleinc') TOMBR('$(libdir)/qrpglesrc.file/icndbapi_h.mbr') MBROPT(*REPLACE)"

$(libdir)/qrpglesrc.file/trfcapi.mbr $(libdir)/qrpglesrc.file/trfcapi_h.mbr ../src/interfaces/trfcapi.ts: trfcapi.yaml
	npx ec-generate -f $<
	cp trfcapi.ts ../src/interfaces/trfcapi.ts
	system "CPYFRMSTMF FROMSTMF('trfcapi.rpgle') TOMBR('$(libdir)/qrpglesrc.file/trfcapi.mbr') MBROPT(*REPLACE)"
	system "CPYFRMSTMF FROMSTMF('trfcapi_h.rpgleinc') TOMBR('$(libdir)/qrpglesrc.file/trfcapi_h.mbr') MBROPT(*REPLACE)"

$(libdir)/qrpglesrc.file/vinapi.mbr $(libdir)/qrpglesrc.file/vinapi_h.mbr ../src/interfaces/vinapi.ts: vinapi.yaml
	npx ec-generate -f $<
	cp vinapi.ts ../src/interfaces/vinapi.ts
	system "CPYFRMSTMF FROMSTMF('vinapi.rpgle') TOMBR('$(libdir)/qrpglesrc.file/vinapi.mbr') MBROPT(*REPLACE)"
	system "CPYFRMSTMF FROMSTMF('vinapi_h.rpgleinc') TOMBR('$(libdir)/qrpglesrc.file/vinapi_h.mbr') MBROPT(*REPLACE)"

$(libdir)/qrpglesrc.file/wthfrcapi.mbr $(libdir)/qrpglesrc.file/wthfcapi_h.mbr ../src/interfaces/wthfrcapi.ts: wthfrcapi.yaml
	npx ec-generate -f $<
	cp wthfrcapi.ts ../src/interfaces/wthfrcapi.ts
	system "CPYFRMSTMF FROMSTMF('wthfrcapi.rpgle') TOMBR('$(libdir)/qrpglesrc.file/wthfrcapi.mbr') MBROPT(*REPLACE)"
	system "CPYFRMSTMF FROMSTMF('wthfcapi_h.rpgleinc') TOMBR('$(libdir)/qrpglesrc.file/wthfcapi_h.mbr') MBROPT(*REPLACE)"

$(libdir)/qrpglesrc.file/lblapi.mbr $(libdir)/qrpglesrc.file/lblapi_h.mbr ../src/interfaces/lblapi.ts: lblapi.yaml
	npx ec-generate -f $<
	cp lblapi.ts ../src/interfaces/lblapi.ts
	system "CPYFRMSTMF FROMSTMF('lblapi.rpgle') TOMBR('$(libdir)/qrpglesrc.file/lblapi.mbr') MBROPT(*REPLACE)"
	system "CPYFRMSTMF FROMSTMF('lblapi_h.rpgleinc') TOMBR('$(libdir)/qrpglesrc.file/lblapi_h.mbr') MBROPT(*REPLACE)"


.PHONY: library
library:
	-system "CRTLIB $(LIB)"
	-system "CRTSRCPF FILE($(LIB)/QCMDSRC)"
	-system "CRTSRCPF FILE($(LIB)/QRPGLESRC)"


.PHONY: clean
clean:
	-rm $(FQCMDS)
	-rm $(FQPGMS)
	-rm $(FQSRVPGMS)
	-rm $(FQMODS)
	-rm $(FQGENMODS)
	-rm $(FQSRCMBRS)
	-rm $(libdir)/qrpglesrc.file/ecnctc.mbr
	-rm ecnctc.rpgleinc
	-rm $(LCLGENMODSRC)
	-rm $(LCLGENHDRSRC)
	-rm $(LCLGENTSSRC)
	-rm $(LCLGENJSSRC)
	-rm $(FQTSGENSRC)
