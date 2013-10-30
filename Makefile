CXX = g++
CXXFLAGS ?= -g -O0 -Wall -W -ansi -D__TEST__ -Wcpp
LDFLAGS ?= 
SED = sed
MV = mv
RM = rm
CHIBI = ${HOME}/arm/ChibiOS_2.6.1
LWIP = ${CHIBI}/ext/lwip

ARM_GCC_PATH=~/arm/gcc-arm-none-eabi-4_7-2012q4
ARM_CC=${ARM_GCC_PATH}/bin/arm-none-eabi-gcc
ARM_CXX=${ARM_GCC_PATH}/bin/arm-none-eabi-g++
ARM_AR=${ARM_GCC_PATH}/bin/arm-none-eabi-ar
ARM_OBJCOPY=${ARM_GCC_PATH}/bin/arm-none-eabi-objcopy
ARM_CXX_FLAGS = -O2 -g -mthumb -mcpu=cortex-m3 -std=gnu99 -Wall -fno-builtin 

CHIBI_INCLUDE =  -Iarm -I${CHIBI}/os/kernel/include -I$(CHIBI)/os/ports/GCC/ARMCMx -I$(CHIBI)/os/ports/GCC/ARMCMx/STM32F1xx/ -I$(CHIBI)/os/ports/common/ARMCMx \
    -I$(CHIBI)/os/hal/include -I$(CHIBI)/os/hal/platforms/STM32F1xx -I$(CHIBI)/os/hal/platforms/STM32 -I$(CHIBI)/os/ports/common/ARMCMx/CMSIS/include \
    -I$(CHIBI)/os/hal/platforms/STM32/GPIOv1 -I$(CHIBI)/os/hal/platforms/STM32/USARTv1 -I$(CHIBI)/os/hal/platforms/STM32/TIMv1 -I$(CHIBI)/os/various \
    -I$(CHIBI)/os/various/lwip_bindings -I${LWIP}/src/include -I${LWIP}/src/include/ipv4 -I$(CHIBI)/os/hal/platforms/STM32/GPIOv1/
ARM_INCLUDE = ${CHIBI_INCLUDE}
ARM_LD_FLAGS = -mcpu=cortex-m3 -nostartfiles -mthumb -mno-thumb-interwork -T$(CHIBI)/os/ports/GCC/ARMCMx/STM32F1xx/ld/STM32F107xC.ld -Wl,--gc-sections,--accept-unknown-input-arch 

.SUFFIXES: .o .cpp

BUILD_DIR=build

VPATH=:arm/:${CHIBI}/

all: arm

