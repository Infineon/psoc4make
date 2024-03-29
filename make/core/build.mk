################################################################################
# \file build.mk
#
# \brief
# Performs the compilation and linking steps.
#
################################################################################
# \copyright
# Copyright 2018-2020 Cypress Semiconductor Corporation
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
################################################################################

ifeq ($(WHICHFILE),true)
$(info Processing $(lastword $(MAKEFILE_LIST)))
endif

$(info )
$(info Constructing build rules...)

################################################################################
# Macros
################################################################################

#
# Search for relative path patterns in source list
# $(1) : Pattern
# $(2) : Sources
#
CY_MACRO_VPATH_FIND=$(foreach level,$(1),$(if $(filter $(level)%,$(2)),$(level)))

# 
# Gather the includes in inclist_export.rsp files
# $(1) : List of inclist_export.rsp files
#
CY_MACRO_ECLIPSE_PRINT=$(foreach incFile,$(1),$(call CY_MACRO_FILE_READ,$(incFile)))

#
# Construct explicit rules for select files
# $(1) : source file
# $(2) : object file
# $(3) : file origin identifier
#
define CY_MACRO_EXPLICIT_RULE

# Build the correct compiler arguments
$(2)_SUFFIX=$$(suffix $(1))
ifeq ($$($(2)_SUFFIX),.$(CY_TOOLCHAIN_SUFFIX_s))
$(2)_EXPLICIT_COMPILE_ARGS=$(CY_BUILD_COMPILE_AS_LC)
else ifeq ($$($(2)_SUFFIX),.$(CY_TOOLCHAIN_SUFFIX_S))
$(2)_EXPLICIT_COMPILE_ARGS=$(CY_BUILD_COMPILE_AS_UC)
else ifeq ($$($(2)_SUFFIX),.$(CY_TOOLCHAIN_SUFFIX_C))
$(2)_EXPLICIT_COMPILE_ARGS=$(CY_BUILD_COMPILE_EXPLICIT_C)
else ifeq ($$($(2)_SUFFIX),.$(CY_TOOLCHAIN_SUFFIX_CPP))
$(2)_EXPLICIT_COMPILE_ARGS=$(CY_BUILD_COMPILE_EXPLICIT_CPP)
else
$$(call CY_MACRO_ERROR,Incompatible source file type encountered while constructing explicit rule: $(1))
endif

$(CY_CONFIG_DIR)/$(2) : $(1)
ifneq ($(CY_MAKE_IDE),eclipse)
	$$(info $$(CY_INDENT)Compiling $(3) file $$(CY_COMPILE_PRINT))
else
	$$(info Compiling $$< $$(CY_RECIPE_DEFINES) $$(sort $$(CY_RECIPE_INCLUDES) $$(call CY_MACRO_ECLIPSE_PRINT,$$(CY_SHAREDLIB_INCLUDES_EXPORT_LIST))))
endif
	$(CY_NOISE)$$($(2)_EXPLICIT_COMPILE_ARGS) $$@ $$<

endef


################################################################################
# Target output
################################################################################

ifneq ($(LIBNAME),)
CY_BUILD_TARGET=$(CY_CONFIG_DIR)/$(LIBNAME).$(CY_TOOLCHAIN_SUFFIX_ARCHIVE)
else
CY_BUILD_TARGET=$(CY_CONFIG_DIR)/$(APPNAME).$(CY_TOOLCHAIN_SUFFIX_TARGET)
CY_BUILD_MAPFILE=$(CY_CONFIG_DIR)/$(APPNAME).$(CY_TOOLCHAIN_SUFFIX_MAP)
endif


################################################################################
# Shared libs
################################################################################

ifneq ($(SEARCH_LIBS_AND_INCLUDES),)

CY_SHAREDLIB_INCLUDES_EXPORT_LIST=$(foreach lib,$(SEARCH_LIBS_AND_INCLUDES),$($(notdir $(lib))_SHAREDLIB_BUILD_LOCATION)/inclist_export.rsp)
CY_SHAREDLIB_LIBS_EXPORT_LIST=$(foreach lib,$(SEARCH_LIBS_AND_INCLUDES),$($(notdir $(lib))_SHAREDLIB_BUILD_LOCATION)/liblist_export.rsp)
CY_SHAREDLIB_ARTIFACT_EXPORT_LIST=$(foreach lib,$(SEARCH_LIBS_AND_INCLUDES),$($(notdir $(lib))_SHAREDLIB_BUILD_LOCATION)/artifact_export.rsp)
CY_SHAREDLIB_ARTIFACTS=$(foreach d,$(CY_SHAREDLIB_ARTIFACT_EXPORT_LIST),$(call CY_MACRO_FILE_READ,$(d)))

