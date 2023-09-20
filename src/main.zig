// LED: A8 D2 

pub const registers = @import("stm32f103/registers.zig");

pub export fn main() callconv(.C) void {

    registers.enable_gpio(.A) catch {}; 
    registers.enable_gpio(.D) catch {}; 

    var flip: bool = true; 

    const gpa = registers.gpio_address(.A);
    gpa.crh &= 0xffff_fff0; 
    gpa.crh |= 0x0000_0003; 
    const gpd = registers.gpio_address(.D); 
    gpd.crl &= 0xffff_f0ff; 
    gpd.crl |= 0xffff_f3ff; 

    while (true) {
        const aset = 1 << 8; 
        if (flip) {
            gpa.odr &= ~@as(u32, aset); 
        } else {
            gpa.odr |= aset; 
        }
        const bset = 1 << 2; 
        if (flip) {
            gpd.odr |= bset; 
        } else {
            gpd.odr &= ~@as(u32, bset); 
        }
        for (0..2000000) |_| {
            asm volatile ( "nop" : : : "memory" ); 
        } 
        flip = !flip; 
    }
}
