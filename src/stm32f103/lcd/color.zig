const std = @import("std"); 

const from_u16 = Color.from_u16; 

pub const white = from_u16(0xffff); 
pub const black = from_u16(0x0000); 
pub const red = from_u16(0xf800); 
pub const green = from_u16(0x07e0); 
pub const blue = from_u16(0x001f); 
pub const meganta = from_u16(0xf81f); 
pub const yellow = from_u16(0xffe0); 
pub const cyan = from_u16(0x07ff); 
pub const brown = from_u16(0xbc40); 
pub const brred = from_u16(0xfc07); 
pub const gray = from_u16(0x8430); 
pub const darkblue = from_u16(0x0010); 
pub const lightblue = from_u16(0x7d7c);
pub const grayblue = from_u16(0x5458); 
pub const lightgreen = from_u16(0x841f); 
pub const lightgray = from_u16(0xc618); 
pub const lightgrayblue = from_u16(0xa651); 
pub const lightbrownblue = from_u16(0x2b12); 

pub const Color = packed struct {
    r: u5, 
    g: u6, 
    b: u5, 
    pub fn from_u16(v: u16) Color {
        return @bitCast(v); 
    }
};

comptime {
    std.debug.assert(@sizeOf(Color) == 2);     
    _ = white;
    _ = black; 
}