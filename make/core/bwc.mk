################################################################################
# \file bwc.mk
#
# \brief
# Backwards-compatibility variables
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


##########################
# Tool paths
##########################

ifneq ($(CY_TOOL_make_BASE),)
CY_INTERNAL_TOOL_make_BASE:=$(CY_INTERNAL_TOOLS)/$(CY_TOOL_make_BASE)
else
CY_INTERNAL_TOOL_make_BASE:=$(CY_MAKEFILES_DIR)
endif

ifneq ($(CY_TOOL_cfg-backend-cli_EXE),)
CY_INTERNAL_TOOL_cfg-backend-cli_EXE:=$(CY_INTERNAL_TOOLS)/$(CY_TOOL_cfg-backend-cli_EXE)
else
CY_INTERNAL_TOOL_cfg-backend-cli_EXE:=$(CY_CFG_BACKEND_CLI_DIR)/cfg-backend-cli
endif

ifneq ($(CY_TOOL_device-configurator_EXE),)
CY_INTERNAL_TOOL_device-configurator_EXE:=$(CY_INTERNAL_TOOLS)/$(CY_TOOL_device-configurator_EXE)
else
CY_INTERNAL_TOOL_device-configurator_EXE:=$(CY_DEVICE_CONFIGURATOR_DIR)/device-configurator
endif

ifneq ($(CY_TOOL_capsense-configurator_EXE),)
CY_INTERNAL_TOOL_capsense-configurator_EXE:=$(CY_INTERNAL_TOOLS)/$(CY_TOOL_capsense-configurator_EXE)
else
CY_INTERNAL_TOOL_capsense-configurator_EXE:=$(CY_CAPSENSE_CONFIGURATOR_DIR)/capsense-configurator
endif

ifneq ($(CY_TOOL_capsense-tuner_EXE),)
CY_INTERNAL_TOOL_capsense-tuner_EXE:=$(CY_INTERNAL_TOOLS)/$(CY_TOOL_capsense-tuner_EXE)
else
CY_INTERNAL_TOOL_capsense-tuner_EXE:=$(CY_CAPSENSE_CONFIGURATOR_DIR)/capsense-tuner
endif

ifneq ($(CY_TOOL_bt-configurator-cli_EXE),)
CY_INTERNAL_TOOL_bt-configurator-cli_EXE:=$(CY_INTERNAL_TOOLS)/$(CY_TOOL_bt-configurator-cli_EXE)
else
CY_INTERNAL_TOOL_bt-configurator-cli_EXE:=$(CY_BT_CONFIGURATOR_DIR)/bt-configurator-cli
endif

ifneq ($(CY_TOOL_bt-configurator_EXE),)
CY_INTERNAL_TOOL_bt-configurator_EXE:=$(CY_INTERNAL_TOOLS)/$(CY_TOOL_bt-configurator_EXE)
else
CY_INTERNAL_TOOL_bt-configurator_EXE:=$(CY_BT_CONFIGURATOR_DIR)/bt-configurator
endif

ifneq ($(CY_TOOL_cype-tool_EXE),)
CY_INTERNAL_TOOL_cype-tool_EXE:=$(CY_INTERNAL_TOOLS)/$(CY_TOOL_cype-tool_EXE)
else
CY_INTERNAL_TOOL_cype-tool_EXE:=$(CY_PE_TOOL_DIR)/cype-tool
endif

ifneq ($(CY_TOOL_dfuh-tool_EXE),)
CY_INTERNAL_TOOL_dfuh-tool_EXE:=$(CY_INTERNAL_TOOLS)/$(CY_TOOL_dfuh-tool_EXE)
else
CY_INTERNAL_TOOL_dfuh-tool_EXE:=$(CY_DFUH_TOOL_DIR)/dfuh-tool
endif

ifneq ($(CY_TOOL_qspi-configurator_EXE),)
CY_INTERNAL_TOOL_qspi-configurator_EXE:=$(CY_INTERNAL_TOOLS)/$(CY_TOOL_qspi-configurator_EXE)
else
CY_INTERNAL_TOOL_qspi-configurator_EXE:=$(CY_QSPI_CONFIGURATOR_DIR)/qspi-configurator
endif

ifneq ($(CY_TOOL_seglcd-configurator_EXE),)
CY_INTERNAL_TOOL_seglcd-configurator_EXE:=$(CY_INTERNAL_TOOLS)/$(CY_TOOL_seglcd-configurator_EXE)
else
CY_INTERNAL_TOOL_seglcd-configurator_EXE:=$(CY_SEGLCD_CONFIGURATOR_DIR)/seglcd-configurator
endif

