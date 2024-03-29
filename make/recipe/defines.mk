################################################################################
# \file defines.mk
#
# \brief
# Defines, needed for the PSoC 4 build recipe.
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

include $(CY_INTERNAL_BASELIB_PATH)/make/recipe/defines_common.mk


################################################################################
# General
################################################################################

#
# Define the default core
#
CORE?=CM0P
CY_START_FLASH=0x00000000
CY_START_SRAM=0x20000000

#
# Architecure specifics
#
CY_OPENOCD_CHIP_NAME=psoc4
CY_OPENOCD_DEVICE_CFG=psoc4.cfg
CY_OPENOCD_OTHER_RUN_CMD?=mon psoc4 reset_halt
CY_OPENOCD_OTHER_RUN_CMD_ECLIPSE?=$(CY_OPENOCD_OTHER_RUN_CMD)\&\#13;\&\#10;

ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_PSOC4AS1)))
CY_PSOC_DIE_NAME=PSoC4AS1
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_PSOC4AS2)))
CY_PSOC_DIE_NAME=PSoC4AS2
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_PSOC4AS3)))
CY_PSOC_DIE_NAME=PSoC4AS3
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_PSOC4AMC)))
CY_PSOC_DIE_NAME=PSoC4AMC
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_PSOC4AS4)))
CY_PSOC_DIE_NAME=PSoC4AS4
else
$(call CY_MACRO_ERROR,Incorrect part number $(DEVICE). Check DEVICE variable.)
endif

#
# Flash memory specifics
#
ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_16)))
CY_MEMORY_FLASH=16384
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_32)))
CY_MEMORY_FLASH=32768
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_64)))
CY_MEMORY_FLASH=65536
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_128)))
CY_MEMORY_FLASH=131072
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_256)))
CY_MEMORY_FLASH=262144
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_384)))
CY_MEMORY_FLASH=393216
else
$(call CY_MACRO_ERROR,No Flash memory size defined for $(DEVICE))
endif

#
# SRAM memory specifics
#
ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_SRAM_KB_2)))
CY_MEMORY_SRAM=2048
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_SRAM_KB_4)))
CY_MEMORY_SRAM=4096
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_SRAM_KB_8)))
CY_MEMORY_SRAM=8192
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_SRAM_KB_16)))
CY_MEMORY_SRAM=16384
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_SRAM_KB_32)))
CY_MEMORY_SRAM=32768
else
$(call CY_MACRO_ERROR,No SRAM memory size defined for $(DEVICE))
endif

#
# linker scripts
#
ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_16)))
ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_SRAM_KB_4)))
CY_LINKER_SCRIPT_NAME=cy8c4xx4
else ifneq (,$(findstring CY8C47,$(DEVICE))) # PSoC 4700S, 2 KB SRAM
CY_LINKER_SCRIPT_NAME=cy8c47x4
else # PSoC 4000S, 2 KB SRAM
CY_LINKER_SCRIPT_NAME=cy8c40x4
endif


else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_32)))
CY_LINKER_SCRIPT_NAME=cy8c4xx5

else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_64)))
ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_SRAM_KB_8)))
CY_LINKER_SCRIPT_NAME=cy8c4xx6
else # 16 KB SRAM
CY_LINKER_SCRIPT_NAME=cy8c45x6
endif

else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_128)))
ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_SRAM_KB_16)))
CY_LINKER_SCRIPT_NAME=cy8c4xx7
else # 32 KB SRAM
CY_LINKER_SCRIPT_NAME=cy8c45x7
endif

else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_256)))
CY_LINKER_SCRIPT_NAME=cy8c4xx8

else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_384)))
CY_LINKER_SCRIPT_NAME=cy8c4xx9
endif

ifeq ($(CY_LINKER_SCRIPT_NAME),)
$(call CY_MACRO_ERROR,Could not resolve device series for linker script)
endif


################################################################################
# BSP generation
################################################################################

DEVICE_GEN?=$(DEVICE)
ADDITIONAL_DEVICES_GEN?=$(ADDITIONAL_DEVICES)

# Architecture specifics
ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_PSOC4AS1)))
CY_BSP_STARTUP=psoc4000s
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_PSOC4AS2)))
CY_BSP_STARTUP=psoc4100s
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_PSOC4AS3)))
CY_BSP_STARTUP=psoc4100sp
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_PSOC4AMC)))
CY_BSP_STARTUP=psoc4100sp256kb
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_PSOC4AS4)))
CY_BSP_STARTUP=psoc4as4 # TBD: datasheet name is not yet defined
endif