CY_BUILD_SHAREDLIB_INCLIST=$(foreach inc,$(CY_SHAREDLIB_INCLUDES_EXPORT_LIST),$(addprefix $(CY_TOOLCHAIN_INCRSPFILE),$(inc)))
CY_BUILD_SHAREDLIB_LIBLIST=$(foreach lib,$(CY_SHAREDLIB_LIBS_EXPORT_LIST),$(addprefix $(CY_TOOLCHAIN_OBJRSPFILE),$(lib)))\
							$(foreach artifact,$(CY_SHAREDLIB_ARTIFACT_EXPORT_LIST),$(addprefix $(CY_TOOLCHAIN_OBJRSPFILE),$(artifact)))

endif


################################################################################
# Dependent apps
################################################################################

ifneq ($(DEPENDENT_APP_PATHS),)

CY_DEPAPP_TARGET=$(CY_CONFIG_DIR)/$(APPNAME)_standalone.$(CY_TOOLCHAIN_SUFFIX_TARGET)
CY_DEPAPP_MAPFILE=$(CY_CONFIG_DIR)/$(APPNAME)_standalone.$(CY_TOOLCHAIN_SUFFIX_MAP)

CY_DEPAPP_ARTIFACT_EXPORT_LIST=$(foreach app,$(DEPENDENT_APP_PATHS),$($(notdir $(app))_DEPAPP_BUILD_LOCATION)/artifact_export.rsp)
CY_DEPAPP_C_FILES=$(foreach d,$(CY_DEPAPP_ARTIFACT_EXPORT_LIST),$(call CY_MACRO_FILE_READ,$(d)))
CY_DEPAPP_STRIPPED=$(notdir $(CY_DEPAPP_C_FILES))
CY_DEPAPP_OBJ_FILES=$(addprefix $(CY_CONFIG_DIR)/dep_apps/,$(CY_DEPAPP_STRIPPED:%.$(CY_TOOLCHAIN_SUFFIX_C)=%.$(CY_TOOLCHAIN_SUFFIX_O)))

endif


################################################################################
# Build arguments
################################################################################

#
# Strip off the paths for conversion to build output files
#
CY_BUILD_EXTSRC_LIST=$(SOURCES) $(CY_SEARCH_APP_SOURCE_ASSET)
CY_BUILD_INTSRC_LIST=$(filter-out $(CY_BUILD_EXTSRC_LIST),$(CY_RECIPE_SOURCE))
CY_BUILD_SRC_STRIPPED=$(patsubst $(CY_INTERNAL_APP_PATH)/%,/%,$(patsubst $(CY_INTERNAL_EXTAPP_PATH)/%,/%,$(CY_BUILD_INTSRC_LIST)))
CY_BUILD_EXTSRC_RELATIVE=$(sort $(filter $(CY_INTERNAL_APP_PATH)/%,$(CY_BUILD_EXTSRC_LIST)) $(filter ../%,$(CY_BUILD_EXTSRC_LIST)) $(filter ./%,$(CY_BUILD_EXTSRC_LIST)))
CY_BUILD_EXTSRC_ABSOLUTE=$(filter-out $(CY_BUILD_EXTSRC_RELATIVE),$(CY_BUILD_EXTSRC_LIST))
CY_BUILD_EXTSRC_RELATIVE_STRIPPED=$(patsubst $(CY_INTERNAL_APP_PATH)/%,/%,$(subst ../,,$(CY_BUILD_EXTSRC_RELATIVE)))
CY_BUILD_EXTSRC_ABSOLUTE_STRIPPED=$(notdir $(CY_BUILD_EXTSRC_ABSOLUTE))