ifneq ($(CY_TOOL_smartio-configurator_EXE),)
CY_INTERNAL_TOOL_smartio-configurator_EXE:=$(CY_INTERNAL_TOOLS)/$(CY_TOOL_smartio-configurator_EXE)
else
CY_INTERNAL_TOOL_smartio-configurator_EXE:=$(CY_SMARTIO_CONFIGURATOR_DIR)/smartio-configurator
endif

ifneq ($(CY_TOOL_usbdev-configurator-cli_EXE),)
CY_INTERNAL_TOOL_usbdev-configurator-cli_EXE:=$(CY_INTERNAL_TOOLS)/$(CY_TOOL_usbdev-configurator-cli_EXE)
else
CY_INTERNAL_TOOL_usbdev-configurator-cli_EXE:=$(CY_USBDEV_CONFIGURATOR_DIR)/usbdev-configurator-cli
endif

ifneq ($(CY_TOOL_usbdev-configurator_EXE),)
CY_INTERNAL_TOOL_usbdev-configurator_EXE:=$(CY_INTERNAL_TOOLS)/$(CY_TOOL_usbdev-configurator_EXE)
else
CY_INTERNAL_TOOL_usbdev-configurator_EXE:=$(CY_USBDEV_CONFIGURATOR_DIR)/usbdev-configurator
endif

ifneq ($(CY_TOOL_library-manager_EXE),)
CY_INTERNAL_TOOL_library-manager_EXE:=$(CY_INTERNAL_TOOLS)/$(CY_TOOL_library-manager_EXE)
else
CY_INTERNAL_TOOL_library-manager_EXE:=$(CY_LIBRARY_MANAGER_DIR)/library-manager
endif

ifneq ($(CY_TOOL_project-creator_EXE),)
CY_INTERNAL_TOOL_project-creator_EXE:=$(CY_INTERNAL_TOOLS)/$(CY_TOOL_project-creator_EXE)
else
CY_INTERNAL_TOOL_project-creator_EXE:=$(CY_PROJECT_CREATOR_DIR)/project-creator
endif

ifneq ($(CY_TOOL_openocd_EXE),)
CY_INTERNAL_TOOL_openocd_EXE:=$(CY_INTERNAL_TOOLS)/$(CY_TOOL_openocd_EXE)
else
CY_INTERNAL_TOOL_openocd_EXE:=$(CY_OPENOCD_DIR)/bin/openocd
endif

ifneq ($(CY_TOOL_openocd_scripts_SCRIPT),)
CY_INTERNAL_TOOL_openocd_scripts_SCRIPT:=$(CY_INTERNAL_TOOLS)/$(CY_TOOL_openocd_scripts_SCRIPT)
else
CY_INTERNAL_TOOL_openocd_scripts_SCRIPT:=$(CY_OPENOCD_DIR)/scripts
endif

ifneq ($(CY_TOOL_fw-loader_EXE),)
CY_INTERNAL_TOOL_fw-loader_EXE:=$(CY_INTERNAL_TOOLS)/$(CY_TOOL_fw-loader_EXE)
else
CY_INTERNAL_TOOL_fw-loader_EXE:=$(CY_FW_LOADER_DIR)/bin/fw-loader
endif

#
# Special handling for GCC
# 	app makefile - CY_COMPILER_PATH (if selected toolchain is GCC)
# 	startex.mk - CY_COMPILER_DIR
# 	app makefile and again in main.mk if not set - CY_COMPILER_GCC_ARM_DIR
#
ifneq ($(CY_COMPILER_GCC_ARM_DIR),)
CY_INTERNAL_GCC_PATH=$(CY_COMPILER_GCC_ARM_DIR)
CY_USE_CUSTOM_GCC=true
else
CY_INTERNAL_GCC_PATH=$(CY_COMPILER_DIR)
endif

ifeq ($(TOOLCHAIN),GCC_ARM)
ifneq ($(CY_COMPILER_PATH),)
CY_INTERNAL_GCC_PATH=$(CY_COMPILER_PATH)
CY_USE_CUSTOM_GCC=true
endif
endif

ifeq ($(CY_USE_CUSTOM_GCC),true)
CY_INTERNAL_TOOL_gcc_BASE:=$(CY_INTERNAL_GCC_PATH)
else
ifneq ($(CY_TOOL_gcc_BASE),)
CY_INTERNAL_TOOL_gcc_BASE:=$(CY_INTERNAL_TOOLS)/$(CY_TOOL_gcc_BASE)
else
CY_INTERNAL_TOOL_gcc_BASE:=$(CY_INTERNAL_GCC_PATH)
endif
endif

