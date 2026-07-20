ADA_SRC = src/vulnerable_parser.adb
C_SRC = harness.c
TARGET = fuzz_target

all: $(TARGET)

$(TARGET): $(ADA_SRC) $(C_SRC)
	@echo "Compiling Ada..."
	alr exec -- gnatmake -c $(ADA_SRC) -O2
	@echo "Compiling C with AFL++..."
	afl-gcc -c $(C_SRC) -o harness.o
	@echo "Linking..."
	alr exec -- gcc -no-pie -o $(TARGET) harness.o vulnerable_parser.o -lgnarl -lgnat -lm -lpthread -ldl

clean:
	rm -f *.o *.ali $(TARGET)

.PHONY: all clean