clean:
	-@$(RM) -r $(BUILD_DIR)/* 2> /dev/null


# --------------------------------------------------
# ARM ChibiOS lib
# --------------------------------------------------

lwip_src = ext/lwip/src/netif/etharp.c ext/lwip/src/core/dhcp.c ext/lwip/src/core/dns.c ext/lwip/src/core/init.c \
        ext/lwip/src/core/mem.c ext/lwip/src/core/memp.c ext/lwip/src/core/netif.c  ext/lwip/src/core/pbuf.c ext/lwip/src/core/raw.c \
        ext/lwip/src/core/stats.c ext/lwip/src/core/sys.c ext/lwip/src/core/tcp.c ext/lwip/src/core/tcp_in.c ext/lwip/src/core/tcp_out.c ext/lwip/src/core/udp.c \
        ext/lwip/src/core/ipv4/autoip.c ext/lwip/src/core/ipv4/icmp.c ext/lwip/src/core/ipv4/igmp.c ext/lwip/src/core/ipv4/inet.c ext/lwip/src/core/ipv4/inet_chksum.c \
        ext/lwip/src/core/ipv4/ip.c ext/lwip/src/core/ipv4/ip_addr.c ext/lwip/src/core/ipv4/ip_frag.c ext/lwip/src/core/def.c ext/lwip/src/core/timers.c \
        ext/lwip/src/api/api_lib.c ext/lwip/src/api/api_msg.c ext/lwip/src/api/err.c ext/lwip/src/api/netbuf.c ext/lwip/src/api/netdb.c ext/lwip/src/api/netifapi.c \
        ext/lwip/src/api/sockets.c ext/lwip/src/api/tcpip.c

chibi_src = os/kernel/src/chcond.c os/kernel/src/chdebug.c os/kernel/src/chdynamic.c os/kernel/src/chevents.c os/kernel/src/chheap.c \
    os/kernel/src/chlists.c os/kernel/src/chmboxes.c os/kernel/src/chmemcore.c os/kernel/src/chmempools.c os/kernel/src/chmsg.c os/kernel/src/chmtx.c \
    os/kernel/src/chqueues.c os/kernel/src/chregistry.c os/kernel/src/chschd.c os/kernel/src/chsem.c os/kernel/src/chsys.c os/kernel/src/chthreads.c \
    os/kernel/src/chvt.c  \
    os/hal/src/adc.c os/hal/src/ext.c os/hal/src/gpt.c os/hal/src/hal.c os/hal/src/i2c.c os/hal/src/pal.c os/hal/src/pwm.c os/hal/src/sdc.c os/hal/src/serial.c \
    os/hal/src/spi.c os/hal/src/tm.c os/hal/src/uart.c os/hal/src/mac.c \
    os/hal/platforms/STM32/ext_lld.c os/hal/platforms/STM32/TIMv1/gpt_lld.c os/hal/platforms/STM32/I2Cv1/i2c_lld.c os/hal/platforms/STM32/TIMv1/pwm_lld.c \
    os/hal/platforms/STM32/USARTv1/serial_lld.c os/hal/platforms/STM32/SPIv1/spi_lld.c os/hal/platforms/STM32/USARTv1/uart_lld.c \
    os/hal/platforms/STM32/GPIOv1/pal_lld.c \
    os/hal/platforms/STM32F1xx/adc_lld.c os/hal/platforms/STM32F1xx/hal_lld.c os/hal/platforms/STM32F1xx/stm32_dma.c \
    os/ports/GCC/ARMCMx/crt0.c os/ports/GCC/ARMCMx/chcore.c os/ports/GCC/ARMCMx/chcore_v7m.c os/ports/common/ARMCMx/nvic.c \
    os/various/chprintf.c os/various/evtimer.c \
    os/various/lwip_bindings/lwipthread.c os/various/lwip_bindings/arch/sys_arch.c \
    ${lwip_src}
chibi_objects = $(addprefix $(BUILD_DIR)/arm/chibi/, $(chibi_src:.c=.o))

arm-chibi: $(BUILD_DIR)/arm/chibi/libchibi.a

$(BUILD_DIR)/arm/chibi/libchibi.a: ${chibi_objects}
	@echo Creating ChibiOS library
	@${ARM_AR} cr ${BUILD_DIR}/arm/chibi/libchibi.a ${chibi_objects} 

$(BUILD_DIR)/arm/chibi/%.o : %.c
	@echo $<
	@mkdir -p $(BUILD_DIR)/arm/chibi/os/kernel/src $(BUILD_DIR)/arm/chibi/os/hal/src $(BUILD_DIR)/arm/chibi/os/hal/platforms/STM32/SPIv1 \
	$(BUILD_DIR)/arm/chibi/os/hal/platforms/STM32/USARTv1 $(BUILD_DIR)/arm/chibi/os/hal/platforms/STM32/GPIOv1 \
	$(BUILD_DIR)/arm/chibi/os/hal/platforms/STM32/TIMv1 $(BUILD_DIR)/arm/chibi/os/hal/platforms/STM32/I2Cv1 \
	$(BUILD_DIR)/arm/chibi/os/hal/platforms/STM32F1xx ${BUILD_DIR}/arm/chibi/os/ports/GCC/ARMCMx ${BUILD_DIR}/arm/chibi/os/ports/common/ARMCMx \
	${BUILD_DIR}/arm/chibi/os/various/lwip_bindings/arch \
	${BUILD_DIR}/arm/chibi/ext/lwip/src/netif ${BUILD_DIR}/arm/chibi/ext/lwip/src/core ${BUILD_DIR}/arm/chibi/ext/lwip/src/core/ipv4 \
	${BUILD_DIR}/arm/chibi/ext/lwip/src/api
	@$(ARM_CC) $(ARM_CXX_FLAGS) $(ARM_INCLUDE) -c $< -o $@


# --------------------------------------------------
# ARM test
# --------------------------------------------------
ARM_SRC = arm/arm_main.c arm/web.c arm/vectors.c arm/syscalls.c arm/board.c arm/dhcp.c arm/board.c arm/ds18b20.c arm/mac_lld.c
ARM_OBJECTS = $(subst .c,.o, $(addprefix $(BUILD_DIR)/arm/, $(notdir $(ARM_SRC:.cpp=.o)))) 

arm: $(BUILD_DIR)/arm/http.bin

$(BUILD_DIR)/arm/http.bin: $(BUILD_DIR)/arm/http.elf
	@echo $<
	@$(ARM_OBJCOPY) -O binary $^ $@

$(BUILD_DIR)/arm/http.elf: $(ARM_OBJECTS) $(BUILD_DIR)/arm/chibi/libchibi.a
	@echo $<
	@$(ARM_CC) $(ARM_LD_FLAGS)  $^ -o $@ -L$(BUILD_DIR)/arm/chibi -lchibi -lstdc++ -lm


$(BUILD_DIR)/arm/%.o : %.c
	@echo $<
	@mkdir -p $(BUILD_DIR)/arm
	@$(ARM_CC) $(ARM_CXX_FLAGS) $(ARM_INCLUDE) -c $< -o $@

$(BUILD_DIR)/arm/%.o : %.cpp
	@echo $<
	@mkdir -p $(BUILD_DIR)/arm
	@$(ARM_CXX) $(ARM_CXX_FLAGS) $(ARM_INCLUDE) -c $< -o $@


ifneq "$(MAKECMDGOALS)" "clean"
-include $(dependencies)
-include $(test_dependencies)
endif
