OPENSCAD="C:/Program Files/OpenSCAD/openscad.com"
OPENSCAD_FLAGS="--enable=assert"

SCAD_FILES = $(wildcard *.scad)

BUILDDIR = build
OUTPUTDIR = output

default: all

define def_parts
# explicit wildcard expansion suppresses errors when no files are found
include $(wildcard $(BUILDDIR)/*.deps)

.SECONDARY: $(BUILDDIR)/$2.scad
$(BUILDDIR)/$2.scad: $1 | dir_build dir_output
	@echo -n -e 'use <../$(1)>\npart_$(2)();' > $(BUILDDIR)/$2.scad

$(OUTPUTDIR)/$2.stl: $(BUILDDIR)/$2.scad
	@echo Building $2
	@$(OPENSCAD) $(OPENSCAD_FLAGS) -m make -D is_build=true -o $(OUTPUTDIR)/$2.stl -d $(BUILDDIR)/$2.deps $(BUILDDIR)/$2.scad

.PHONY: all
all:: $(OUTPUTDIR)/$2.stl
endef

define find_parts
$(eval PARTS := $(shell  sed -n -e 's/^module part_\(.*\)().*/\1/p' $1))
$(foreach part,$(PARTS),$(eval $(call def_parts,$1,$(part))))
endef

$(foreach file,$(SCAD_FILES),$(eval $(call find_parts,$(file))))

.PHONY: list
list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | xargs

.SECONDARY: dir_build
dir_build:
	@mkdir -p $(BUILDDIR)

.SECONDARY: dir_output
dir_output:
	@mkdir -p $(OUTPUTDIR)

clean:
	@rm -rf $(BUILDDIR)
	@rm -rf $(OUTPUTDIR)