#
# Source files that come from the application, generated, and external input
#
CY_BUILD_SRC_S_FILES=$(filter %.$(CY_TOOLCHAIN_SUFFIX_S),$(CY_BUILD_SRC_STRIPPED))
CY_BUILD_SRC_s_FILES=$(filter %.$(CY_TOOLCHAIN_SUFFIX_s),$(CY_BUILD_SRC_STRIPPED))
CY_BUILD_SRC_C_FILES=$(filter %.$(CY_TOOLCHAIN_SUFFIX_C),$(CY_BUILD_SRC_STRIPPED))
CY_BUILD_SRC_CPP_FILES=$(filter %.$(CY_TOOLCHAIN_SUFFIX_CPP),$(CY_BUILD_SRC_STRIPPED))
CY_BUILD_GENSRC_S_FILES=$(filter %.$(CY_TOOLCHAIN_SUFFIX_S),$(CY_RECIPE_GENERATED))
CY_BUILD_GENSRC_s_FILES=$(filter %.$(CY_TOOLCHAIN_SUFFIX_s),$(CY_RECIPE_GENERATED))
CY_BUILD_GENSRC_C_FILES=$(filter %.$(CY_TOOLCHAIN_SUFFIX_C),$(CY_RECIPE_GENERATED))
CY_BUILD_GENSRC_CPP_FILES=$(filter %.$(CY_TOOLCHAIN_SUFFIX_CPP),$(CY_RECIPE_GENERATED))
CY_BUILD_EXTSRC_S_FILES=$(filter %.$(CY_TOOLCHAIN_SUFFIX_S),$(CY_BUILD_EXTSRC_RELATIVE_STRIPPED) $(CY_BUILD_EXTSRC_ABSOLUTE_STRIPPED))
CY_BUILD_EXTSRC_s_FILES=$(filter %.$(CY_TOOLCHAIN_SUFFIX_s),$(CY_BUILD_EXTSRC_RELATIVE_STRIPPED) $(CY_BUILD_EXTSRC_ABSOLUTE_STRIPPED))
CY_BUILD_EXTSRC_C_FILES=$(filter %.$(CY_TOOLCHAIN_SUFFIX_C),$(CY_BUILD_EXTSRC_RELATIVE_STRIPPED) $(CY_BUILD_EXTSRC_ABSOLUTE_STRIPPED))
CY_BUILD_EXTSRC_CPP_FILES=$(filter %.$(CY_TOOLCHAIN_SUFFIX_CPP),$(CY_BUILD_EXTSRC_RELATIVE_STRIPPED) $(CY_BUILD_EXTSRC_ABSOLUTE_STRIPPED))

#
# The list of object files
#
CY_BUILD_SRC_S_OBJ_FILES=$(addprefix $(CY_CONFIG_DIR)/,$(CY_BUILD_SRC_S_FILES:%.$(CY_TOOLCHAIN_SUFFIX_S)=%.$(CY_TOOLCHAIN_SUFFIX_O)))
CY_BUILD_SRC_s_OBJ_FILES=$(addprefix $(CY_CONFIG_DIR)/,$(CY_BUILD_SRC_s_FILES:%.$(CY_TOOLCHAIN_SUFFIX_s)=%.$(CY_TOOLCHAIN_SUFFIX_O)))
CY_BUILD_SRC_C_OBJ_FILES=$(addprefix $(CY_CONFIG_DIR)/,$(CY_BUILD_SRC_C_FILES:%.$(CY_TOOLCHAIN_SUFFIX_C)=%.$(CY_TOOLCHAIN_SUFFIX_O)))
CY_BUILD_SRC_CPP_OBJ_FILES=$(addprefix $(CY_CONFIG_DIR)/,$(CY_BUILD_SRC_CPP_FILES:%.$(CY_TOOLCHAIN_SUFFIX_CPP)=%.$(CY_TOOLCHAIN_SUFFIX_O)))
CY_BUILD_GENSRC_S_OBJ_FILES=$(patsubst $(CY_BUILDTARGET_DIR)/%,$(CY_CONFIG_DIR)/%,$(CY_BUILD_GENSRC_S_FILES:%.$(CY_TOOLCHAIN_SUFFIX_S)=%.$(CY_TOOLCHAIN_SUFFIX_O)))
CY_BUILD_GENSRC_s_OBJ_FILES=$(patsubst $(CY_BUILDTARGET_DIR)/%,$(CY_CONFIG_DIR)/%,$(CY_BUILD_GENSRC_s_FILES:%.$(CY_TOOLCHAIN_SUFFIX_s)=%.$(CY_TOOLCHAIN_SUFFIX_O)))
CY_BUILD_GENSRC_C_OBJ_FILES=$(patsubst $(CY_BUILDTARGET_DIR)/%,$(CY_CONFIG_DIR)/%,$(CY_BUILD_GENSRC_C_FILES:%.$(CY_TOOLCHAIN_SUFFIX_C)=%.$(CY_TOOLCHAIN_SUFFIX_O)))
CY_BUILD_GENSRC_CPP_OBJ_FILES=$(patsubst $(CY_BUILDTARGET_DIR)/%,$(CY_CONFIG_DIR)/%,$(CY_BUILD_GENSRC_CPP_FILES:%.$(CY_TOOLCHAIN_SUFFIX_CPP)=%.$(CY_TOOLCHAIN_SUFFIX_O)))
CY_BUILD_EXTSRC_S_OBJ_FILES=$(addprefix $(CY_CONFIG_DIR)/ext/,$(CY_BUILD_EXTSRC_S_FILES:%.$(CY_TOOLCHAIN_SUFFIX_S)=%.$(CY_TOOLCHAIN_SUFFIX_O)))
CY_BUILD_EXTSRC_s_OBJ_FILES=$(addprefix $(CY_CONFIG_DIR)/ext/,$(CY_BUILD_EXTSRC_s_FILES:%.$(CY_TOOLCHAIN_SUFFIX_s)=%.$(CY_TOOLCHAIN_SUFFIX_O)))
CY_BUILD_EXTSRC_C_OBJ_FILES=$(addprefix $(CY_CONFIG_DIR)/ext/,$(CY_BUILD_EXTSRC_C_FILES:%.$(CY_TOOLCHAIN_SUFFIX_C)=%.$(CY_TOOLCHAIN_SUFFIX_O)))
CY_BUILD_EXTSRC_CPP_OBJ_FILES=$(addprefix $(CY_CONFIG_DIR)/ext/,$(CY_BUILD_EXTSRC_CPP_FILES:%.$(CY_TOOLCHAIN_SUFFIX_CPP)=%.$(CY_TOOLCHAIN_SUFFIX_O)))

