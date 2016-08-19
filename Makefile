SHELL=/bin/bash
PATH := /usr/local/bin:$(PATH)
PROJECT_NAME := ant_broadcast_s212

### <!-- Please modify these definitions
ROOT_PATH		= ../..
SDK_PATH 		= /Users/sonientaegi/Library/nRF5_SDK_11
DRIVER_PATH 	= $(SDK_PATH)/components/drivers_nrf
LIB_PATH 		= $(SDK_PATH)/components/libraries
TEMPLATE_PATH 	= $(SDK_PATH)/components/toolchain/gcc

# Config Chipset
CHIPSET				= nrf52832
CHIPSET_FAMILY		= NRF52
CHIPSET_VARIANT		= xxaa

# Enable softdevice
ENABLE_SOFTDEVICE	= 1
ENABLE_BLE			= 0
ENABLE_ANT			= 1
SOFTDEVICE_VERSION	= 212

# Enable peripherals
ENABLE_PERIPHERAL	= 1
ENABLE_GPIO			= 1
ENABLE_TIMER		= 1
ENABLE_PWM			= 0
ENABLE_TWI			= 0
ENABLE_PSTORAGE		= 0
###      Please modify these definitions -->

export OUTPUT_FILENAME
MAKEFILE_NAME := $(MAKEFILE_LIST)
MAKEFILE_DIR := $(dir $(MAKEFILE_NAME) ) 
CHIPSET_FAMILY_LOWER := $(shell echo $(CHIPSET_FAMILY) | tr [A-Z] [a-z])

ifeq ($(OS),Windows_NT)
include $(TEMPLATE_PATH)/Makefile.windows
else
include $(TEMPLATE_PATH)/Makefile.posix
endif

MK := mkdir
RM := rm -rf

#echo suspend
ifeq ("$(VERBOSE)","1")
NO_ECHO := 
else
NO_ECHO := @
endif

# Toolchain commands
CC              := '$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-gcc'
AS              := '$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-as'
AR              := '$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-ar' -r
LD              := '$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-ld'
NM              := '$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-nm'
OBJDUMP         := '$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-objdump'
OBJCOPY         := '$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-objcopy'
SIZE            := '$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-size'

#function for removing duplicates in a list
remduplicates = $(strip $(if $1,$(firstword $1) $(call remduplicates,$(filter-out $(firstword $1),$1))))

# Common
C_SOURCE_FILES += \
	$(abspath $(SDK_PATH)/components/toolchain/system_$(CHIPSET_FAMILY_LOWER).c) \
	$(abspath $(DRIVER_PATH)/delay/nrf_delay.c) \
	$(abspath $(ROOT_PATH)/softdevice.c) \
	$(abspath $(ROOT_PATH)/peripheral.c) \
	$(abspath $(ROOT_PATH)/main.c)

INC_PATHS += \
	-I$(abspath $(ROOT_PATH)) \
	-I$(abspath $(ROOT_PATH)/config) \
	-I$(abspath $(ROOT_PATH)/config/s$(SOFTDEVICE_VERSION)) \
	-I$(abspath $(SDK_PATH)/components/toolchain) \
	-I$(abspath $(SDK_PATH)/components/toolchain/gcc) \
	-I$(abspath $(SDK_PATH)/components/device) \
	-I$(abspath $(SDK_PATH)/components/toolchain/CMSIS/Include) \
	-I$(abspath $(SDK_PATH)/components/softdevice/s$(SOFTDEVICE_VERSION)/headers) \
	-I$(abspath $(DRIVER_PATH)/delay) \
	-I$(abspath $(LIB_PATH)/util) 

# Segger RTT debugger
ifeq ($(DEBUG), 1) 
	CFLAGS += -D_DEBUG
	
	C_SOURCE_FILES += \
		$(abspath $(SDK_PATH)/external/segger_rtt/SEGGER_RTT.c) \
		$(abspath $(SDK_PATH)/external/segger_rtt/SEGGER_RTT_printf.c) \
		$(abspath $(SDK_PATH)/components/libraries/util/nrf_log.c)
	
	INC_PATHS += \
		-I$(abspath $(SDK_PATH)/external/segger_rtt) \
		-I$(abspath $(LIB_PATH)/util)
