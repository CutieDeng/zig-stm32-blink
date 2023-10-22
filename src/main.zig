pub const registers = @import("stm32f103/registers.zig");
pub const lcd = @import("stm32f103/lcd.zig");

const std = @import("std"); 

pub export fn main() callconv(.C) void {

    registers.enable_gpio(.A) catch unreachable; 
    registers.enable_gpio(.D) catch unreachable; 
    lcd.impl.init(); 

    var flip: bool = true; 

    const gpa = comptime registers.gpio_address(.A);
    const gpc = comptime registers.gpio_address(.C); 
    const gpd = comptime registers.gpio_address(.D); 

    // PA8 is the LED on the blue pill board. 
    gpa.crh &= 0xffff_fff0; 
    gpa.crh |= 0x0000_0003; 

    // PD2 is the LED on the black pill board. 
    gpd.crl &= 0xffff_f0ff; 
    gpd.crl |= 0xffff_f3ff; 

    // PA0 as input 
    // gpa.crl &= 0xffff_fff0; 
    // gpa.crl |= 0x0000_0008; 

    // PC5 as input (pull up )
    gpc.crl &= 0xff0f_ffff; 
    gpc.crl |= 0x0080_0000; 
    gpc.odr |= 1 << 5; 

    var idx : u128 = 0; 

    const rd = lcd.impl.rd;
    registers.enable_gpio(rd.port) catch {};       
    rd.write(0); 
    lcd.impl.write_data(15); 

    var inc: std.atomic.Atomic(i32) = .{ .value = 1 };  

    while (true) : (idx += 1) {
        const l = inc.load(.Unordered);
        
        inc.store(l + 1, .Unordered); 
        if (idx % 0x100000 != 0) {
            continue ;
        }
        const aset = 1 << 8; 
        if (flip) {
            gpa.odr &= ~@as(u32, aset); 
        } else {
            gpa.odr |= aset; 
        }
        if (gpc.idr & (1 << 5) != 0) {
            // flip = true; 
        }
        const bset = 1 << 2; 
        if (flip) {
            gpd.odr |= bset; 
        } else {
            gpd.odr &= ~@as(u32, bset); 
        }
        flip = !flip; 
    }
}