ifeq ($(CY_USE_CUSTOM_GCC),true)
CY_INTERNAL_TOOL_arm-none-eabi-gcc_EXE:=$(CY_INTERNAL_GCC_PATH)/bin/arm-none-eabi-gcc
else
ifneq ($(CY_TOOL_arm-none-eabi-gcc_EXE),)
CY_INTERNAL_TOOL_arm-none-eabi-gcc_EXE:=$(CY_INTERNAL_TOOLS)/$(CY_TOOL_arm-none-eabi-gcc_EXE)
else
CY_INTERNAL_TOOL_arm-none-eabi-gcc_EXE:=$(CY_INTERNAL_GCC_PATH)/bin/arm-none-eabi-gcc
endif
endif

ifeq ($(CY_USE_CUSTOM_GCC),true)
CY_INTERNAL_TOOL_arm-none-eabi-g++_EXE:=$(CY_INTERNAL_GCC_PATH)/bin/arm-none-eabi-g++
else
ifneq ($(CY_TOOL_arm-none-eabi-g++_EXE),)
CY_INTERNAL_TOOL_arm-none-eabi-g++_EXE:=$(CY_INTERNAL_TOOLS)/$(CY_TOOL_arm-none-eabi-g++_EXE)
else
CY_INTERNAL_TOOL_arm-none-eabi-g++_EXE:=$(CY_INTERNAL_GCC_PATH)/bin/arm-none-eabi-g++
endif
endif

ifeq ($(CY_USE_CUSTOM_GCC),true)
CY_INTERNAL_TOOL_arm-none-eabi-ar_EXE:=$(CY_INTERNAL_GCC_PATH)/bin/arm-none-eabi-ar
else
ifneq ($(CY_TOOL_arm-none-eabi-ar_EXE),)
CY_INTERNAL_TOOL_arm-none-eabi-ar_EXE:=$(CY_INTERNAL_TOOLS)/$(CY_TOOL_arm-none-eabi-ar_EXE)
else
CY_INTERNAL_TOOL_arm-none-eabi-ar_EXE:=$(CY_INTERNAL_GCC_PATH)/bin/arm-none-eabi-ar
endif
endif

ifeq ($(CY_USE_CUSTOM_GCC),true)
CY_INTERNAL_TOOL_arm-none-eabi-gdb_EXE:=$(CY_INTERNAL_GCC_PATH)/bin/arm-none-eabi-gdb
else
ifneq ($(CY_TOOL_arm-none-eabi-gdb_EXE),)
CY_INTERNAL_TOOL_arm-none-eabi-gdb_EXE:=$(CY_INTERNAL_TOOLS)/$(CY_TOOL_arm-none-eabi-gdb_EXE)
else
CY_INTERNAL_TOOL_arm-none-eabi-gdb_EXE:=$(CY_INTERNAL_GCC_PATH)/bin/arm-none-eabi-gdb
endif
endif

ifeq ($(CY_USE_CUSTOM_GCC),true)
CY_INTERNAL_TOOL_arm-none-eabi-objcopy_EXE:=$(CY_INTERNAL_GCC_PATH)/bin/arm-none-eabi-objcopy
else
ifneq ($(CY_TOOL_arm-none-eabi-objcopy_EXE),)
CY_INTERNAL_TOOL_arm-none-eabi-objcopy_EXE:=$(CY_INTERNAL_TOOLS)/$(CY_TOOL_arm-none-eabi-objcopy_EXE)
else
CY_INTERNAL_TOOL_arm-none-eabi-objcopy_EXE:=$(CY_INTERNAL_GCC_PATH)/bin/arm-none-eabi-objcopy
endif
endif

ifeq ($(CY_USE_CUSTOM_GCC),true)
CY_INTERNAL_TOOL_arm-none-eabi-readelf_EXE:=$(CY_INTERNAL_GCC_PATH)/bin/arm-none-eabi-readelf
else
ifneq ($(CY_TOOL_arm-none-eabi-readelf_EXE),)
CY_INTERNAL_TOOL_arm-none-eabi-readelf_EXE:=$(CY_INTERNAL_TOOLS)/$(CY_TOOL_arm-none-eabi-readelf_EXE)
else
CY_INTERNAL_TOOL_arm-none-eabi-readelf_EXE:=$(CY_INTERNAL_GCC_PATH)/bin/arm-none-eabi-readelf
endif
endif

##########################
# Dependent libs
##########################

# Externally use DEPENDENT_LIB_PATHS. Internally use SEARCH_LIBS_AND_INCLUDES to preserve BWC
ifneq ($(DEPENDENT_LIB_PATHS),)
SEARCH_LIBS_AND_INCLUDES+=$(DEPENDENT_LIB_PATHS)
endif
