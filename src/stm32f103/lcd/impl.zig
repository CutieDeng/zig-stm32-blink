const register = @import("../registers.zig");
const lcd = @import("../lcd.zig");

const std = @import("std"); 

const Pin = register.Pin; 
const GpioDomain = register.GpioDomain; 

pub const rs : Pin = .{ .port = .C, .pin = 8, };
pub const cs : Pin = .{ .port = .C, .pin = 9, }; 
pub const rd : Pin = .{ .port = .C, .pin = 6, }; 
pub const wr : Pin = .{ .port = .C, .pin = 7, }; 
pub const bl : Pin = .{ .port = .C, .pin = 10, }; 
pub const data_domain : GpioDomain = .B;

const color = lcd.color; 
pub var foreground : color.Color = color.black;
pub var background : color.Color = color.white; 

pub inline fn raw_get_data() u16 {
    const gpio_type = comptime register.gpio_address(data_domain); 
    const input : u16 = @truncate(gpio_type.idr); 
    return input; 
}

pub inline fn raw_write_data(input: u16) void {
    const gpio_type = comptime register.gpio_address(data_domain); 
    gpio_type.odr = input; 
}

pub fn init() void {
    const ps = .{ .C, .B }; 
    inline for (ps) |p| {
        register.enable_gpio(p) catch {}; 
    }
}

pub fn write_data(input: u16) void {
    rs.write(1); 
    cs.write(0); 
    defer cs.write(1); 
    raw_write_data(input); 
    wr.write(0); 
    defer wr.write(1); 
}

pub fn raw_write_register(input: u16) void {
    rs.write(0); 
    cs.write(0); 
    defer cs.write(1); 
    raw_write_data(input); 
    wr.write(0); 
    defer wr.write(1); 
}

pub fn write_register(reg: u16, input: u16) void {
    raw_write_register(reg); 
    return raw_write_data(input); 
}

