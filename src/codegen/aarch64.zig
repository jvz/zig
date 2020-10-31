const std = @import("std");
const DW = std.dwarf;
const testing = std.testing;

// zig fmt: off

/// General purpose registers in the AArch64 instruction set
pub const Register = enum(u6) {
    // 64-bit registers
    x0, x1, x2, x3, x4, x5, x6, x7,
    x8, x9, x10, x11, x12, x13, x14, x15,
    x16, x17, x18, x19, x20, x21, x22, x23,
    x24, x25, x26, x27, x28, x29, x30, xzr,

    // 32-bit registers
    w0, w1, w2, w3, w4, w5, w6, w7,
    w8, w9, w10, w11, w12, w13, w14, w15,
    w16, w17, w18, w19, w20, w21, w22, w23,
    w24, w25, w26, w27, w28, w29, w30, wzr,

    pub fn id(self: Register) u5 {
        return @truncate(u5, @enumToInt(self));
    }

    /// Returns the bit-width of the register.
    pub fn size(self: Register) u7 {
        return switch (@enumToInt(self)) {
            0...31 => 64,
            32...63 => 32,
        };
    }

    /// Convert from any register to its 64 bit alias.
    pub fn to64(self: Register) Register {
        return @intToEnum(Register, self.id());
    }

    /// Convert from any register to its 32 bit alias.
    pub fn to32(self: Register) Register {
        return @intToEnum(Register, @as(u6, self.id()) + 32);
    }

    /// Returns the index into `callee_preserved_regs`.
    pub fn allocIndex(self: Register) ?u4 {
        inline for (callee_preserved_regs) |cpreg, i| {
            if (self.id() == cpreg.id()) return i;
        }
        return null;
    }

    pub fn dwarfLocOp(self: Register) u8 {
        return @as(u8, self.id()) + DW.OP_reg0;
    }
};

// zig fmt: on

pub const callee_preserved_regs = [_]Register{
    .x19, .x20, .x21, .x22, .x23,
    .x24, .x25, .x26, .x27, .x28,
};
pub const c_abi_int_param_regs = [_]Register{ .x0, .x1, .x2, .x3, .x4, .x5, .x6, .x7 };
pub const c_abi_int_return_regs = [_]Register{ .x0, .x1 };

test "Register.id" {
    testing.expectEqual(@as(u5, 0), Register.x0.id());
    testing.expectEqual(@as(u5, 0), Register.w0.id());

    testing.expectEqual(@as(u5, 31), Register.xzr.id());
    testing.expectEqual(@as(u5, 31), Register.wzr.id());
}

test "Register.size" {
    testing.expectEqual(@as(u7, 64), Register.x19.size());
    testing.expectEqual(@as(u7, 32), Register.w3.size());
}

test "Register.to64/to32" {
    testing.expectEqual(Register.x0, Register.w0.to64());
    testing.expectEqual(Register.x0, Register.x0.to64());

    testing.expectEqual(Register.w3, Register.w3.to32());
    testing.expectEqual(Register.w3, Register.x3.to32());
}

// zig fmt: off

/// Scalar floating point registers in the aarch64 instruction set
pub const FloatingPointRegister = enum(u8) {
    // 128-bit registers
    q0, q1, q2, q3, q4, q5, q6, q7,
    q8, q9, q10, q11, q12, q13, q14, q15,
    q16, q17, q18, q19, q20, q21, q22, q23,
    q24, q25, q26, q27, q28, q29, q30, q31,

    // 64-bit registers
    d0, d1, d2, d3, d4, d5, d6, d7,
    d8, d9, d10, d11, d12, d13, d14, d15,
    d16, d17, d18, d19, d20, d21, d22, d23,
    d24, d25, d26, d27, d28, d29, d30, d31,

    // 32-bit registers
    s0, s1, s2, s3, s4, s5, s6, s7,
    s8, s9, s10, s11, s12, s13, s14, s15,
    s16, s17, s18, s19, s20, s21, s22, s23,
    s24, s25, s26, s27, s28, s29, s30, s31,

    // 16-bit registers
    h0, h1, h2, h3, h4, h5, h6, h7,
    h8, h9, h10, h11, h12, h13, h14, h15,
    h16, h17, h18, h19, h20, h21, h22, h23,
    h24, h25, h26, h27, h28, h29, h30, h31,

    // 8-bit registers
    b0, b1, b2, b3, b4, b5, b6, b7,
    b8, b9, b10, b11, b12, b13, b14, b15,
    b16, b17, b18, b19, b20, b21, b22, b23,
    b24, b25, b26, b27, b28, b29, b30, b31,

    pub fn id(self: FloatingPointRegister) u5 {
        return @truncate(u5, @enumToInt(self));
    }

    /// Returns the bit-width of the register.
    pub fn size(self: FloatingPointRegister) u8 {
        return switch (@enumToInt(self)) {
            0...31 => 128,
            32...63 => 64,
            64...95 => 32,
            96...127 => 16,
            128...159 => 8,
            else => unreachable,
        };
    }

    /// Convert from any register to its 128 bit alias.
    pub fn to128(self: FloatingPointRegister) FloatingPointRegister {
        return @intToEnum(FloatingPointRegister, self.id());
    }

    /// Convert from any register to its 64 bit alias.
    pub fn to64(self: FloatingPointRegister) FloatingPointRegister {
        return @intToEnum(FloatingPointRegister, @as(u8, self.id()) + 32);
    }

    /// Convert from any register to its 32 bit alias.
    pub fn to32(self: FloatingPointRegister) FloatingPointRegister {
        return @intToEnum(FloatingPointRegister, @as(u8, self.id()) + 64);
    }

    /// Convert from any register to its 16 bit alias.
    pub fn to16(self: FloatingPointRegister) FloatingPointRegister {
        return @intToEnum(FloatingPointRegister, @as(u8, self.id()) + 96);
    }

    /// Convert from any register to its 8 bit alias.
    pub fn to8(self: FloatingPointRegister) FloatingPointRegister {
        return @intToEnum(FloatingPointRegister, @as(u8, self.id()) + 128);
    }
};

