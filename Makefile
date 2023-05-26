# SRC := $(wildcard src/*.c)
SRC := $(shell find src/ -type f -name '*.c')
OUT := out
BINARY := $(OUT)/tap_fw
MCU := attiny13a
F_CPU := 1000000UL
P_MCU := t13
A_MCU := avr2 # https://www.nongnu.org/avr-libc/user-manual/using_tools.html

C_FLAGS := -Os -DF_CPU=$(F_CPU) -mmcu=$(MCU) -flto

build: $(BINARY).hex

$(OUT):
	mkdir out

$(BINARY).hex: $(BINARY).elf
	avr-objcopy -O ihex -R .eeprom $(BINARY).elf $(BINARY).hex

$(BINARY).elf: $(OUT) Makefile $(SRC)
	avr-gcc $(C_FLAGS) -o $(BINARY).elf $(SRC)

flash: $(BINARY).hex
	avrdude -c usbasp-clone -p $(P_MCU) -U flash:w:$(BINARY).hex:i

clean:
	rm -rf $(OUT)

## dev ##

size: $(BINARY).elf
	avr-size -C --mcu=$(MCU) $(BINARY).elf

dump: $(BINARY).elf
	avr-objdump -S $(BINARY).elf > $(BINARY).dump

hex_dump: # $(BINARY).hex
	avr-objdump -D -m $(A_MCU) $(BINARY).hex > $(BINARY).hex.dump

read_flash: $(OUT)
	avrdude -c usbasp-clone -p $(P_MCU) -U flash:r:$(BINARY).hex:i

read_eeprom: $(OUT)
	avrdude -c usbasp-clone -p $(P_MCU) -U eeprom:r:$(BINARY).eeprom.hex:i

read_fuse:
	avrdude -c usbasp-clone -p $(P_MCU) -U lfuse:r:-:h -U lock:r:-:h 2>/dev/null