# All object files from the application
CY_BUILD_ALL_OBJ_FILES=\
	$(call CY_MACRO_REMOVE_DOUBLESLASH,\
	$(CY_BUILD_SRC_S_OBJ_FILES)\
	$(CY_BUILD_SRC_s_OBJ_FILES)\
	$(CY_BUILD_SRC_C_OBJ_FILES)\
	$(CY_BUILD_SRC_CPP_OBJ_FILES)\
	$(CY_BUILD_GENSRC_S_OBJ_FILES)\
	$(CY_BUILD_GENSRC_s_OBJ_FILES)\
	$(CY_BUILD_GENSRC_C_OBJ_FILES)\
	$(CY_BUILD_GENSRC_CPP_OBJ_FILES)\
	$(CY_BUILD_EXTSRC_S_OBJ_FILES)\
	$(CY_BUILD_EXTSRC_s_OBJ_FILES)\
	$(CY_BUILD_EXTSRC_C_OBJ_FILES)\
	$(CY_BUILD_EXTSRC_CPP_OBJ_FILES))\
	$(CY_DEPAPP_OBJ_FILES)

# Obj list without dependent apps
CY_DEPAPP_OBJ_FILES_WO=$(filter-out $(CY_DEPAPP_OBJ_FILES),$(CY_BUILD_ALL_OBJ_FILES))

#
# Dependency files
#
CY_DEPENDENCY_FILES=$(CY_BUILD_ALL_OBJ_FILES:%.$(CY_TOOLCHAIN_SUFFIX_O)=%.$(CY_TOOLCHAIN_SUFFIX_D))

#
# The list of static libraries
#
CY_BUILD_ALL_LIB_FILES=$(CY_RECIPE_LIBS)

#
# Output directories
#
CY_BUILD_DIRS=$(sort $(call CY_MACRO_DIR,$(CY_BUILD_ALL_OBJ_FILES)) $(call CY_MACRO_DIR,$(CY_BUILD_TARGET)))

#
# Check Windows path length limit for build directories
#
ifeq ($(OS),Windows_NT)

ifeq ($(CY_SHELL_TYPE),shell)
CY_BUILD_CHECK_STRLEN:=$(shell \
	for directory in $(CY_BUILD_DIRS); do\
		if [ "$${#directory}" -ge 260 ]; then\
			echo "$$directory";\
		fi;\
	done)
else 
CY_BUILD_CHECK_STRLEN:=$(shell \
	for directory in $(CY_BUILD_DIRS); do\
		if [ "$${\#directory}" -ge 260 ]; then\
			echo "$$directory";\
		fi;\
	done)
endif

