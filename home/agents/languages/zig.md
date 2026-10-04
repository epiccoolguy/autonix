# Zig Idioms

Write explicit, transparent Zig: caller-owned memory, explicit allocators, plain structs, comptime type-functions, and no hidden control flow.

## Rules

- No hidden allocations: functions that allocate must accept a `std.mem.Allocator` as an explicit parameter.
- Caller owns allocated memory. Colocate cleanup with `defer allocator.free(...)` immediately after successful allocation.
- Plain structs with method syntax (`fn init(...)`, `fn deinit(...)`). A method is merely a function taking `self: *Self` or `self: Self`.
- Polymorphism via tagged `union(enum)` with exhaustive `switch`, or `comptime` type parameters. Never construct custom vtables or interface pointer structs for internal domain logic.
- Use explicit error sets `error{NotFound, DiskFull}!T`. Early return with `try`.

## Side-by-Side Comparison

### State & Polymorphism

AVOID (Emulating OOP VTables):
```zig
// AVOID: Simulating class vtables in Zig
const ReaderInterface = struct {
    ptr: *anyopaque,
    readFn: *const fn (ctx: *anyopaque, buf: []u8) anyerror!usize,

    pub fn read(self: ReaderInterface, buf: []u8) anyerror!usize {
        return self.readFn(self.ptr, buf);
    }
};
```

DO (Tagged Union with Exhaustive Switch):
```zig
pub const Backend = union(enum) {
    memory: MemoryBackend,
    file: FileBackend,

    pub fn read(self: *Backend, buf: []u8) !usize {
        return switch (self.*) {
            .memory => |*m| m.read(buf),
            .file => |*f| f.read(buf),
        };
    }
};
```

### Memory Management & Resource Lifetime

AVOID (Hidden Allocation Inside Init / Global State):
```zig
var global_allocator = std.heap.page_allocator;

pub const Session = struct {
    id: []const u8,

    pub fn create(name: []const u8) !Session {
        // Hiding allocator from the caller
        const id = try global_allocator.dupe(u8, name);
        return Session{ .id = id };
    }
};
```

DO (Explicit Allocator & Caller Deferral):
```zig
pub const Session = struct {
    id: []const u8,

    pub fn init(allocator: std.mem.Allocator, name: []const u8) !Session {
        const id = try allocator.dupe(u8, name);
        return Session{ .id = id };
    }

    pub fn deinit(self: Session, allocator: std.mem.Allocator) void {
        allocator.free(self.id);
    }
};

// Caller site:
const session = try Session.init(allocator, "user-42");
defer session.deinit(allocator);
```
