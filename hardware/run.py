#!/usr/bin/env python3

from pathlib import Path
from vunit import VUnit

VU = VUnit.from_argv()
VU.add_vhdl_builtins()
VU.add_osvvm()
VU.add_verification_components()

SRC_PATH = Path(__file__).parent / "design"
TESTS_PATH = Path(__file__).parent / "tests"

VU.add_library("design_lib").add_source_files(SRC_PATH / "*.vhd")
VU.add_library("testbench_lib").add_source_files(TESTS_PATH / "*.vhd")

VU.main()
