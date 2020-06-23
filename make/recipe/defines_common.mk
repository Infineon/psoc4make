################################################################################
# \file defines_common.mk
#
# \brief
# Common PSoC-specific variables and targets for defines.mk
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


################################################################################
# General
################################################################################

#
# List the supported toolchains
#
CY_SUPPORTED_TOOLCHAINS=GCC_ARM IAR ARM A_Clang


################################################################################
# BSP Generation
################################################################################

# Command for copying linker scripts and starups (Note: this doesn't get expanded and used until "bsp" target)
ifeq ($(sort $(CY_BSP_LINKER_SCRIPT) $(CY_BSP_STARTUP)),)
CY_BSP_TEMPLATES_CMD=echo "Could not determine linker scripts and startup files for DEVICE $(DEVICE_GEN). Skipping update...";
else
CY_BSP_TEMPLATES_CMD=\
	if [ -d $(CY_BSP_TEMPLATES_DIR) ]; then \
		echo "Populating $(CY_BSP_LINKER_SCRIPT) linker scripts and $(CY_BSP_STARTUP) startup files...";\
		rm -rf $(CY_BSP_DESTINATION_DIR);\
		pushd  $(CY_BSP_TEMPLATES_DIR) 1> /dev/null;\
		$(CY_FIND) . -type d -exec mkdir -p $(CY_BSP_DESTINATION_ABSOLUTE)/'{}' \; ;\
		$(CY_FIND) . -type f \( \
		$(CY_BSP_SEARCH_FILES_CMD) \
		\) -exec cp -p '{}' $(CY_BSP_DESTINATION_ABSOLUTE)/'{}' \; ;\
		popd 1> /dev/null;\
	else \
		echo "Could not detect template linker scripts and startup files. Skipping update...";\
	fi;
endif

# Command for updating the device(s) (Note: this doesn't get expanded and used until "bsp" target)
CY_BSP_DEVICES_CMD=\
	designFile=$$($(CY_FIND) $(CY_TARGET_GEN_DIR) -name *.modus);\
	if [[ $$designFile ]]; then\
		echo "Running device-configurator for $(DEVICE_GEN) $(ADDITIONAL_DEVICES_GEN)...";\
		$(CY_CONFIG_MODUS_EXEC)\
		$(CY_CONFIG_LIBFILE)\
		--build $$designFile\
		--set-device=$(subst $(CY_SPACE),$(CY_COMMA),$(DEVICE_GEN) $(ADDITIONAL_DEVICES_GEN));\
		cfgStatus=$$(echo $$?);\
		if [ $$cfgStatus != 0 ]; then echo "ERROR: Device-configuration failed for $$designFile"; exit $$cfgStatus; fi;\
	else\
		echo "Could not detect .modus file. Skipping update...";\
	fi;


################################################################################
# Paths
################################################################################

# Paths used in program/debug
ifeq ($(CY_DEVICESUPPORT_PATH),)
CY_OPENOCD_SVD_PATH?=
else
CY_OPENOCD_SVD_PATH?=
endif

# Set the output file paths
ifneq ($(CY_BUILD_LOCATION),)
CY_SYM_FILE?=$(CY_INTERNAL_BUILD_LOC)/$(TARGET)/$(CONFIG)/$(APPNAME).$(CY_TOOLCHAIN_SUFFIX_TARGET)
CY_PROG_FILE?=$(CY_INTERNAL_BUILD_LOC)/$(TARGET)/$(CONFIG)/$(APPNAME).$(CY_TOOLCHAIN_SUFFIX_PROGRAM)
else
CY_SYM_FILE?=\$$\{cy_prj_path\}/$(notdir $(CY_INTERNAL_BUILD_LOC))/$(TARGET)/$(CONFIG)/$(APPNAME).$(CY_TOOLCHAIN_SUFFIX_TARGET)
CY_PROG_FILE?=\$$\{cy_prj_path\}/$(notdir $(CY_INTERNAL_BUILD_LOC))/$(TARGET)/$(CONFIG)/$(APPNAME).$(CY_TOOLCHAIN_SUFFIX_PROGRAM)
endif


