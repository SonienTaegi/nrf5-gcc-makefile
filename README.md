# nrf5-gcc-makefile
Universal gcc makefile to compile nrf5 series

* Notice
  Currently this make file was tested with below conditions.
  Chipset     : nrf51822, nrf52832
  Soft device : S130, S132, S212

This makefile provides compiling configurations for nordic NRF51 and NRF52 series with any type of NRF5 11 soft device series. Simply replace original makefile with this and modify configuration parameters in the file. Or you may set compile option in shell or eclipse compile configuration. These parameters and compile options are introduced below.

# Compile option
1. VERBOSE=1
   This is original Makefile option. It is used for making syntax index profiling.
2. DEBUG=1
   To set this compile option will include headers and sources of segger rtt. Also compiling macro _DEBUG will be defined automatically. You may use this option with "ifdef _DEBUG" in your source to make debug and release version at the same time. 

# Makefile configuration
1. Path
  a. ROOT_PATH       
     Root path of the project. It can be both relative or absoulte path.
  b. SDK_PATH
     Root path of Soft Device SDK path.
  c. DRIVER_PATH
     Path of drivers_nrf. Mostly $(SDK_PATH)/components/drivers_nrf
  d. LIB_PATH 		 
     Path of libraries. Mostly $(SDK_PATH)/components/libraries
  e. TEMPLATE_PATH 
     Path of gcc templates. Mostly $(SDK_PATH)/components/toolchain/gcc

2. Chipset configuration
  a. CHIPSET
     Name of the chipset. nrf51822 or ntf52832. I have not yet tested other models.
  b. CHIPSET_FAMILY
     Name of chipset family. NRF51 or NRF52. This will automatically set ARM family option : Cortex-m0 / Cortex-m4f.
  c. CHIPSET_VARIANT
     Actually this parameter is now being used just for naming hex file.

3. Soft device
  a. ENABLE_SOFTDEVICE
     To set this 1 will includes headers and sources related soft device stack.
  b. ENABLE_BLE
     To set this 1 will includes headers and sources related soft device BLE stack.
  c. ENABLE_ANT
     To set this 1 will includes headers and sources related ANT stack.

4. Peripherals
  a. ENABLE_PERIPHERAL
     To set this 1 will includes common headers for using peripheral driver.  

  * Currently peripherals below are supported in this Makefile. These will be expanded when I need. ( Just fun! ) I will be
    so glad to anybody suggest cases.
  
  b. ENABLE_GPIO        // This is for GPIOTE
  c. ENABLE_TIMER
  d. ENABLE_PWM         // Not implemented yet but will be soon.
  e. ENABLE_TWI
  f. ENABLE_PSTORAGE
