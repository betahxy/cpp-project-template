# Author:betahxy
# This is a template makefile for a c project
# Usually you just to copy this one into a sub folder if you need to compile sub folders
# Please you need to add that sub folder name in $(SUB_DIR), you need to control your own folder hierarchy
MAKE=make

CC := gcc
CXX := g++
LD :=

PWD := $(shell pwd)
INCLUDE_DIR := -I$(PWD)/include/

CFLAGS := $(INCLUDE_DIR) -Wall -g

# Where all objects will be put, this directory is created automatically by makefile
BUILD_DIR:= $(PWD)/build/

# Your sub folder list, separated by space 
SUB_DIR := src
# Clean command of each sub folder
SUB_DIR_CLEAN := $(patsubst %, %_clean,$(SUB_DIR))
SRC_DIR := .

# Source files in a folder, not including files of sub folders
SRCS := $(wildcard *.cc)
OBJS := $(SRCS:%.cc=$(BUILD_DIR)%.o)
DEPS := $(SRCS:%.cc=%.d)

# Link target
TARGET := main
# Sub folders need to know some variables, those variables will override the same variables in sub folders
export  CXX INCLUDE_DIR CFLAGS BUILD_DIR

.PHONY: all clean clean_build clean_all print \
		subdirs_clean $(SUB_DIR) $(SUB_DIR_CLEAN)

sinclude $(DEPS)

$(TARGET):all
	$(info [LD] Linking target:$@)
	@set -e;\
	$(CXX) -o $(BUILD_DIR)$(TARGET) $(shell find $(BUILD_DIR) -name "*.o");

all: $(BUILD_DIR) $(BUILD_DIR) $(SUB_DIR) $(OBJS) 

# If a build folder doesn't exist, create one first
$(BUILD_DIR):
	$(info Build directory does not exist, creating...)
	@mkdir -p $(BUILD_DIR)

# Need to make each sub foloder
$(SUB_DIR):
	$(info [Make] Making folder [$@])
	@set -e;\
	$(MAKE) -e -C $@ all

# We need to add prefix $(BUILD_DIR) to specify the imp
$(BUILD_DIR)%.o:%.cc
	$(info [CXX] Compiling object: $@...)
	@$(CXX) $(INCLUDE_DIR) -MM -MP -MT $@ -MF $(patsubst %.cc,%.d,$<) $<
	@$(CXX) $(CFLAGS) $< -c -o $@

# When cleaning, first clean each sub folders
clean: $(SUB_DIR_CLEAN)
	@set -e;\
	rm -f *.d*;\
	rm -f *.o;\
	rm -rf $(BUILD_DIR)

$(SUB_DIR_CLEAN):
	$(info [CLEAN] Cleaning folder $(patsubst %_clean,%,$@)...)
	@$(MAKE) clean -e -C $(patsubst %_clean,%,$@)