################################################################################
# IDE specifics
################################################################################

ifeq ($(filter vscode,$(MAKECMDGOALS)),vscode)

CY_GCC_BASE_DIR=$(subst $(CY_INTERNAL_TOOLS)/,,$(CY_INTERNAL_TOOL_gcc_BASE))
CY_GCC_VERSION=$(shell $(CY_INTERNAL_TOOL_arm-none-eabi-gcc_EXE) -dumpversion)

ifneq ($(CY_BUILD_LOCATION),)
CY_ELF_FILE?=$(CY_INTERNAL_BUILD_LOC)/$(TARGET)/$(CONFIG)/$(APPNAME).$(CY_TOOLCHAIN_SUFFIX_TARGET)
CY_HEX_FILE?=$(CY_INTERNAL_BUILD_LOC)/$(TARGET)/$(CONFIG)/$(APPNAME).$(CY_TOOLCHAIN_SUFFIX_PROGRAM)
else
CY_ELF_FILE?=./$(notdir $(CY_INTERNAL_BUILD_LOC))/$(TARGET)/$(CONFIG)/$(APPNAME).$(CY_TOOLCHAIN_SUFFIX_TARGET)
CY_HEX_FILE?=./$(notdir $(CY_INTERNAL_BUILD_LOC))/$(TARGET)/$(CONFIG)/$(APPNAME).$(CY_TOOLCHAIN_SUFFIX_PROGRAM)
endif

CY_VSCODE_ARGS="s|&&CY_ELF_FILE&&|$(CY_ELF_FILE)|g;"\
				"s|&&CY_HEX_FILE&&|$(CY_HEX_FILE)|g;"\
				"s|&&CY_OPEN_OCD_FILE&&|$(CY_OPENOCD_DEVICE_CFG)|g;"\
				"s|&&CY_SVD_FILE_NAME&&|$(CY_OPENOCD_SVD_PATH)|g;"\
				"s|&&CY_MTB_PATH&&|$(CY_TOOLS_DIR)|g;"\
				"s|&&CY_TOOL_CHAIN_DIRECTORY&&|$(subst ",,$(CY_CROSSPATH))|g;"\
				"s|&&CY_C_FLAGS&&|$(CY_RECIPE_CFLAGS)|g;"\
 				"s|&&CY_GCC_VERSION&&|$(CY_GCC_VERSION)|g;"

ifeq ($(CY_USE_CUSTOM_GCC),true)
CY_VSCODE_ARGS+="s|&&CY_GCC_BIN_DIR&&|$(CY_INTERNAL_TOOL_gcc_BASE)/bin|g;"\
 				"s|&&CY_GCC_DIRECTORY&&|$(CY_INTERNAL_TOOL_gcc_BASE)|g;"
else
CY_VSCODE_ARGS+="s|&&CY_GCC_BIN_DIR&&|$$\{config:modustoolbox.toolsPath\}/$(CY_GCC_BASE_DIR)/bin|g;"\
 				"s|&&CY_GCC_DIRECTORY&&|$$\{config:modustoolbox.toolsPath\}/$(CY_GCC_BASE_DIR)|g;"
endif

endif


################################################################################
# Tools specifics
################################################################################

ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_CAPSENSE)))
CY_SUPPORTED_TOOL_TYPES+=capsense-configurator capsense-tuner
endif

CY_BT_ENABLED_DEVICE_COMPONENTS=43012 4343W 43438
ifneq ($(filter $(CY_BT_ENABLED_DEVICE_COMPONENTS),$(COMPONENTS)),)
CY_SUPPORTED_TOOL_TYPES+=bt-configurator
endif
ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_BLE)))
CY_SUPPORTED_TOOL_TYPES+=bt-configurator
endif

ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FS_USB)))
CY_SUPPORTED_TOOL_TYPES+=usbdev-configurator
endif

CY_SUPPORTED_TOOL_TYPES+=\
	device-configurator\
	seglcd-configurator\
	smartio-configurator\
	dfuh-tool
