################################################################################
# \file config.mk
#
# \brief
# Configurator-related routines
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

#
# Default file extension
#
CY_CONFIG_FILE_EXT?=modus


################################################################################
# Search
################################################################################

CY_CONFIG_MODUS_EXT=modus
CY_CONFIG_CYBT_EXT=cybt
CY_CONFIG_CYUSBDEV_EXT=cyusbdev

#
# Search for configuration files and filter
#
CY_CONFIG_MODUS_FILES:=$(call CY_MACRO_SEARCH,.$(CY_CONFIG_MODUS_EXT),$(CY_INTERNAL_APP_PATH))\
					$(if $(CY_INTERNAL_EXTAPP_PATH),$(call CY_MACRO_SEARCH,.$(CY_CONFIG_MODUS_EXT),$(CY_INTERNAL_EXTAPP_PATH)))\
					$(if $(SEARCH_LIBS_AND_INCLUDES),$(foreach d,$(SEARCH_LIBS_AND_INCLUDES),$(call CY_MACRO_SEARCH,.$(CY_CONFIG_MODUS_EXT),$(d))))
CY_CONFIG_CYBT_FILES:=$(call CY_MACRO_SEARCH,.$(CY_CONFIG_CYBT_EXT),$(CY_INTERNAL_APP_PATH))\
					$(if $(CY_INTERNAL_EXTAPP_PATH),$(call CY_MACRO_SEARCH,.$(CY_CONFIG_CYBT_EXT),$(CY_INTERNAL_EXTAPP_PATH)))\
					$(if $(SEARCH_LIBS_AND_INCLUDES),$(foreach d,$(SEARCH_LIBS_AND_INCLUDES),$(call CY_MACRO_SEARCH,.$(CY_CONFIG_CYBT_EXT),$(d))))
CY_CONFIG_CYUSBDEV_FILES:=$(call CY_MACRO_SEARCH,.$(CY_CONFIG_CYUSBDEV_EXT),$(CY_INTERNAL_APP_PATH))\
					$(if $(CY_INTERNAL_EXTAPP_PATH),$(call CY_MACRO_SEARCH,.$(CY_CONFIG_CYUSBDEV_EXT),$(CY_INTERNAL_EXTAPP_PATH)))\
					$(if $(SEARCH_LIBS_AND_INCLUDES),$(foreach d,$(SEARCH_LIBS_AND_INCLUDES),$(call CY_MACRO_SEARCH,.$(CY_CONFIG_CYUSBDEV_EXT),$(d))))

CY_SEARCH_PRUNED_MODUS_FILES:=$(filter-out $(foreach d,$(CY_IGNORE_DIRS),$(filter $(d)%,$(CY_CONFIG_MODUS_FILES))),$(CY_CONFIG_MODUS_FILES))
CY_SEARCH_PRUNED_CYBT_FILES:=$(filter-out $(foreach d,$(CY_IGNORE_DIRS),$(filter $(d)%,$(CY_CONFIG_CYBT_FILES))),$(CY_CONFIG_CYBT_FILES))
CY_SEARCH_PRUNED_CYUSBDEV_FILES:=$(filter-out $(foreach d,$(CY_IGNORE_DIRS),$(filter $(d)%,$(CY_CONFIG_CYUSBDEV_FILES))),$(CY_CONFIG_CYUSBDEV_FILES))

CY_SEARCH_AVAILABLE_MODUS_SOURCES=$(call CY_MACRO_FILTER_FILES,MODUS)
CY_SEARCH_AVAILABLE_CYBT_SOURCES=$(call CY_MACRO_FILTER_FILES,CYBT)
CY_SEARCH_AVAILABLE_CYUSBDEV_SOURCES=$(call CY_MACRO_FILTER_FILES,CYUSBDEV)

ifneq ($(words $(CY_SEARCH_AVAILABLE_MODUS_SOURCES)),1)
ifneq ($(words $(CY_SEARCH_AVAILABLE_MODUS_SOURCES)),0)
$(call CY_MACRO_ERROR,Multiple device configuration files detected: $(CY_SEARCH_AVAILABLE_MODUS_SOURCES))
endif
endif
ifneq ($(words $(CY_SEARCH_AVAILABLE_CYBT_SOURCES)),1)
ifneq ($(words $(CY_SEARCH_AVAILABLE_CYBT_SOURCES)),0)
$(call CY_MACRO_ERROR,Multiple BT configuration files detected: $(CY_SEARCH_AVAILABLE_CYBT_SOURCES))
endif
endif
ifneq ($(words $(CY_SEARCH_AVAILABLE_CYUSBDEV_SOURCES)),1)
ifneq ($(words $(CY_SEARCH_AVAILABLE_CYUSBDEV_SOURCES)),0)
$(call CY_MACRO_ERROR,Multiple USBDEV configuration files detected: $(CY_SEARCH_AVAILABLE_CYUSBDEV_SOURCES))
endif
endif


