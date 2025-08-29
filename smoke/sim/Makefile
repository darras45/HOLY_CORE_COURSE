TOPLEVEL_LANG = verilog
VERILOG_SOURCES = $(shell pwd)/../rtl/core_top.sv
TOPLEVEL = core_top
MODULE = test_core_smoke
SIM = verilator
EXTRA_ARGS += --trace
VERILATOR_COMPILE_ARGS += --sv
include $(shell cocotb-config --makefiles)/Makefile.sim
