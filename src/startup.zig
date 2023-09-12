const main = @import("main.zig");

// These symbols come from the linker script
extern const _data_loadaddr: u32;
extern var _data: u32;
extern const _edata: u32;
extern var _bss: u32;
extern const _ebss: u32;

export fn resetHandler() void {
    // Copy data from flash to RAM
    // version 0.9 
    // const data_loadaddr = @ptrCast([*]const u8, &_data_loadaddr);
    // const data = @ptrCast([*]u8, &_data);
    // version 0.11 
    const data_loadaddr : [*] const u8 = @ptrCast(&_data_loadaddr);
    const data : [*] u8 = @ptrCast(&_data);
    const data_size = @intFromPtr(&_edata) - @intFromPtr(&_data);
    for (data_loadaddr[0..data_size], 0..) |d, i| data[i] = d;

    // Clear the bss
    // const bss = @ptrCast([*]u8, &_bss);
    // const bss_size = @ptrToInt(&_ebss) - @ptrToInt(&_bss);
    const bss : [*] u8 = @ptrCast(&_bss);
    const bss_size = @intFromPtr(&_ebss) - @intFromPtr(&_bss);
    for (bss[0..bss_size]) |*b| b.* = 0;

    // Call contained in main.zig
    main.main();

    unreachable;
}
