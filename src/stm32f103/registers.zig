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

pub fn gpio_address(domain: GpioDomain) *volatile GpioType {
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

pub const EnableGpioError = error {
    GpioAlreadyEnabled, 
};

pub fn enable_gpio(domain: GpioDomain) EnableGpioError!void {
    const v = rcc_apb2_enr.*; 
    const bit_idx : u5 = 
        @intFromEnum(domain) + 2;
    const bit = @as(u32, 1) << bit_idx;
    if ((v & bit) != 0) {
        return EnableGpioError.GpioAlreadyEnabled; 
    }
    const w = v | bit; 
    rcc_apb2_enr.* = w;  
}

pub const Pin = struct {
    port: GpioDomain,
    pin: u4, 
    pub fn write(self: Pin, comptime one: u1) void {
        const value : u32 = @as(u32, 1) << self.pin; 
        const value_write : u32 = if (one == 1) value else value << 16 ; 
        const gpio = gpio_address(self.port); 
        gpio.bsrr = value_write; 
        return ; 
    }
    pub const set = write; 
};

comptime {
    _ = Pin; 
    _ = Pin.set; 
}