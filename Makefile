CC	= arm-linux-gnueabihf-gcc
CFLAGS	= -Wall -mcpu=cortex-a8 -mfloat-abi=hard -mfpu=neon -marm
LDFLAGS = -lrt -static

asm_objects = pi_calc_asm.o pi_func.o
default: pi_calc_c


pi_calc_c:pi_calc.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $< -D Version_c
	

pi_calc_asm:$(asm_objects)
	$(CC) $(LDFLAGS) -o $@ $^

pi_calc_asm.o:pi_calc.c
	$(CC) -c $(CFLAGS) -o $@ $< -D Version_asm

pi_func.o:pi_func.s
	$(CC) -c $(CFLAGS) -o $@ $<

.PHONY: 
clean:
	rm -f pi_calc_c pi_calc_asm pi_func.o pi_calc_asm.o

