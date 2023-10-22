pub const font = @import("lcd/font.zig");
pub const color = @import("lcd/color.zig");
pub const impl = @import("lcd/impl.zig");

comptime { 
    _ = font; 
    _ = color; 
    _ = impl; 
}
