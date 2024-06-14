_00: addi    x31, x0, 0x430
_04: ori     x30, x0, -0x421
_08: add     x29, x30, x31
_0C: sub     x28, x31, x30
_10: and     x27, x31, x30
_14: xor     x26, x31, x30

_18: srai    x1, x30, 24
_1C: slli    x2, x30, 8
_20: srl     x3, x30, x28

_24: slt     x4, x29, x31
_28: sltu    x5, x31, x29
_2C: slti    x6, x30, 0

_30: lui     x7, 0xABC
_34: auipc   x8, 0xCDE
_38: xorid   x9, x27, 0

_3C: sw      x30, 4(x27)
_40: lw      x10, 4(x27)

_44: sh      x31, 8(x27)
_48: lb      x11, 4(x27)
_4C: lhu     x12, 7(x27)

_50: bne     x30, x31, 12
_54: addi    x0, x0, 0
_58: addi    x0, x0, 0
_5C: bge     x26, x29, 12
_60: bltu    x30, x29, 8
_64: addi    x0, x0, 0

_68: jal     x13, 4
_6C: jalr    x14, 8(x13)
_70: halt    x0, 0
_74: jal     x0, -4
_78: halt    x0, 0