else 
	CFLAGS += -D_NDEBUG
endif

# Soft device
ifeq ($(ENABLE_SOFTDEVICE), 1)
	C_SOURCE_FILES += \
		$(abspath $(LIB_PATH)/util/app_error.c) \
		$(abspath $(SDK_PATH)/components/softdevice/common/softdevice_handler/softdevice_handler.c)
	
	INC_PATHS += \
		-I$(abspath $(SDK_PATH)/components/softdevice/s$(SOFTDEVICE_VERSION)/headers) \
		-I$(abspath $(SDK_PATH)/components/softdevice/common/softdevice_handler) 
endif

ifeq ($(ENABLE_BLE), 1)
	CFLAGS += -DENABLE_BLE
	C_SOURCE_FILES += \
		$(abspath $(SDK_PATH)/components/ble/common/ble_advdata.c) \
		$(abspath $(SDK_PATH)/components/ble/ble_radio_notification/ble_radio_notification.c) \
	
	INC_PATHS += \
		-I$(abspath $(SDK_PATH)/components/ble/common) \
		-I$(abspath $(SDK_PATH)/components/ble/ble_radio_notification)
endif

ifeq ($(ENABLE_ANT), 1)
	CFLAGS += -DENABLE_ANT
	C_SOURCE_FILES += \
 		$(abspath $(SDK_PATH)/components/ant/ant_channel_config/ant_channel_config.c) \
		$(abspath $(SDK_PATH)/components/ant/ant_stack_config/ant_stack_config.c)

	INC_PATHS += \
		-I$(abspath $(SDK_PATH)/components/ant/ant_stack_config) \
		-I$(abspath $(SDK_PATH)/components/ant/ant_channel_config)
endif

# Peripheral - Common
ifeq ($(ENABLE_PERIPHERAL), 1)
	C_SOURCE_FILES += \
		$(abspath $(DRIVER_PATH)/common/nrf_drv_common.c)
 
	INC_PATHS += \
		-I$(abspath $(DRIVER_PATH)/common) \
		-I$(abspath $(DRIVER_PATH)/hal) \
		-I$(abspath $(DRIVER_PATH)/config) 
endif

# Peripheral - GPIO
ifeq ($(ENABLE_GPIO), 1)
	C_SOURCE_FILES += \
		$(abspath $(DRIVER_PATH)/gpiote/nrf_drv_gpiote.c)
		
	INC_PATHS += \
		-I$(abspath $(DRIVER_PATH)/gpiote)
endif

# Peripheral - TIMER
ifeq ($(ENABLE_TIMER), 1)
	C_SOURCE_FILES += \
		$(abspath $(DRIVER_PATH)/timer/nrf_drv_timer.c)
		
	INC_PATHS += \
		-I$(abspath $(DRIVER_PATH)/timer)
endif

# Peripheral - pstorage
ifeq ($(ENABLE_PSTORAGE), 1)
	CFLAGS += -DENABLE_PSTORAGE

	C_SOURCE_FILES += \
		$(abspath $(DRIVER_PATH)/pstorage/pstorage.c) \
		sync_pstorage.c
		
		
	INC_PATHS += \
		-I$(abspath $(DRIVER_PATH)/pstorage) \
		-I$(abspath $(DRIVER_PATH)/pstorage/config)
endif

#assembly files common to all targets
ASM_SOURCE_FILES  = $(abspath $(SDK_PATH)/components/toolchain/gcc/gcc_startup_$(CHIPSET_FAMILY_LOWER).s)

OBJECT_DIRECTORY = _build
LISTING_DIRECTORY = $(OBJECT_DIRECTORY)
OUTPUT_BINARY_DIRECTORY = $(OBJECT_DIRECTORY)

# Sorting removes duplicates
BUILD_DIRECTORIES := $(sort $(OBJECT_DIRECTORY) $(OUTPUT_BINARY_DIRECTORY) $(LISTING_DIRECTORY) )

