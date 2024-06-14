# ==============================================================================
# Authors:              Doğu Erkan Arkadaş
#
# Cocotb Testbench:     For Single Cycle RISC-V Laboratory
#
# Description:
# ------------------------------------
# Test bench for the single cycle laboratory, used by the students to check their designs
#
# License:
# ==============================================================================

import logging
import cocotb
from Helper_lib import read_file_to_list, Instruction, rotate_right, shift_helper, ByteAddressableMemory, reverse_hex_string_endiannes
from Helper_Student import Log_Datapath, Log_Controller
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, Edge, Timer
from cocotb.binary import BinaryValue

class TB:
    def __init__(self, Instruction_list, dut, dut_PC, dut_regfile):
        self.dut = dut
        self.dut_PC = dut_PC
        self.dut_regfile = dut_regfile
        self.Instruction_list = Instruction_list
        # Configure the logger
        self.logger = logging.getLogger("Performance Model")
        self.logger.setLevel(logging.DEBUG)
        # Initial values are all 0 as in a FPGA
        self.PC = 0
        self.Z_flag = 0
        self.Register_File = []
        for i in range(32):
            self.Register_File.append(0)
        # Memory is a special class helper lib to simulate HDL counterpart
        self.memory = ByteAddressableMemory(1024)

        self.clock_cycle_count = 0

    # Calls user populated log functions    
    def log_dut(self):
        Log_Datapath(self.dut, self.logger)
        Log_Controller(self.dut, self.logger)

    # Compares and logs the PC and register file of Python module and HDL design
    def compare_result(self):
        self.logger.debug("************* Performance Model / DUT Data  **************")
        self.logger.debug("PC:%08x \t PC:%08x", self.PC, self.dut_PC.value.integer)
        assert self.PC == self.dut_PC.value
        for i in range(32):
            data = self.dut_regfile.Reg_Out[i].value.integer 
            if self.Register_File[i] < 0:
                data= pow(2,32) - self.dut_regfile.Reg_Out[i].value.integer 
                data =  (-1) * data
            self.logger.debug("Register%d: %08x \t %08x", i, (self.Register_File[i] & 0xFFFFFFFF), (data & 0xFFFFFFFF))

            assert self.Register_File[i] == data

    # A model of the verilog code to confirm operation, data is In_data
    def performance_model(self):
        self.logger.debug("**************** Clock cycle: %d **********************", self.clock_cycle_count)
        self.clock_cycle_count += 1
        # Read current instructions, extract and log the fields
        self.logger.debug("**************** Instruction No: %d **********************", int(self.PC / 4))
        current_instruction = self.Instruction_list[int(self.PC / 4)]
        current_instruction = current_instruction.replace(" ", "")
        # We need to reverse the order of bytes since little endian makes the string reversed in Python
        current_instruction = reverse_hex_string_endiannes(current_instruction)
        self.PC += 4
        # Call Instruction calls to get each field from the instruction
        inst_fields = Instruction(current_instruction)
        inst_fields.log(self.logger)

        # Instruction execution logic for RISC-V
        opcode = inst_fields.opcode
        funct3 = inst_fields.funct3
        funct7= inst_fields.funct7
        instr_type = inst_fields.instr_type
        rs1_val = self.Register_File[inst_fields.rs1]
        rs2_val = self.Register_File[inst_fields.rs2]
        if (rs1_val & (1 << 31)) != 0:
            rs1_unsigned = pow(2,32) - rs1_val
        else:
            rs1_unsigned = rs1_val
        if (rs2_val & (1 << 31)) != 0:
            rs2_unsigned = pow(2,32) - rs2_val
        else:
            rs2_unsigned = rs2_val
        imm = inst_fields.imm
        if instr_type == 'R':    
            if funct7 == 0b0000000 and funct3 == 0b000: #ADD
                self.Register_File[inst_fields.rd] = rs1_val + rs2_val
            elif funct7 == 0b0100000 and funct3 == 0b000: #SUB
                self.Register_File[inst_fields.rd] = rs1_val - rs2_val
            elif funct7 == 0b0000000 and funct3 == 0b111: #AND
                self.Register_File[inst_fields.rd] = rs1_val & rs2_val
            elif funct7 == 0b0000000 and funct3 == 0b110: #OR
                self.Register_File[inst_fields.rd] = rs1_val | rs2_val
            elif funct7 == 0b0000000 and funct3 == 0b100: #XOR
                self.Register_File[inst_fields.rd] = rs1_val ^ rs2_val
            elif funct7 == 0b0000000 and funct3 == 0b001: #SLL
                self.Register_File[inst_fields.rd] = rs1_val << (rs2_val & 0x1F) 
            elif funct7 == 0b0000000 and funct3 == 0b101: #SRL
                self.Register_File[inst_fields.rd] = (rs1_val & 0xFFFFFFFF) >> (rs2_val & 0x1F) 
            elif funct7 == 0b0100000 and funct3 == 0b101: #SRA
                self.Register_File[inst_fields.rd] = (rs1_val >> (rs2_val & 0x1F)) | (rs1_val & 0x80000000)
            elif funct7 == 0b0000000 and funct3 == 0b010: #SLT
                self.Register_File[inst_fields.rd] = int(rs1_val < rs2_val) 
            elif funct7 == 0b0000000 and funct3 == 0b011: #SLTU
                self.Register_File[inst_fields.rd] = int(rs1_unsigned < rs2_unsigned) 
        
        elif instr_type == 'I':
            if opcode == 0b0010011:
                if funct3 == 0b000: #ADDI
                    self.Register_File[inst_fields.rd] = rs1_val + imm
                elif funct3 == 0b111: #ANDI
                    self.Register_File[inst_fields.rd] = rs1_val & imm
                elif funct3 == 0b110: #ORI
                    self.Register_File[inst_fields.rd] = rs1_val | imm
                elif funct3 == 0b100: #XORI
                    self.Register_File[inst_fields.rd] = rs1_val ^ imm
                elif funct7 == 0b0000000 and funct3 == 0b001: #SLLI
                    self.Register_File[inst_fields.rd] = rs1_val << (imm & 0x1F) 
                elif funct7 == 0b0000000 and funct3 == 0b101: #SRLI
                    self.Register_File[inst_fields.rd] = rs1_val >> (imm & 0x1F) 
                elif funct7 == 0b0100000 and funct3 == 0b101: #SRAI
                    self.Register_File[inst_fields.rd] = (rs1_val >> (imm & 0x1F)) | (rs1_val & 0x80000000)
                elif funct3 == 0b010: #SLTI
                    self.Register_File[inst_fields.rd] = int(rs1_val < imm) 
                elif funct3 == 0b011: #SLTIU
                    self.Register_File[inst_fields.rd] = int(rs1_unsigned < imm) 
            elif opcode == 0b1100111 and funct3 == 0b000: # JALR
                    self.Register_File[inst_fields.rd] = self.PC
                    self.PC = (rs1_val + imm) & ~1
            elif opcode == 0b0000011:
                if funct3 == 0b000: #LB
                    data = int.from_bytes(self.memory.read(rs1_val + inst_fields.imm)) & 0xFF
                    if (data & 0x80) == 0x80:
                        data = data | 0xFFFFFF00
                    self.Register_File[inst_fields.rd]= data
                elif funct3 == 0b000: #LBU
                    data = int.from_bytes(self.memory.read(rs1_val + inst_fields.imm)) & 0xFF
                    self.Register_File[inst_fields.rd]= data
                elif funct3 == 0b001: #LH
                    data = int.from_bytes(self.memory.read(rs1_val+ inst_fields.imm)) & 0xFFFF
                    if (data & 0x8000) == 0x8000:
                        data = data | 0xFFFF0000
                    self.Register_File[inst_fields.rd]= data
                elif funct3 == 0b101: #LHU
                    data = int.from_bytes(self.memory.read(rs1_val + inst_fields.imm)) & 0xFFFF
                    self.Register_File[inst_fields.rd]= data
                elif funct3 == 0b010: #LW
                    data = int.from_bytes(self.memory.read(rs1_val + inst_fields.imm))
                    self.Register_File[inst_fields.rd]= data
            elif opcode == 0b0001011: #XORID
                self.Register_File[inst_fields.rd] = rs1_val ^ (2375178 ^ 2376242) 
        
        elif instr_type == 'J':
            if opcode == 0b1101111:
                self.Register_File[inst_fields.rd] = self.PC
                self.PC -= 4
                self.PC = self.PC + imm
        
        elif instr_type == 'B':
            if funct3 == 0b000: #BEQ
                if rs1_val == rs2_val:
                    self.PC -= 4
                    self.PC += inst_fields.imm 
            elif funct3 == 0b001: #BNE
                if rs1_val != rs2_val:
                    self.PC -= 4
                    self.PC += inst_fields.imm 
            elif funct3 == 0b100: #BLT
                if rs1_val < rs2_val:
                    self.PC -= 4
                    self.PC += inst_fields.imm 
            elif funct3 == 0b101: #BGE
                if rs1_val > rs2_val:
                    self.PC -= 4
                    self.PC += inst_fields.imm 
            elif funct3 == 0b110: #BLTU
                if rs1_unsigned < rs2_unsigned:
                    self.PC -= 4
                    self.PC += inst_fields.imm 
            elif funct3 == 0b111: #BGEU
                if rs1_unsigned > rs2_unsigned:
                    self.PC -= 4
                    self.PC += inst_fields.imm 

        elif instr_type == 'S':
            if funct3 == 0b000: #SB
                address = rs1_val+ inst_fields.imm
                self.memory.write(address, rs2_val)
            elif funct3 == 0b001: #SH
                address = rs1_val+ inst_fields.imm
                self.memory.write(address, rs2_val)
            elif funct3 == 0b010: #SW
                address = rs1_val+ inst_fields.imm
                self.memory.write(address, rs2_val)
            
        elif instr_type == 'U':
            if opcode == 0b0010111: #AUIPC
                self.Register_File[inst_fields.rd] = self.PC - 4 + imm
            elif opcode == 0b0110111: #LUI
                self.Register_File[inst_fields.rd] = imm

    async def run_test(self):
        self.performance_model()
        # Wait 1 us the very first time bc. initially all signals are "X"
        await Timer(1, units="us")
        self.log_dut()
        await RisingEdge(self.dut.clk)
        await FallingEdge(self.dut.clk)
        self.compare_result()
        while int(self.Instruction_list[int(self.PC / 4)].replace(" ", ""), 16) != 0:
            self.performance_model()
            # Log datapath and controller before clock edge, this calls user filled functions
            self.log_dut()
            await RisingEdge(self.dut.clk)
            await FallingEdge(self.dut.clk)
            self.compare_result()
            input()

@cocotb.test()
async def Single_cycle_test(dut):
    # Generate the clock
    await cocotb.start(Clock(dut.clk, 10, 'us').start(start_high=False))
    # Reset once before continuing with the tests
    dut.reset.value = 1
    await RisingEdge(dut.clk)
    dut.reset.value = 0
    await FallingEdge(dut.clk)
    instruction_lines = read_file_to_list('Instructions.hex')
    # Give PC signal handle and Register File MODULE handle
    tb = TB(instruction_lines, dut, dut.PC, dut.my_datapath.reg_file)
    await tb.run_test()