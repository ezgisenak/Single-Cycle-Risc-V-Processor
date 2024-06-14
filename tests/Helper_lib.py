def read_file_to_list(filename):
    """
    Reads a text file and returns a list where each element is a line in the file.

    :param filename: The name of the file to read.
    :return: A list of strings, where each string is a line from the file.
    """
    with open(filename, 'r') as file:
        lines = file.readlines()
        # Stripping newline characters from each line
        lines = [line.strip() for line in lines]
    return lines

class Instruction:
    """
    Parses a 32-bit RISC-V instruction in hexadecimal format.

    :param instruction: A string representing the 32-bit instruction in hex format.
    :return: This class with the fields.
    """
    def __init__(self, instruction):
        # Convert the reversed hex instruction to a 32-bit binary string
        self.binary_instr = format(int(instruction, 16), '032b')
        self.instr_type = ''
        self.imm = 0

        # Extract the common fields
        self.opcode = int(self.binary_instr[25:32], 2)
        self.rd = int(self.binary_instr[20:25], 2)
        self.funct3 = int(self.binary_instr[17:20], 2)
        self.rs1 = int(self.binary_instr[12:17], 2)
        self.rs2 = int(self.binary_instr[7:12], 2)
        self.funct7 = int(self.binary_instr[0:7], 2)

        if self.opcode in [0b0110011]:  # R-type
            self.instr_type = 'R'
            # R-type instructions
            self.shamt = None  # shift amount field is not used for R-type in this context
        elif self.opcode in [0b0010011, 0b0000011, 0b1100111, 0b0000000, 0b0001011]:  # I-type
            self.instr_type = 'I'       # I-type
            self.imm = int(self.binary_instr[0:12], 2)
            if self.binary_instr[0] == '1':  # sign extend if necessary
                self.imm -= (1 << 12)
        elif self.opcode in [0b0100011]:  # S-type
            self.instr_type = 'S'
            imm_11_5 = int(self.binary_instr[0:7], 2)
            imm_4_0 = int(self.binary_instr[20:25], 2)
            self.imm = (imm_11_5 << 5) | imm_4_0
            if self.binary_instr[0] == '1':  # sign extend if necessary
                self.imm -= (1 << 12)
        elif self.opcode in [0b1100011]:  # B-type
            self.instr_type = 'B'
            imm_12 = int(self.binary_instr[0], 2)
            imm_10_5 = int(self.binary_instr[1:7], 2)
            imm_4_1 = int(self.binary_instr[20:24], 2)
            imm_11 = int(self.binary_instr[24], 2)
            self.imm = (imm_12 << 12) | (imm_11 << 11) | (imm_10_5 << 5) | (imm_4_1 << 1)
            if self.binary_instr[0] == '1':  # sign extend if necessary
                self.imm -= (1 << 13)
        elif self.opcode in [0b0110111, 0b0010111]:  # U-type
            self.instr_type = 'U'
            self.imm = int(self.binary_instr[0:20], 2) << 12
        elif self.opcode in [0b1101111]:  # J-type
            self.instr_type = 'J'
            imm_20 = int(self.binary_instr[0], 2)
            imm_10_1 = int(self.binary_instr[1:11], 2)
            imm_11 = int(self.binary_instr[11], 2)
            imm_19_12 = int(self.binary_instr[12:20], 2)
            self.imm = (imm_20 << 20) | (imm_19_12 << 12) | (imm_11 << 11) | (imm_10_1 << 1)
            if self.binary_instr[0] == '1':  # sign extend if necessary
                self.imm -= (1 << 21)

    def log(self, logger):
        logger.debug("****** Current Instruction *********")
        logger.debug("Binary string: %s", self.binary_instr)
        logger.debug("Opcode: %s", '{0:07b}'.format(self.opcode))
        logger.debug("rd: %d", self.rd)
        logger.debug("funct3: %s", '{0:03b}'.format(self.funct3))
        logger.debug("rs1: %d", self.rs1)
        logger.debug("rs2: %d", self.rs2)
        logger.debug("funct7: %s", '{0:07b}'.format(self.funct7))

        if self.instr_type == 'R':
            logger.debug("Instruction Type: R")
        elif self.instr_type == 'I':
            logger.debug("Instruction Type: I")
            logger.debug("Immediate: %d", self.imm)
        elif self.instr_type == 'S':
            logger.debug("Instruction Type: S")
            logger.debug("Immediate: %d", self.imm)
        elif self.instr_type == 'B':
            logger.debug("Instruction Type: B")
            logger.debug("Immediate: %d", self.imm)
        elif self.instr_type == 'U':
            logger.debug("Instruction Type: U")
            logger.debug("Immediate: %d", self.imm)
        elif self.instr_type == 'J':
            logger.debug("Instruction Type: J")
            logger.debug("Immediate: %d", self.imm)
 
def reverse_hex_string_endiannes(hex_string):
    reversed_string = bytes.fromhex(hex_string)
    reversed_string = reversed_string[::-1]
    reversed_string = reversed_string.hex()
    return reversed_string

def rotate_right(value, shift, n_bits=32):
    """
    Rotate `value` to the right by `shift` bits.

    :param value: The integer value to rotate.
    :param shift: The number of bits to rotate by.
    :param n_bits: The bit-width of the integer (default 32 for standard integer).
    :return: The value after rotating to the right.
    """
    shift %= n_bits  # Ensure the shift is within the range of 0 to n_bits-1
    return (value >> shift) | (value << (n_bits - shift)) & ((1 << n_bits) - 1)