#flags common to all targets
CFLAGS += -DSOFTDEVICE_PRESENT
CFLAGS += -D$(CHIPSET_FAMILY)
CFLAGS += -DS$(SOFTDEVICE_VERSION)
ifeq ($(ENABLE_BLE), 1)
	CFLAGS += -DBLE_STACK_SUPPORT_REQD
endif
ifeq ($(ENABLE_ANT), 1)
	CFLAGS += -DANT_STACK_SUPPORT_REQD
endif
CFLAGS += -DBSP_DEFINES_ONLY
CFLAGS += -DNRF_LOG_USES_RTT=1
CFLAGS += -mthumb -mabi=aapcs --std=gnu99
CFLAGS += -Werror -O3 -g3
ifeq ("$(CHIPSET_FAMILY)", "NRF51")
	CFLAGS += -mcpu=cortex-m0
	CFLAGS += -mfloat-abi=soft
else
	CFLAGS += -mcpu=cortex-m4
	CFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
endif
# keep every function in separate section. This will allow linker to dump unused functions
CFLAGS += -ffunction-sections -fdata-sections -fno-strict-aliasing
CFLAGS += -fno-builtin --short-enums 
# keep every function in separate section. This will allow linker to dump unused functions
LDFLAGS += -Xlinker -Map=$(LISTING_DIRECTORY)/$(OUTPUT_FILENAME).map
LDFLAGS += -mthumb -mabi=aapcs -L $(TEMPLATE_PATH) -T$(LINKER_SCRIPT)
ifeq ("$(CHIPSET_FAMILY)", "NRF51")
	LDFLAGS += -mcpu=cortex-m0
else
	LDFLAGS += -mcpu=cortex-m4
	LDFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
endif
# let linker to dump unused sections
LDFLAGS += -Wl,--gc-sections
# use newlib in nano version
LDFLAGS += --specs=nano.specs -lc -lnosys

# Assembler flags
ASMFLAGS += -x assembler-with-cpp
ASMFLAGS += -DSOFTDEVICE_PRESENT
ASMFLAGS += -D$(CHIPSET_FAMILY)
ASMFLAGS += -DS$(SOFTDEVICE_VERSION)
ifeq ($(ENABLE_BLE), 1)
	ASMFLAGS += -DBLE_STACK_SUPPORT_REQD
endif
ifeq ($(ENABLE_ANT), 1)
	ASMFLAGS += -DANT_STACK_SUPPORT_REQD
endif
ASMFLAGS += -DBSP_DEFINES_ONLY

#default target - first one defined
default: flash $(CHIPSET)_$(CHIPSET_VARIANT)_s$(SOFTDEVICE_VERSION)

#building all targets
all: clean
	$(NO_ECHO)$(MAKE) -f $(MAKEFILE_NAME) -C $(MAKEFILE_DIR) -e cleanobj
	$(NO_ECHO)$(MAKE) -f $(MAKEFILE_NAME) -C $(MAKEFILE_DIR) -e $(CHIPSET)_$(CHIPSET_VARIANT)_s$(SOFTDEVICE_VERSION)

#target for printing all targets
help:
	@echo following targets are available:
	@echo 	$(CHIPSET)_$(CHIPSET_VARIANT)_s$(SOFTDEVICE_VERSION)
	@echo 	flash_softdevice

C_SOURCE_FILE_NAMES = $(notdir $(C_SOURCE_FILES))
C_PATHS = $(call remduplicates, $(dir $(C_SOURCE_FILES) ) )
C_OBJECTS = $(addprefix $(OBJECT_DIRECTORY)/, $(C_SOURCE_FILE_NAMES:.c=.o) )

ASM_SOURCE_FILE_NAMES = $(notdir $(ASM_SOURCE_FILES))
ASM_PATHS = $(call remduplicates, $(dir $(ASM_SOURCE_FILES) ))
ASM_OBJECTS = $(addprefix $(OBJECT_DIRECTORY)/, $(ASM_SOURCE_FILE_NAMES:.s=.o) )

vpath %.c $(C_PATHS)
vpath %.s $(ASM_PATHS)

OBJECTS = $(C_OBJECTS) $(ASM_OBJECTS)

