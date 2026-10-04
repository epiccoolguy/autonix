# Zig

Zig already enforces much of this. The compiler rejects unused locals and parameters and non-exhaustive `switch` on enums and tagged unions, and requires every error union to be handled. `zig fmt` only formats. There is no extra lint config to add.

## Data

- Plain structs; methods are functions taking `self: Self` or `self: *Self`. Use `init` / `deinit` pairs for owned resources.
- Closed variants are `union(enum)` handled with an exhaustive `switch`. No `else` prong when switching on your own enums.
- `const` by default; `var` only where the value changes.

## Memory and dependencies

- Any function that allocates takes a `std.mem.Allocator` parameter. No global allocators, no hidden allocation.
- The caller owns returned memory and frees it with `defer` on the next line.
- On a function's failure path, release partially acquired resources with `errdefer` right after each acquire.

## Errors

- Explicit error sets for public functions (`error{ NotFound, DiskFull }!T`); `anyerror` only at the top level.
- Propagate with `try`. Handle with `catch |err| switch (err) { ... }` listing each error.
- `catch unreachable` and `orelse unreachable` only for invariants the code proves. Panic only for bugs.

## Abstraction

- Polymorphism through `union(enum)` or `comptime` type parameters. No hand-rolled vtables (`*anyopaque` plus function pointers) for internal domain logic; they are for std-style boundaries like `std.mem.Allocator` or `std.Io.Writer`.
- `comptime` for generic types and real compile-time work only, not cleverness. No `anytype` where a concrete type works.
- Standard library first.

## Don't / do

Don't:
```zig
var global_allocator = std.heap.page_allocator;
pub fn create(name: []const u8) !Session {
    return .{ .id = try global_allocator.dupe(u8, name) };
}
```
Do:
```zig
pub fn init(allocator: std.mem.Allocator, name: []const u8) !Session {
    return .{ .id = try allocator.dupe(u8, name) };
}
pub fn deinit(self: Session, allocator: std.mem.Allocator) void {
    allocator.free(self.id);
}
// caller
const session = try Session.init(allocator, "user-42");
defer session.deinit(allocator);
```
