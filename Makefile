#CPUS ?= $(getconf _NPROCESSORS_ONLN)
CPUS ?= $(shell nproc)
MAKEFLAGS += --jobs=$(CPUS)

# Passed to openscad itself, not to make. Deliberately empty: Manifold is the
# default backend now, and lazy-union is NOT safe here. It drops the implicit
# union between sibling geometry, so a part whose body is several statements
# not wrapped in union() exports as separate solids in one STL rather than one
# merged manifold, with no error. Add flags here if a part needs them.
OPENSCAD_FLAGS =

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
# Native Linux only. WSL is deliberately unsupported: openscad there is a
# Windows binary needing Windows paths, and the .deps file it writes back
# would then contain "Z:\...", whose drive-letter colon make parses as a rule
# separator. Use ./openscad.sh for the GUI, or build from git-bash/Windows.
OPENSCAD="openscad-nightly"
endif
ifneq (,$(findstring MINGW64_NT,$(UNAME_S)))
OPENSCAD=/c/Program\ Files/OpenSCAD\ \(Nightly\)/openscad.com
endif

OPENSCADPATH=$(shell pwd)

SCAD_FILES = $(wildcard *.scad)

BUILDDIR = build
OUTPUTDIR = output

default: all

define def_parts
# explicit wildcard expansion suppresses errors when no files are found
include $(wildcard $(BUILDDIR)/*.deps)

.SECONDARY: $(BUILDDIR)/$2.scad
# define a new target for a temporary "build file" that only calls the part module
$(BUILDDIR)/$2.scad: $1 | dir_build dir_output
	@/bin/echo -n -e 'use <../$(1)>\npart_$(2)();' > $(BUILDDIR)/$2.scad

$(OUTPUTDIR)/$2.stl: $(BUILDDIR)/$2.scad
	@echo Building $2
	@OPENSCADPATH=$(OPENSCADPATH) $(OPENSCAD) $(OPENSCAD_FLAGS) -m make -D is_build=true -o $(OPENSCADPATH)/$(OUTPUTDIR)/$2.stl -d $(OPENSCADPATH)/$(BUILDDIR)/$2.deps $(OPENSCADPATH)/$(BUILDDIR)/$2.scad

.PHONY: all
all:: $(OUTPUTDIR)/$2.stl
endef

define find_parts
# use sed to find all openscad modules that begin with part_
$(eval PARTS := $(shell  sed -n -e 's/^module part_\(.*\)().*/\1/p' $1))
# define a new build target for each found part
$(foreach part,$(PARTS),$(eval $(call def_parts,$1,$(part))))
endef

# Find all parts in all scad files
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

gui:
	@OPENSCADPATH=$(OPENSCADPATH) $(OPENSCAD)