ifneq ($(strip $(CY_BUILD_CHECK_STRLEN)),)
$(call CY_MACRO_ERROR,Detected path(s) that exceed the Windows path length: $(CY_BUILD_CHECK_STRLEN))
endif
endif

#
# Prints full/shortened source name
#
ifneq (,$(filter $(VERBOSE),true 1))
CY_COMPILE_PRINT=$<
else
CY_COMPILE_PRINT=$(notdir $<)
endif

#
# Construct the full list of flags
#
CY_BUILD_ALL_ASFLAGS_UC=\
	$(CY_RECIPE_ASFLAGS)\
	$(CY_RECIPE_DEFINES)

CY_BUILD_ALL_ASFLAGS_LC=\
	$(CY_RECIPE_ASFLAGS)

CY_BUILD_ALL_CFLAGS=\
	$(CY_RECIPE_CFLAGS)\
	$(CY_RECIPE_DEFINES)

CY_BUILD_ALL_CXXFLAGS=\
	$(CY_RECIPE_CXXFLAGS)\
	$(CY_RECIPE_DEFINES)

#
# Compiler arguments
#
CY_BUILD_COMPILE_AS_UC:=$(AS) $(CY_BUILD_ALL_ASFLAGS_UC) $(CY_TOOLCHAIN_INCRSPFILE_ASM)$(CY_CONFIG_DIR)/inclist.rsp \
						$(CY_BUILD_SHAREDLIB_INCLIST) $(CY_TOOLCHAIN_OUTPUT_OPTION)
CY_BUILD_COMPILE_AS_LC:=$(AS) $(CY_BUILD_ALL_ASFLAGS_LC) $(CY_TOOLCHAIN_INCRSPFILE_ASM)$(CY_CONFIG_DIR)/inclist.rsp \
						$(CY_BUILD_SHAREDLIB_INCLIST) $(CY_TOOLCHAIN_OUTPUT_OPTION)
CY_BUILD_COMPILE_C:=$(CC) $(CY_BUILD_ALL_CFLAGS) $(CY_TOOLCHAIN_INCRSPFILE)$(CY_CONFIG_DIR)/inclist.rsp \
						$(CY_BUILD_SHAREDLIB_INCLIST) $(CY_TOOLCHAIN_DEPENDENCIES) $(CY_TOOLCHAIN_OUTPUT_OPTION) 
CY_BUILD_COMPILE_CPP:=$(CXX) $(CY_BUILD_ALL_CXXFLAGS) $(CY_TOOLCHAIN_INCRSPFILE)$(CY_CONFIG_DIR)/inclist.rsp \
						$(CY_BUILD_SHAREDLIB_INCLIST) $(CY_TOOLCHAIN_DEPENDENCIES) $(CY_TOOLCHAIN_OUTPUT_OPTION)
CY_BUILD_COMPILE_EXPLICIT_C:=$(CC) $(CY_BUILD_ALL_CFLAGS) $(CY_TOOLCHAIN_INCRSPFILE)$(CY_CONFIG_DIR)/inclist.rsp \
						$(CY_BUILD_SHAREDLIB_INCLIST) $(CY_TOOLCHAIN_EXPLICIT_DEPENDENCIES) $(CY_TOOLCHAIN_OUTPUT_OPTION) 
CY_BUILD_COMPILE_EXPLICIT_CPP:=$(CXX) $(CY_BUILD_ALL_CXXFLAGS) $(CY_TOOLCHAIN_INCRSPFILE)$(CY_CONFIG_DIR)/inclist.rsp \
						$(CY_BUILD_SHAREDLIB_INCLIST) $(CY_TOOLCHAIN_EXPLICIT_DEPENDENCIES) $(CY_TOOLCHAIN_OUTPUT_OPTION) 

#
# Linker arguments
#
CY_BUILD_LINK=$(LD) $(CY_RECIPE_LDFLAGS) $(CY_TOOLCHAIN_OUTPUT_OPTION) $@ $(CY_TOOLCHAIN_MAPFILE)$(CY_BUILD_MAPFILE) \
			$(CY_TOOLCHAIN_OBJRSPFILE)$(CY_CONFIG_DIR)/objlist.rsp \
			$(CY_TOOLCHAIN_STARTGROUP) $(CY_RECIPE_EXTRA_LIBS) $(CY_BUILD_ALL_LIB_FILES) $(CY_BUILD_SHAREDLIB_LIBLIST) $(CY_TOOLCHAIN_ENDGROUP)