################################################################################
# Arguments constructions
################################################################################

##########################
# .modus (HW)
##########################

CY_CONFIG_MODUS_FILE?=$(CY_SEARCH_AVAILABLE_MODUS_SOURCES)
CY_CONFIG_MODUS_OUTPUT=$(call CY_MACRO_DIR,$(CY_CONFIG_MODUS_FILE))/GeneratedSource
CY_OPENOCD_QSPI_CFG_PATH=$(CY_CONFIG_MODUS_OUTPUT)

ifeq ($(CY_DEVICESUPPORT_PATH),)
CY_CONFIG_LIBFILE=
else
CY_CONFIG_LIBFILE=--library $(CY_INTERNAL_DEVICESUPPORT_PATH)/devicesupport.xml
endif

CY_CONFIG_MODUS_EXEC=$(CY_INTERNAL_TOOL_cfg-backend-cli_EXE)
ifneq ($(notdir $(CY_TOOLS_DIR)),tools_2.0)
CY_CONFIG_MODUS_EXEC_FLAGS=\
	$(CY_CONFIG_LIBFILE)\
	--build $(CY_CONFIG_MODUS_FILE)\
	--check-mcu=$(DEVICE)\
	--check-coprocessors=$(subst $(CY_SPACE),$(CY_COMMA),$(ADDITIONAL_DEVICES))
else
CY_CONFIG_MODUS_EXEC_FLAGS=\
	$(CY_CONFIG_LIBFILE)\
	--build $(CY_CONFIG_MODUS_FILE)\
	--set-device=$(subst $(CY_SPACE),$(CY_COMMA),$(DEVICE) $(ADDITIONAL_DEVICES))
endif

CY_CONFIG_MODUS_GUI=$(CY_INTERNAL_TOOL_device-configurator_EXE)
CY_CONFIG_MODUS_GUI_FLAGS=\
	--design

##########################
# .cybt (SW)
##########################

CY_CONFIG_CYBT_FILE?=$(CY_SEARCH_AVAILABLE_CYBT_SOURCES)
CY_CONFIG_CYBT_OUTPUT=$(call CY_MACRO_DIR,$(CY_CONFIG_CYBT_FILE))/GeneratedSource

CY_CONFIG_CYBT_EXEC=$(CY_INTERNAL_TOOL_bt-configurator-cli_EXE)
CY_CONFIG_CYBT_EXEC_FLAGS=\
	--config $(CY_CONFIG_CYBT_FILE)

CY_CONFIG_CYBT_GUI=$(CY_INTERNAL_TOOL_bt-configurator_EXE)
CY_CONFIG_CYBT_GUI_FLAGS=\
	--config

##########################
# .cyusbdev (SW)
##########################

CY_CONFIG_CYUSBDEV_FILE?=$(CY_SEARCH_AVAILABLE_CYUSBDEV_SOURCES)
CY_CONFIG_CYUSBDEV_OUTPUT=$(call CY_MACRO_DIR,$(CY_CONFIG_CYUSBDEV_FILE))/GeneratedSource

CY_CONFIG_CYUSBDEV_EXEC=$(CY_INTERNAL_TOOL_usbdev-configurator-cli_EXE)
CY_CONFIG_CYUSBDEV_EXEC_FLAGS=\
	--config $(CY_CONFIG_CYUSBDEV_FILE)

CY_CONFIG_CYUSBDEV_GUI=$(CY_INTERNAL_TOOL_usbdev-configurator_EXE)
CY_CONFIG_CYUSBDEV_GUI_FLAGS=\
	--config


################################################################################
# Source generation
################################################################################

CY_CONFIG_MODUS_TIMESTAMP=$(CY_CONFIG_MODUS_OUTPUT)/cycfg.timestamp
CY_CONFIG_CYBT_TIMESTAMP=$(CY_CONFIG_CYBT_OUTPUT)/cycfg_bt.timestamp
CY_CONFIG_CYUSBDEV_TIMESTAMP=$(CY_CONFIG_CYUSBDEV_OUTPUT)/cycfg_usbdev.timestamp

gen_config: $(CY_CONFIG_MODUS_TIMESTAMP) $(CY_CONFIG_CYBT_TIMESTAMP) $(CY_CONFIG_CYUSBDEV_TIMESTAMP)

