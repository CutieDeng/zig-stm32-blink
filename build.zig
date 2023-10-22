const Builder = @import("std").build.Builder;
const builtin = @import("builtin");
const std = @import("std");

pub fn build(b: *Builder) void {
    // Target STM32F407VG
    // Target STM32F103RCT6 
    const target : std.zig.CrossTarget = .{
        .cpu_arch = .thumb,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m3 },
        // .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m4 },
        .os_tag = .freestanding,
        .abi = .eabihf,
    };
    const mode : std.builtin.Mode = b.standardOptimizeOption(.{}); 
    const elf : *std.Build.Step.Compile = b.addExecutable(.{
        .name = "zig-stm32-blink.elf", 
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target, 
        .optimize = mode, 
    });
    elf.setLinkerScriptPath(.{ .path = "src/linker.ld" });
    const artifact: *std.Build.Step.InstallArtifact = b.addInstallArtifact(elf, .{});
    b.default_step.dependOn(&elf.step);
    b.default_step.dependOn(&artifact.step); 
    const cmd : *std.Build.Step.Run = b.addSystemCommand(&[_][]const u8{
        "zig", 
        "objcopy",
        "-O", 
        "binary", 
        "zig-out/bin/zig-stm32-blink.elf", 
        "zig-out/bin/zig-stm32-blink.bin",
    }); 
    const cpStep: *std.Build.Step.ObjCopy = b.addObjCopy(.{ .generated = elf.getEmittedBin().generated }, .{
        .format = .bin, 
        .basename = "bin",
    } ); 
    cpStep.step.dependOn(&artifact.step);
    const bin2 = b.step("bin2", "test"); 
    bin2.dependOn(&cpStep.step); 
    const bin_step : *std.build.Builder.Step = b.step("bin", "Generate binary file to be flashed");
    bin_step.dependOn(&cmd.step);
    cmd.step.dependOn(b.default_step); 
    b.default_step.dependOn(&elf.step);
    const flash_cmd = b.addSystemCommand(&[_][]const u8{
        "st-flash",
        "write",
        "zig-out/bin/zig-stm32-blink.bin", 
        "0x8000000",
    });
    flash_cmd.step.dependOn(bin_step); 
    const flash_step = b.step("flash", "Flash and run the app on your STM32F4Discovery");
    flash_step.dependOn(&flash_cmd.step);
}