CY_BUILD_LINK_STANDALONE=$(LD) $(CY_RECIPE_LDFLAGS) $(CY_TOOLCHAIN_OUTPUT_OPTION) $@ $(CY_TOOLCHAIN_MAPFILE)$(CY_BUILD_MAPFILE) \
			$(CY_TOOLCHAIN_OBJRSPFILE)$(CY_CONFIG_DIR)/objlist_standalone.rsp \
			$(CY_TOOLCHAIN_STARTGROUP) $(CY_RECIPE_EXTRA_LIBS) $(CY_BUILD_ALL_LIB_FILES) $(CY_BUILD_SHAREDLIB_LIBLIST) $(CY_TOOLCHAIN_ENDGROUP)

#
# Archiver arguments
#
CY_BUILD_ARCHIVE=$(AR) $(CY_RECIPE_ARFLAGS) $(CY_TOOLCHAIN_OUTPUT_OPTION) $@ $(CY_TOOLCHAIN_OBJRSPFILE)$(CY_CONFIG_DIR)/objlist.rsp 


################################################################################
# Dependency construction
################################################################################

#
# Dependency variables for compilation
#
CY_BUILD_COMPILER_DEPS=\
	$(CY_BUILD_COMPILE_AS_UC)\
	$(CY_BUILD_COMPILE_AS_LC)\
	$(CY_BUILD_COMPILE_C)\
	$(CY_BUILD_COMPILE_CPP)\
	$(CY_RECIPE_INCLUDES)

#
# Dependency variables for link/archive
#
CY_BUILD_LINKER_DEPS=\
	$(CY_BUILD_LINK)\
	$(CY_BUILD_ARCHIVE)\
	$(CY_SHAREDLIB_LIBS_EXPORT_LIST)\
	$(CY_SHAREDLIB_ARTIFACT_EXPORT_LIST)