$(CY_CONFIG_MODUS_TIMESTAMP): $(CY_CONFIG_MODUS_FILE)
ifneq ($(CY_CONFIG_MODUS_FILE),)
	$(info Running device-configurator to update stale files...)
	$(CY_NOISE)$(CY_CONFIG_MODUS_EXEC) $(CY_CONFIG_MODUS_EXEC_FLAGS)
	$(CY_NOISE)echo "-> Generated device configuration file(s) in $(CY_CONFIG_MODUS_OUTPUT)"
endif

$(CY_CONFIG_CYBT_TIMESTAMP): $(CY_CONFIG_CYBT_FILE)
ifneq ($(CY_CONFIG_CYBT_FILE),)
	$(info Running bt-configurator to update stale files...)
	$(CY_NOISE)$(CY_CONFIG_CYBT_EXEC) $(CY_CONFIG_CYBT_EXEC_FLAGS)
	$(CY_NOISE)echo "-> Generated bt configuration file(s) in $(CY_CONFIG_CYBT_OUTPUT)"
endif

$(CY_CONFIG_CYUSBDEV_TIMESTAMP): $(CY_CONFIG_CYUSBDEV_FILE)
ifneq ($(CY_CONFIG_CYUSBDEV_FILE),)
	$(info Running usbdev-configurator to update stale files...)
	$(CY_NOISE)$(CY_CONFIG_CYUSBDEV_EXEC) $(CY_CONFIG_CYUSBDEV_EXEC_FLAGS)
	$(CY_NOISE)echo "-> Generated usbdev configuration file(s) in $(CY_CONFIG_CYUSBDEV_OUTPUT)"
endif


################################################################################
# Configurator launch
################################################################################

# Extract the names for the variable name construction
CY_CONFIG_CONVERT=$(foreach ext,$(CY_CONFIG_FILE_EXT),$(call CY_MACRO_UC,$(ext)))

# Gather the files. Find all files that match the extensions in the design.modus location
CY_CONFIG_FILES=$(sort $(foreach ext,$(CY_CONFIG_CONVERT),$(CY_CONFIG_$(ext)_FILE))\
				$(foreach ext,$(CY_CONFIG_FILE_EXT),$(wildcard $(call CY_MACRO_DIR,$(CY_CONFIG_MODUS_FILE))/*.$(ext))))

# This setting allows the command to run in the background.  Some invocations of "make config"
# need to override this behavior (ex. VS Code in Windows)
CY_CONFIG_JOB_CONTROL=&

config:
ifeq ($(CY_CONFIG_MODUS_FILE),)
	$(info $(CY_NEWLINE)Could not find any device configuration files)
	$(info Launching device-configurator for a new configuration)
	$(CY_NOISE) $(CY_CONFIG_MODUS_GUI) $(CY_CONFIG_LIBFILE) $(CY_CONFIG_JOB_CONTROL)
else
	$(info $(CY_NEWLINE)Launching device-configurator on $(CY_CONFIG_MODUS_FILE))
	$(CY_NOISE) $(CY_CONFIG_MODUS_GUI) $(CY_CONFIG_LIBFILE) $(CY_CONFIG_MODUS_GUI_FLAGS) $(CY_CONFIG_MODUS_FILE) $(CY_CONFIG_JOB_CONTROL)
endif

config_bt:
ifeq ($(CY_CONFIG_CYBT_FILE),)
	$(info $(CY_NEWLINE)Could not find any bt-configuration files)
	$(info Launching bt-configurator for a new configuration)
	$(CY_NOISE) $(CY_CONFIG_CYBT_GUI) $(CY_CONFIG_JOB_CONTROL)
else
	$(info $(CY_NEWLINE)Launching bt-configurator on $(CY_CONFIG_CYBT_FILE))
	$(CY_NOISE) $(CY_CONFIG_CYBT_GUI) $(CY_CONFIG_CYBT_GUI_FLAGS) $(CY_CONFIG_CYBT_FILE) $(CY_CONFIG_JOB_CONTROL)
endif

config_usbdev:
ifeq ($(CY_CONFIG_CYUSBDEV_FILE),)
	$(info $(CY_NEWLINE)Could not find any usbdev-configuration files)
	$(info Launching usbdev-configurator for a new configuration)
	$(CY_NOISE) $(CY_CONFIG_CYUSBDEV_GUI) $(CY_CONFIG_JOB_CONTROL)
else
	$(info $(CY_NEWLINE)Launching usbdev-configurator on $(CY_CONFIG_CYUSBDEV_FILE))
	$(CY_NOISE) $(CY_CONFIG_CYUSBDEV_GUI) $(CY_CONFIG_CYUSBDEV_GUI_FLAGS) $(CY_CONFIG_CYUSBDEV_FILE) $(CY_CONFIG_JOB_CONTROL)
endif

.PHONY: gen_config
.PHONY: config config_bt config_usbdev
