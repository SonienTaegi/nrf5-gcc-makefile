# nrf5-gcc-makefile
Universal gcc makefile to compile nrf5 series

* Notice
  Currently this make file was tested with below conditions.<br>
  Chipset : nrf51822, nrf52832<br>
  Soft device : S130, S132, S212

This makefile provides compiling configurations for nordic NRF51 and NRF52 series with any type of NRF5 11 soft device series. Simply replace original makefile with this and modify configuration parameters in the file. Or you may set compile option in shell or eclipse compile configuration. These parameters and compile options are introduced below. But before reading it, please read Pre-condition at first. The paragraph contains naming rules of project files.

## Pre-condition
1. Linker Script<br>
   .ld file should be named in this manner : chipset_chipset-variant_softdevice type.ld<br>
   For example : nrf51822_xxaa_s130.ld
2. Comming soon...

## Compile option
1. VERBOSE=1<br>
   This is original Makefile option. It is used for making syntax index profiling.
2. DEBUG=1<br>
   To set this compile option will include headers and sources of segger rtt. Also compiling macro _DEBUG will be defined automatically. You may use this option with "ifdef _DEBUG" in your source to make debug and release version at the same time. 

## Makefile configuration
1. Path
  - ROOT_PATH<br>
     Root path of the project. It can be both relative or absoulte path.
  - SDK_PATH<br>
     Root path of Soft Device SDK path.
  - DRIVER_PATH<br>
     Path of drivers_nrf. Mostly $(SDK_PATH)/components/drivers_nrf
  - LIB_PATH<br>
     Path of libraries. Mostly $(SDK_PATH)/components/libraries
  - TEMPLATE_PATH<br>
     Path of gcc templates. Mostly $(SDK_PATH)/components/toolchain/gcc

2. Chipset configuration
  - CHIPSET<br>
     Name of the chipset. nrf51822 or ntf52832. I have not yet tested other models.
  - CHIPSET_FAMILY<br>
     Name of chipset family. NRF51 or NRF52. This will automatically set ARM family option : Cortex-m0 / Cortex-m4f.
  - CHIPSET_VARIANT<br>
     Actually this parameter is now being used just for naming hex file.

3. Soft device
  - ENABLE_SOFTDEVICE<br>
     To set this 1 will includes headers and sources related soft device stack.
  - ENABLE_BLE<br>
     To set this 1 will includes headers and sources related soft device BLE stack.
  - ENABLE_ANT<br>
     To set this 1 will includes headers and sources related ANT stack.

4. Peripherals
  - ENABLE_PERIPHERAL<br>
     To set this 1 will includes common headers for using peripheral driver.  
     - Currently peripherals below are supported in this Makefile. These will be expanded when I need... or I will be so glad to anybody suggest cases. Plz help me :)
  - ENABLE_GPIO // This is for GPIOTE.
  - ENABLE_TIMER
  - ENABLE_PWM // Not implemented yet but will be soon.
  - ENABLE_TWI
  - ENABLE_PSTORAGE