def shift_helper(value, shift,shift_type, n_bits=32):
    shift %= n_bits  # Ensure the shift is within the range of 0 to n_bits-1
    match shift_type:
        case 0:
            return (value  << shift)% 0x100000000
        case 1:
            return (value  >> shift) % 0x100000000
        case 2:
            if((value & 0x80000000)!=0):
                    filler = (0xFFFFFFFF >> (n_bits-shift))<<((n_bits-shift))
                    return ((value  >> shift)|filler) % 0x100000000
            else:
                return (value  >> shift) % 0x100000000
        case 3:
            return rotate_right(value,shift,n_bits)
        
def reverse_hex_string_endiannes(hex_string):  
    reversed_string = bytes.fromhex(hex_string)
    reversed_string = reversed_string[::-1]
    reversed_string = reversed_string.hex()        
    return  reversed_string
class ByteAddressableMemory:
    def __init__(self, size):
        self.size = size
        self.memory = bytearray(size)  # Initialize memory as a bytearray of the given size

    def read(self, address):
        if address < 0 or address + 4 > self.size:
            raise ValueError("Invalid memory address or length")
        return_val = bytes(self.memory[address : address + 4])
        return_val = return_val[::-1]
        return return_val

    def write(self, address, data):
        if address < 0 or address + 4> self.size:
            raise ValueError("Invalid memory address or data length")
        data = data & 0xFFFFFFFF
        data_bytes = data.to_bytes(4, byteorder='little')
        self.memory[address : address + 4] = data_bytes        


def Log_Datapath(dut,logger):
    #Log whatever signal you want from the datapath, called before positive clock edge
    logger.debug("************ DUT DATAPATH Signals ***************")
    dut._log.info("reset:%s", hex(dut.my_datapath.reset.value.integer))
    dut._log.info("ALUSrc:%s", hex(dut.my_datapath.ALUSrc.value.integer))
    dut._log.info("MemWrite:%s", hex(dut.my_datapath.MemWrite.value.integer))
    dut._log.info("RegWrite:%s", hex(dut.my_datapath.RegWrite.value.integer))
    dut._log.info("PCSrc:%s", hex(dut.my_datapath.PCSrc.value.integer))
    dut._log.info("MemtoReg:%s", hex(dut.my_datapath.MemtoReg.value.integer))
    dut._log.info("RegSrc:%s", hex(dut.my_datapath.RegSrc.value.integer))
    dut._log.info("ImmSrc:%s", hex(dut.my_datapath.ImmSrc.value.integer))
    dut._log.info("ALUControl:%s", hex(dut.my_datapath.ALUControl.value.integer))
    dut._log.info("CO:%s", hex(dut.my_datapath.CO.value.integer))
    dut._log.info("OVF:%s", hex(dut.my_datapath.OVF.value.integer))
    dut._log.info("N:%s", hex(dut.my_datapath.N.value.integer))
    dut._log.info("Z:%s", hex(dut.my_datapath.Z.value.integer))
    dut._log.info("CarryIN:%s", hex(dut.my_datapath.CarryIN.value.integer))
    dut._log.info("ShiftControl:%s", hex(dut.my_datapath.ShiftControl.value.integer))
    dut._log.info("shamt:%s", hex(dut.my_datapath.shamt.value.integer))
    dut._log.info("PC:%s", hex(dut.my_datapath.PC.value.integer))
    dut._log.info("Instruction:%s", hex(dut.my_datapath.Instruction.value.integer))

def Log_Controller(dut,logger):
    #Log whatever signal you want from the controller, called before positive clock edge
    logger.debug("************ DUT Controller Signals ***************")
    dut._log.info("Op:%s", hex(dut.my_controller.Op.value.integer))
    dut._log.info("Funct:%s", hex(dut.my_controller.Funct.value.integer))
    dut._log.info("Rd:%s", hex(dut.my_controller.Rd.value.integer))
    dut._log.info("Src2:%s", hex(dut.my_controller.Src2.value.integer))
    dut._log.info("PCSrc:%s", hex(dut.my_controller.PCSrc.value.integer))
    dut._log.info("RegWrite:%s", hex(dut.my_controller.RegWrite.value.integer))
    dut._log.info("MemWrite:%s", hex(dut.my_controller.MemWrite.value.integer))
    dut._log.info("ALUSrc:%s", hex(dut.my_controller.ALUSrc.value.integer))
    dut._log.info("MemtoReg:%s", hex(dut.my_controller.MemtoReg.value.integer))
    dut._log.info("ALUControl:%s", hex(dut.my_controller.ALUControl.value.integer))
    dut._log.info("FlagWrite:%s", hex(dut.my_controller.FlagWrite.value.integer))
    dut._log.info("ImmSrc:%s", hex(dut.my_controller.ImmSrc.value.integer))
    dut._log.info("RegSrc:%s", hex(dut.my_controller.RegSrc.value.integer))
    dut._log.info("ShiftControl:%s", hex(dut.my_controller.ShiftControl.value.integer))
    dut._log.info("shamt:%s", hex(dut.my_controller.shamt.value.integer))
    dut._log.info("CondEx:%s", hex(dut.my_controller.CondEx.value.integer))