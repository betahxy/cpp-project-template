CC := gcc
CXX := g++
LD := ld
PWD := $(shell pwd)
INCLUDE_DIR := -I$(PWD)/include/
CFLAGS := $(INCLUDE_DIR) -Wall -g
BUILD_DIR:= $(PWD)/build/

SUB_DIR := src
SUB_DIR_CLEAN := $(SUB_DIR:%=%_clean)
SRC_DIR := .
ALL_SRC := $(wildcard *.cc)
ALL_OBJ := $(ALL_SRC:%.cc=$(BUILD_DIR)%.o)
ALL_DEP := $(ALL_SRC:%.cc=%.d)
TARGET := main
export  CC CXX INCLUDE_DIR CFLAGS BUILD_DIR
.PHONY: all clean clean_build clean_all print subdirs \
		subdirs_clean $(SUB_DIR) $(SUB_DIR_CLEAN)

$(TARGET):all 
	@set -e;\
	echo "linking target...";\
	$(CXX) -o $(BUILD_DIR)$(TARGET) $(shell find $(BUILD_DIR) -name "*.o");\

all: subdirs $(ALL_DEP) $(ALL_OBJ)

subdirs: $(SUB_DIR)

$(SUB_DIR):
	@set -e;\
	echo "building folder [$@]";\
	make -e -C $@ all

print:
	@echo $(ALL_SRC)
	@echo $(ALL_OBJ)
	@echo $(ALL_DEP)
	@echo $(CC)
	@echo $(BUILD_DIR)
	@echo $(INCLUDE_DIR)
%.d:%.cc
	@set -e;\
	$(CXX) $(INCLUDE_DIR) -E -MM $< > $@.$$$$;\
	sed 's,\($*\)\.o[ :]*,$(BUILD_DIR)\1.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$

$(BUILD_DIR)%.o:%.cc
	@echo "Compiling $@... ";\
	$(CXX) $(CFLAGS) $< -c -o $@

-include $(ALL_DEP)

clean: subdirs_clean
	rm -f *.d*;\
	rm -f *.o;\

subdirs_clean:$(SUB_DIR_CLEAN)

$(SUB_DIR_CLEAN):
	@make clean -e -C $(@:%_clean=%)
clean_build:
	rm -f $(BUILD_DIR)*.o $(BUILD_DIR)$(TARGET)
clean_all:clean_build clean