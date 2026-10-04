# Rust

## Data and behavior

- Prefer structs, enums, functions, and inherent impl methods. Use enums and match for closed alternatives, and Option for absence.
- Protect invariants with private fields and validated constructors/newtypes. Typestate can justify extra types for important lifecycle constraints.
- Use traits for needed capabilities, ecosystem integration, or polymorphism. Choose generics/impl Trait or dyn Trait for actual dispatch/storage needs; coherence rules constrain where implementations can live.

## Control flow and effects

- Choose readable iterator chains or ordinary loops according to clarity. Use Result and ? for recoverable failures, preserving useful error meaning.
- Make ownership and lifetimes clear; borrow or move deliberately. Clone, Box, Rc, Arc, and interior mutability need concrete ownership/storage reasons. A simple clone can be clearer than a convoluted lifetime design.
- Use Drop/RAII for cleanup. Do not panic on ordinary input failures or obscure important effects behind unnamed machinery.

## Modules and boundaries

- Choose cohesive modules and narrow visibility rather than one file per type. Reuse standard traits and existing error conventions.
- Generics and derive can reduce ceremony; custom macros, excessive bounds, and type-level machinery need benefits exceeding their diagnostic and maintenance costs.
