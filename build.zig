const Builder = @import("std").build.Builder;
const builtin = @import("builtin");
const std = @import("std");

pub fn build(b: *Builder) void {

    // Target STM32F407VG
    const target : std.zig.CrossTarget = .{
        .cpu_arch = .thumb,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m4 },
        .os_tag = .freestanding,
        .abi = .eabihf,
    };

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode : std.builtin.Mode = b.standardOptimizeOption(.{}); 

    const elf : *std.Build.Step.Compile = b.addExecutable(.{
        .name = "zig-stm32-blink.elf", 
        .root_source_file = .{ .path = "src/startup.zig" },
        .target = target, 
        .optimize = mode, 
    });

    const vector_obj : *std.Build.Step.Compile = b.addObject( .{
        .name = "vector", 
        .root_source_file = .{ .path = "src/vector.zig" }, 
        .target = target, 
        .optimize = mode, 
    }) ;

    elf.addObject(vector_obj);
    elf.setLinkerScriptPath(.{ .path = "src/linker.ld" });

    // const bin = b.addInstallRaw(elf, "zig-stm32-blink.bin", .{});
    // const ibn = b.addInstallBinFile(source: LazyPath, dest_rel_path: []const u8)
    const bin_step : *std.build.Builder.Step = b.step("bin", "Generate binary file to be flashed");
    _ = bin_step;
    // bin_step.dependOn(&bin.step);

    // const flash_cmd = b.addSystemCommand(&[_][]const u8{
    //     "st-flash",
    //     "write",
    //     b.getInstallPath(bin.dest_dir, bin.dest_filename),
    //     "0x8000000",
    // });
    // flash_cmd.step.dependOn(&bin.step);
    // const flash_step = b.step("flash", "Flash and run the app on your STM32F4Discovery");
    // flash_step.dependOn(&flash_cmd.step);

    b.default_step.dependOn(&elf.step);
    b.installArtifact(elf);
}
