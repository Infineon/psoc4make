# PSoC 4 GNU make Build System Release Notes
This repo provides the build recipe make files and scripts for building and programming PSoC 4 applications. Builds can be run either through a command-line interface (CLI) or through the ModusToolbox Integrated Development Environment (IDE).

### What's Included?
The this release of the PSoC 4 GNU make Build System includes complete support for building, programming, and debugging PSoC 4 application projects. It is expected that a code example contains a top level make file for itself and references a Board Support Package (BSP) that defines specifics items, like the PSoC 4 part, for the target board. Supported functionality includes the following:
* Supported operations:
    * Build
    * Program
    * Debug
    * IDE Integration (Eclipse, VS Code, IAR)
    * BSP Generation
* Supported toolchains:
    * GCC
    * IAR
    * ARMv6

This also includes the getlibs.bash script that can be used directly, or via the make target to download additional git repo based libraries for the application.

### What Changed?
#### v0.5.0
* Initial pre-production release

### Product/Asset Specific Instructions
Builds require that the ModusToolbox tools be installed on your machine. This comes with the ModusToolbox install. On Windows machines, it is recommended that CLI builds be executed using the Cygwin.bat located in ModusToolBox/tools_x.y/modus-shell install directory. This guarantees a consistent shell environment for your builds.

To list the build options, run the "help" target by typing "make help" in CLI. For a verbose documentation on a specific subject type "make help CY_HELP={variable/target}", where "variable" or "target" is one of the listed make variables or targets.

### Supported Software and Tools
This version of the PSoC 4 build system was validated for compatibility with the following Software and Tools:

| Software and Tools                        | Version |
| :---                                      | :----:  |
| ModusToolbox Software Environment         | 2.0     |
| GCC Compiler                              | 7.4     |
| IAR Compiler                              | 8.32    |
| ARM Compiler                              | 6.11    |

### More information
Use the following links for more information, as needed:
* [Cypress Semiconductor, an Infineon Technologies Company](http://www.cypress.com)
* [Cypress Semiconductor GitHub](https://github.com/cypresssemiconductorco)
* [ModusToolbox](https://www.cypress.com/products/modustoolbox-software-environment)

---
© Cypress Semiconductor Corporation, 2019-2020.