// zig fmt: on

test "FloatingPointRegister.id" {
    testing.expectEqual(@as(u5, 0), FloatingPointRegister.b0.id());
    testing.expectEqual(@as(u5, 0), FloatingPointRegister.h0.id());
    testing.expectEqual(@as(u5, 0), FloatingPointRegister.s0.id());
    testing.expectEqual(@as(u5, 0), FloatingPointRegister.d0.id());
    testing.expectEqual(@as(u5, 0), FloatingPointRegister.q0.id());

    testing.expectEqual(@as(u5, 2), FloatingPointRegister.q2.id());
    testing.expectEqual(@as(u5, 31), FloatingPointRegister.d31.id());
}

test "FloatingPointRegister.size" {
    testing.expectEqual(@as(u8, 128), FloatingPointRegister.q1.size());
    testing.expectEqual(@as(u8, 64), FloatingPointRegister.d2.size());
    testing.expectEqual(@as(u8, 32), FloatingPointRegister.s3.size());
    testing.expectEqual(@as(u8, 16), FloatingPointRegister.h4.size());
    testing.expectEqual(@as(u8, 8), FloatingPointRegister.b5.size());
}

test "FloatingPointRegister.toX" {
    testing.expectEqual(FloatingPointRegister.q1, FloatingPointRegister.q1.to128());
    testing.expectEqual(FloatingPointRegister.q2, FloatingPointRegister.b2.to128());
    testing.expectEqual(FloatingPointRegister.q3, FloatingPointRegister.h3.to128());

    testing.expectEqual(FloatingPointRegister.d0, FloatingPointRegister.q0.to64());
    testing.expectEqual(FloatingPointRegister.s1, FloatingPointRegister.d1.to32());
    testing.expectEqual(FloatingPointRegister.h2, FloatingPointRegister.s2.to16());
    testing.expectEqual(FloatingPointRegister.b3, FloatingPointRegister.h3.to8());
}

/// Represents an instruction in the AArch64 instruction set
pub const Instruction = union(enum) {
    SupervisorCall: packed struct {
        fixed_1: u5 = 0b00001,
        imm16: u16,
        fixed_2: u11 = 0b11010100000,
    },

    pub fn toU32(self: Instruction) u32 {
        return switch (self) {
            .SupervisorCall => |v| @bitCast(u32, v),
        };
    }

    // Helper functions for assembly syntax functions

    fn supervisorCall(imm16: u16) Instruction {
        return Instruction{
            .SupervisorCall = .{
                .imm16 = imm16,
            },
        };
    }

    // Supervisor Call

    pub fn svc(imm16: u16) Instruction {
        return supervisorCall(imm16);
    }
};

test "serialize instructions" {
    const Testcase = struct {
        inst: Instruction,
        expected: u32,
    };

    const testcases = [_]Testcase{
        .{ // svc #0
            .inst = Instruction.svc(0),
            .expected = 0b1101_0100_000_0000000000000000_00001,
        },
    };

    for (testcases) |case| {
        const actual = case.inst.toU32();
        testing.expectEqual(case.expected, actual);
    }
}
