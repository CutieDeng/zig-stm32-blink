pub const rcc_base: usize = (0x4002_1000); 
pub const rcc_apb2enr_offset: usize = 0x18; 
pub const rcc_apb2_enr: *volatile u32 = @ptrFromInt(rcc_base + rcc_apb2enr_offset); 

pub const GpioDomain = enum {
    A, B, C, D, E, F, G
};

pub const GpioType = extern struct {
    crl: u32, 
    crh: u32, 
    idr: u32, 
    odr: u32, 
    bsrr: u32, 
    brr: u32, 
    lckr: u32,
};

pub fn gpio_address(comptime domain: GpioDomain) *volatile GpioType {
    const r: *volatile GpioType = 
        switch (domain) {
            .A => @ptrFromInt(0x4001_0800),
            .B => @ptrFromInt(0x4001_0C00),
            .C => @ptrFromInt(0x4001_1000),
            .D => @ptrFromInt(0x4001_1400),
            .E => @ptrFromInt(0x4001_1800),
            .F => @ptrFromInt(0x4001_1C00), 
            .G => @ptrFromInt(0x4001_2000), 
        }; 
    return r; 
}

pub fn enable_gpio(comptime domain: GpioDomain) !void {
    const v = rcc_apb2_enr.*; 
    const bit_idx = switch (domain) {
        .A => 2, 
        .B => 3, 
        .C => 4, 
        .D => 5, 
        .E => 6, 
        .F => @compileError("GPIO F not supported"),
        .G => @compileError("GPIO G not supported"), 
    };
    const bit = 1 << bit_idx; 
    if ((v & bit) != 0) {
        return error.GpioAlreadyEnabled; 
    }
    const w = v | bit; 
    rcc_apb2_enr.* = w;  
}