#
# Take care of the quotes and dollar signs for the echo command
#
CY_BUILD_COMPILER_DEPS_FORMATTED=$(subst $,,$(subst ',,$(subst ",,$(CY_BUILD_COMPILER_DEPS))))
CY_BUILD_LINKER_DEPS_FORMATTED=$(subst $,,$(subst ',,$(subst ",,$(CY_BUILD_LINKER_DEPS))))


################################################################################
# Compilation rules construction
################################################################################

# Create explicit rules for auto-discovered (relative path) files
$(foreach explicit,$(CY_RECIPE_SOURCE),$(eval $(call \
CY_MACRO_EXPLICIT_RULE,$(explicit),$(patsubst $(CY_INTERNAL_APP_PATH)/%,%,$(patsubst $(CY_INTERNAL_EXTAPP_PATH)/%,%,$(addsuffix \
.$(CY_TOOLCHAIN_SUFFIX_O),$(basename $(explicit))))),app)))

# Create explicit rules for generated (relative/absolute path) files
$(foreach explicit,$(CY_RECIPE_GENERATED),$(eval $(call \
CY_MACRO_EXPLICIT_RULE,$(explicit),$(patsubst $(CY_BUILDTARGET_DIR)/%,%,$(addsuffix \
.$(CY_TOOLCHAIN_SUFFIX_O),$(basename $(explicit)))),generated)))

# Create explicit rules for ext (relative path) files
$(foreach explicit,$(CY_BUILD_EXTSRC_RELATIVE),$(eval $(call \
CY_MACRO_EXPLICIT_RULE,$(explicit),$(addprefix ext/,$(patsubst $(CY_INTERNAL_APP_PATH)/%,/%,$(subst ../,,$(addsuffix \
.$(CY_TOOLCHAIN_SUFFIX_O),$(basename $(explicit)))))),ext)))

# Create explicit rules for ext (absolute path) files
$(foreach explicit,$(CY_BUILD_EXTSRC_ABSOLUTE),$(eval $(call \
CY_MACRO_EXPLICIT_RULE,$(explicit),$(addprefix ext/,$(notdir $(addsuffix \
.$(CY_TOOLCHAIN_SUFFIX_O),$(basename $(explicit))))),ext)))

# Create explicit rules for dependent app c-files
$(foreach explicit,$(CY_DEPAPP_C_FILES),$(eval $(call \
CY_MACRO_EXPLICIT_RULE,$(explicit),$(addprefix dep_apps/,$(notdir $(addsuffix \
.$(CY_TOOLCHAIN_SUFFIX_O),$(basename $(explicit))))),dep_apps)))


################################################################################
# Link and Postbuild
################################################################################

#
# Empty target intentional 
#
prebuild:

#
# Dependencies
#
build: prebuild app memcalc
qbuild: prebuild app memcalc
memcalc: app

#
# Top-level application dependency
#
app: CY_BUILD_postprint

#
# Print information before we start the build
#
CY_BUILD_preprint:
	$(info )
	$(info ==============================================================================)
	$(info = Building application =)
	$(info ==============================================================================)

#
# Create the directories needed to do the build
#
CY_BUILD_mkdirs: CY_BUILD_preprint
	$(CY_NOISE)mkdir -p $(CY_BUILD_DIRS) $(CY_CMD_TERM)
ifeq ($(CY_RECIPE_GENERATED_FLAG),TRUE)
	$(CY_NOISE)mkdir -p $(CY_GENERATED_DIR) $(CY_CMD_TERM)
endif

#
# Run generate source step
#
CY_BUILD_gensrc: CY_BUILD_mkdirs
ifeq ($(CY_RECIPE_GENERATED_FLAG),TRUE)
	$(CY_NOISE)mkdir -p $(CY_GENERATED_DIR) $(CY_CMD_TERM)
ifneq ($(CY_SEARCH_RESOURCE_FILES),)
	$(CY_NOISE)echo $(CY_RECIPE_RESOURCE_FILES) > $(CY_GENERATED_DIR)/resources.cyrsc
endif
	$(CY_NOISE)$(CY_RECIPE_GENSRC) $(CY_CMD_TERM)
	$(info Generated $(words $(CY_RECIPE_GENERATED)) source file(s))
endif

#
# Add dependancy to support parallel builds
#
$(CY_BUILD_GENSRC_C_FILES): | CY_BUILD_gensrc

#
# Create .cycompiler file
#
$(CY_CONFIG_DIR)/.cycompiler: CY_BUILD_mkdirs
	$(CY_NOISE)echo "$(CY_BUILD_COMPILER_DEPS_FORMATTED)" > $(CY_CONFIG_DIR)/.cycompiler_tmp; \
	if ! cmp -s "$(CY_CONFIG_DIR)/.cycompiler" "$(CY_CONFIG_DIR)/.cycompiler_tmp"; then \
	    mv -f "$(CY_CONFIG_DIR)/.cycompiler_tmp" "$(CY_CONFIG_DIR)/.cycompiler" ; \
	else \
	    rm -f "$(CY_CONFIG_DIR)/.cycompiler_tmp"; \
	fi

#
# Create .cylinker file
#
$(CY_CONFIG_DIR)/.cylinker: CY_BUILD_mkdirs
	$(CY_NOISE)echo "$(CY_BUILD_LINKER_DEPS_FORMATTED)" > $(CY_CONFIG_DIR)/.cylinker_tmp; \
	if ! cmp -s "$(CY_CONFIG_DIR)/.cylinker" "$(CY_CONFIG_DIR)/.cylinker_tmp"; then \
	    mv -f "$(CY_CONFIG_DIR)/.cylinker_tmp" "$(CY_CONFIG_DIR)/.cylinker" ; \
	else \
	    rm -f "$(CY_CONFIG_DIR)/.cylinker_tmp"; \
	fi

#
# Print before compilation
#
CY_BUILD_precompile: CY_BUILD_gensrc $(CY_CONFIG_DIR)/.cycompiler $(CY_CONFIG_DIR)/.cylinker
	$(info Building $(words $(CY_BUILD_ALL_OBJ_FILES)) file(s))
	$(CY_NOISE)$(CY_SEARCH_GENERATE_QBUILD)
	$(CY_NOISE)echo $(CY_RECIPE_INCLUDES) | tr " " "\n" > $(CY_CONFIG_DIR)/inclist.rsp; \
	 echo $(CY_BUILD_ALL_OBJ_FILES) | tr " " "\n"  > $(CY_CONFIG_DIR)/objlist.rsp; \
	 echo $(CY_BUILD_ALL_LIB_FILES) | tr " " "\n"  > $(CY_CONFIG_DIR)/liblist.rsp;
# Create an artifact sentinel file for shared libs and dependent apps
ifneq ($(strip $(CY_BUILD_ALL_OBJ_FILES) $(CY_BUILD_ALL_LIB_FILES)),)
	$(CY_NOISE)echo $(notdir $(CY_BUILD_TARGET)) > $(CY_CONFIG_DIR)/artifact.rsp
else
	$(CY_NOISE)rm -f $(CY_CONFIG_DIR)/artifact.rsp \
	touch $(CY_CONFIG_DIR)/artifact.rsp
endif
# Create a file to store the shared directory used in dependent apps
ifneq ($(CY_INTERNAL_EXTAPP_PATH),)
	$(CY_NOISE)echo $(abspath $(CY_INTERNAL_EXTAPP_PATH)) | tr " " "\n"  > $(CY_CONFIG_DIR)/extapp.rsp;
endif
# Create a file to hold the list of object files excluding the dependent app c-arrays
ifneq ($(DEPENDENT_APP_PATHS),)
	$(CY_NOISE)echo $(CY_DEPAPP_OBJ_FILES_WO) | tr " " "\n"  > $(CY_CONFIG_DIR)/objlist_standalone.rsp
endif

#
# Dependencies for compilation
#
$(CY_BUILD_ALL_OBJ_FILES): | CY_BUILD_precompile 
$(CY_BUILD_ALL_OBJ_FILES): $(CY_CONFIG_DIR)/.cycompiler $(CY_SHAREDLIB_INCLUDES_EXPORT_LIST)

#
# Dependencies for link
#
$(CY_BUILD_TARGET): | CY_BUILD_precompile
$(CY_BUILD_TARGET): $(CY_CONFIG_DIR)/.cylinker $(CY_RECIPE_EXTRA_LIBS) $(CY_SHAREDLIB_LIBS_EXPORT_LIST) $(CY_SHAREDLIB_ARTIFACT_EXPORT_LIST) $(CY_SHAREDLIB_ARTIFACTS)

#
# Link/archive the application
#
ifneq ($(LIBNAME),)
$(CY_BUILD_TARGET): $(CY_BUILD_ALL_OBJ_FILES) $(CY_BUILD_ALL_LIB_FILES)
ifneq ($(strip $(CY_BUILD_ALL_OBJ_FILES) $(CY_BUILD_ALL_LIB_FILES)),)
	$(info $(CY_INDENT)Archiving output file $(notdir $@))
	$(CY_NOISE)$(CY_BUILD_ARCHIVE) $(CY_CMD_TERM)
endif
else
$(CY_BUILD_TARGET): $(CY_BUILD_ALL_OBJ_FILES) $(CY_BUILD_ALL_LIB_FILES) $(LINKER_SCRIPT)
	$(info $(CY_INDENT)Linking output file $(notdir $@))
	$(CY_NOISE)$(CY_BUILD_LINK)
endif

#
# Link the standalone application (excludes the dependent apps)
#
ifneq ($(DEPENDENT_APP_PATHS),)
$(CY_DEPAPP_TARGET): $(CY_DEPAPP_OBJ_FILES_WO) $(CY_BUILD_ALL_LIB_FILES) $(LINKER_SCRIPT)
	$(info $(CY_INDENT)Linking standalone file $(notdir $@))
	$(CY_NOISE)$(CY_BUILD_LINK_STANDALONE)
endif

#
# Perform post-build step
#
CY_BUILD_postbuild: $(CY_BUILD_TARGET) $(CY_DEPAPP_TARGET)
	$(CY_NOISE)$(CY_RECIPE_POSTBUILD) $(CY_CMD_TERM)

#
# Run BSP post-build step
#
CY_BUILD_bsp_postbuild: CY_BUILD_postbuild
	$(CY_BSP_POSTBUILD)

#
# Perform application post-build step
#
CY_BUILD_app_postbuild: CY_BUILD_bsp_postbuild
	$(POSTBUILD)

#
# Perform the post build print step, basically stating we are done
#
CY_BUILD_postprint: CY_BUILD_app_postbuild
	$(info ==============================================================================)
	$(info = Build complete =)
	$(info ==============================================================================)
	$(info )

#
# Include generated dependency files (if rebuilding)
#
-include $(CY_DEPENDENCY_FILES)

$(info Build rules construction complete)

#
# Indicate all phony targets that should be built regardless
#
.PHONY: app
.PHONY: CY_BUILD_mkdirs
.PHONY: CY_BUILD_postbuild CY_BUILD_app_postbuild CY_BUILD_bsp_postbuild
.PHONY: CY_BUILD_gensrc
.PHONY: CY_BUILD_preprint
.PHONY: CY_BUILD_postprint 