# Linker script
ifneq (,$(findstring $(DEVICE_GEN),$(CY_DEVICES_WITH_FLASH_KB_16)))
ifneq (,$(findstring $(DEVICE_GEN),$(CY_DEVICES_WITH_SRAM_KB_4)))
CY_BSP_LINKER_SCRIPT=cy8c4xx4
else ifneq (,$(findstring CY8C47,$(DEVICE_GEN))) # PSoC 4700S, 2 KB SRAM
CY_BSP_LINKER_SCRIPT=cy8c47x4
else # PSoC 4000S, 2 KB SRAM
CY_BSP_LINKER_SCRIPT=cy8c40x4
endif

else ifneq (,$(findstring $(DEVICE_GEN),$(CY_DEVICES_WITH_FLASH_KB_32)))
CY_BSP_LINKER_SCRIPT=cy8c4xx5

else ifneq (,$(findstring $(DEVICE_GEN),$(CY_DEVICES_WITH_FLASH_KB_64)))
ifneq (,$(findstring $(DEVICE_GEN),$(CY_DEVICES_WITH_SRAM_KB_8)))
CY_BSP_LINKER_SCRIPT=cy8c4xx6
else # 16 KB SRAM
CY_BSP_LINKER_SCRIPT=cy8c45x6
endif

else ifneq (,$(findstring $(DEVICE_GEN),$(CY_DEVICES_WITH_FLASH_KB_128)))
ifneq (,$(findstring $(DEVICE_GEN),$(CY_DEVICES_WITH_SRAM_KB_16)))
CY_BSP_LINKER_SCRIPT=cy8c4xx7
else # 32 KB SRAM
CY_BSP_LINKER_SCRIPT=cy8c45x7
endif

else ifneq (,$(findstring $(DEVICE_GEN),$(CY_DEVICES_WITH_FLASH_KB_256)))
CY_BSP_LINKER_SCRIPT=cy8c4xx8

else ifneq (,$(findstring $(DEVICE_GEN),$(CY_DEVICES_WITH_FLASH_KB_384)))
CY_BSP_LINKER_SCRIPT=cy8c4xx9
endif

# Paths
CY_BSP_TEMPLATES_DIR=$(call CY_MACRO_DIR,$(firstword $(CY_DEVICESUPPORT_SEARCH_PATH)))/devices/templates/COMPONENT_MTB
CY_BSP_DESTINATION_DIR=$(CY_TARGET_GEN_DIR)/TOOLCHAIN_*
CY_BSP_DESTINATION_ABSOLUTE=$(abspath $(CY_TARGET_GEN_DIR))

# Command for searching files in the template directory
CY_BSP_SEARCH_FILES_CMD=\
	-name "system_psoc4*" \
	-o -name "*$(CY_BSP_STARTUP).*" \
	-o -name "*$(CY_BSP_LINKER_SCRIPT).*"


################################################################################
# IDE specifics
################################################################################

ifeq ($(filter vscode,$(MAKECMDGOALS)),vscode)
CY_VSCODE_ARGS+="s|&&DEVICE&&|$(DEVICE)|g;"
endif

CY_ECLIPSE_ARGS="s|&&CY_OPENOCD_CFG&&|$(CY_OPENOCD_DEVICE_CFG)|g;"\
				"s|&&CY_OPENOCD_CHIP&&|$(CY_OPENOCD_CHIP_NAME)|g;"\
				"s|&&CY_OPENOCD_OTHER_RUN_CMD&&|$(CY_OPENOCD_OTHER_RUN_CMD_ECLIPSE)|g;"\
				"s|&&CY_JLINK_CFG_PROGRAM&&|$(DEVICE)|g;"\
				"s|&&CY_JLINK_CFG_DEBUG&&|$(DEVICE)|g;"\
				"s|&&CY_APPNAME&&|$(CY_IDE_PRJNAME)|g;"\
				"s|&&CY_CONFIG&&|$(CONFIG)|g;"\
				"s|&&CY_SVD_PATH&&|$(CY_OPENOCD_SVD_PATH)|g;"\
				"s|&&CY_SYM_FILE&&|$(CY_SYM_FILE)|g;"\
				"s|&&CY_PROG_FILE&&|$(CY_PROG_FILE)|g;"


################################################################################
# Tools specifics
################################################################################

# PSoC 4 smartio also uses the .modus extension
modus_DEFAULT_TYPE+=device-configurator smartio-configurator

# PSoC 4 capsense-tuner shares its existence with capsense-configurator
CY_OPEN_NEWCFG_XML_TYPES+=capsense-tuner