$(CHIPSET)_$(CHIPSET_VARIANT)_s$(SOFTDEVICE_VERSION): OUTPUT_FILENAME := $(CHIPSET)_$(CHIPSET_VARIANT)_s$(SOFTDEVICE_VERSION)
$(CHIPSET)_$(CHIPSET_VARIANT)_s$(SOFTDEVICE_VERSION): LINKER_SCRIPT=$(CHIPSET_FAMILY_LOWER).ld

$(CHIPSET)_$(CHIPSET_VARIANT)_s$(SOFTDEVICE_VERSION): $(BUILD_DIRECTORIES) $(OBJECTS)
	@echo Linking target: $(OUTPUT_FILENAME).out
	$(NO_ECHO)$(CC) $(LDFLAGS) $(OBJECTS) $(LIBS) -lm -o $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).out
	$(NO_ECHO)$(MAKE) -f $(MAKEFILE_NAME) -C $(MAKEFILE_DIR) -e finalize

## Create build directories
$(BUILD_DIRECTORIES):
	echo $(MAKEFILE_NAME)
	$(MK) $@

# Create objects from C SRC files
$(OBJECT_DIRECTORY)/%.o: %.c
	@echo Compiling file: $(notdir $<)
	$(NO_ECHO)$(CC) $(CFLAGS) $(INC_PATHS) -c -o $@ $<

# Assemble files
$(OBJECT_DIRECTORY)/%.o: %.s
	@echo Assembly file: $(notdir $<)
	$(NO_ECHO)$(CC) $(ASMFLAGS) $(INC_PATHS) -c -o $@ $<
# Link
$(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).out: $(BUILD_DIRECTORIES) $(OBJECTS)
	@echo Linking target: $(OUTPUT_FILENAME).out
	$(NO_ECHO)$(CC) $(LDFLAGS) $(OBJECTS) $(LIBS) -lm -o $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).out
## Create binary .bin file from the .out file
$(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).bin: $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).out
	@echo Preparing: $(OUTPUT_FILENAME).bin
	$(NO_ECHO)$(OBJCOPY) -O binary $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).out $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).bin

## Create binary .hex file from the .out file
$(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).hex: $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).out
	@echo Preparing: $(OUTPUT_FILENAME).hex
	$(NO_ECHO)$(OBJCOPY) -O ihex $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).out $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).hex

finalize: genbin genhex echosize

genbin:
	@echo Preparing: $(OUTPUT_FILENAME).bin
	$(NO_ECHO)$(OBJCOPY) -O binary $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).out $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).bin

## Create binary .hex file from the .out file
genhex: 
	@echo Preparing: $(OUTPUT_FILENAME).hex
	$(NO_ECHO)$(OBJCOPY) -O ihex $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).out $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).hex
echosize:
	-@echo ''
	$(NO_ECHO)$(SIZE) $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).out
	-@echo ''

clean:
	$(RM) $(BUILD_DIRECTORIES)

cleanobj:
	$(RM) $(BUILD_DIRECTORIES)/*.o
flash: $(CHIPSET)_$(CHIPSET_VARIANT)_s$(SOFTDEVICE_VERSION)
	@echo Flashing: $(OUTPUT_BINARY_DIRECTORY)/$<.hex
	nrfjprog --program $(OUTPUT_BINARY_DIRECTORY)/$<.hex -f $(CHIPSET_FAMILY_LOWER)  --sectorerase
	nrfjprog --reset -f $(CHIPSET_FAMILY_LOWER)

## Flash softdevice
flash_softdevice:
	@echo Flashing: s$(SOFTDEVICE_VERSION)_$(CHIPSET_FAMILY_LOWER)_2.0.0_softdevice.hex
	nrfjprog --program $(SDK_PATH)/components/softdevice/s$(SOFTDEVICE_VERSION)/hex/s$(SOFTDEVICE_VERSION)_$(CHIPSET_FAMILY_LOWER)_2.0.0_softdevice.hex -f $(CHIPSET_FAMILY_LOWER) --chiperase
	nrfjprog --reset -f $(CHIPSET_FAMILY_LOWER)