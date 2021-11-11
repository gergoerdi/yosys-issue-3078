TOP := Top
SOURCES := $(wildcard *.v)
XDC := nexys-a7-50t.xdc

BITSTREAM_DEVICE := artix7
PARTNAME := xc7a50tcsg324-1
DEVICE := xc7a50t_test
CABLE := digilent

.PHONY: all
all: _build/$(TOP).bit

.PHONY: upload
upload: _build/$(TOP).bit
	openFPGALoader -c $(CABLE) $<

.PHONY: clean
clean:
	rm -rf _build

_build:
	mkdir -p $@

_build/$(TOP).eblif: $(SOURCES) $(XDC) | _build
	cd $(dir $@) && symbiflow_synth -d $(BITSTREAM_DEVICE) -p $(PARTNAME) -t $(TOP) -v $(realpath $(SOURCES)) -x $(realpath $(XDC)) > /dev/null

%.net: %.eblif
	cd $(dir $@) && symbiflow_pack -d $(DEVICE) -e $(realpath $<) > /dev/null

%.place: %.eblif %.net
	cd $(dir $@) && symbiflow_place -d $(DEVICE) -P $(PARTNAME) -e $(notdir $<) -n Top.net > /dev/null

%.route: %.eblif %.place
	cd $(dir $@) && symbiflow_route -d $(DEVICE) -e $(notdir $<) > /dev/null

%.fasm: %.eblif %.route
	cd $(dir $@) && symbiflow_write_fasm -d $(DEVICE) -e $(notdir $<) > /dev/null

%.bit: %.fasm
	cd $(dir $@) && symbiflow_write_bitstream -d $(BITSTREAM_DEVICE) -p $(PARTNAME) -f $(notdir $<) -b $(notdir $@)
