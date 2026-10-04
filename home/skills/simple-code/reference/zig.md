# Zig

- Prefer structs, functions, direct calls, and explicit loops. Use enum/tagged union and switch for closed alternatives, optionals for absence, and error unions with try/catch for failures. Avoid catch unreachable for errors that can actually occur.
- Make allocation and resource ownership explicit. Pass allocators where allocation is required; identify who frees returned memory. Use defer for scoped cleanup and errdefer for cleanup on failed construction. Do not omit real allocation failures in the name of simplicity.
- Use struct literals when construction is plain data; use init/deinit or other methods when they express invariants and lifecycle. Structs with methods are ordinary Zig, not evidence of unwanted OO design.
- Use comptime parameters, type-returning functions, and anytype when they clarify required genericity or compile-time work. Prefer explicit types otherwise. Avoid reflection frameworks or bespoke compile-time DSLs merely because comptime enables them.
- Use a narrow explicit runtime interface/vtable when actual runtime polymorphism requires it, and comptime polymorphism when compile-time selection fits. Zig has no Go-style built-in interface or Rust-style trait mechanism.
- Follow the repo's pinned Zig version and standard-library API. Keep helpers close and pub visibility narrow; do not transplant another language's class hierarchy or error/allocator conventions.
