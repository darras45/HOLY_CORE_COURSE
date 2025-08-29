TOPLEVEL_LANG = verilog

VERILOG_SOURCES = $(shell pwd)/../rtl/pc.sv \
                  $(shell pwd)/../rtl/instr_mem.sv \
                  $(shell pwd)/../rtl/control.sv \
                  $(shell pwd)/../rtl/imm_gen.sv \
                  $(shell pwd)/../rtl/regfile.sv \
                  $(shell pwd)/../rtl/alu.sv \
                  $(shell pwd)/../rtl/data_mem.sv \
                  $(shell pwd)/../rtl/core_top.sv

TOPLEVEL = core_top
MODULE = test_mem_ops
SIM = verilator

VERILATOR_COMPILE_ARGS += --sv
EXTRA_ARGS += --trace

export PYTHONPATH := $(shell pwd)/../tests:$(PYTHONPATH)

include $(shell cocotb-config --makefiles)/Makefile.sim
