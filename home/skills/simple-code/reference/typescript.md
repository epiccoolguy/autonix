# TypeScript

## Data and behavior

- Prefer functions, object literals, closures, and modules. Use classes when identity, encapsulated state, lifecycle, or framework integration benefits.
- Model closed alternatives with discriminated unions and explicit optionality. Use exhaustive narrowing where omissions matter; a never-check can prove exhaustiveness. readonly constrains assignments, not runtime deep mutation.
- Use structural object or function types for needed capabilities. Follow local type/interface conventions. Brands are useful only with validated, controlled construction; avoid elaborate conditional types for simple models.

## Control flow and effects

- Choose array transformations, for...of, or generators according to clarity. Use async/await for sequential effects; make concurrency deliberate. Async callbacks in forEach do not await work.
- Preserve rejection handling, cancellation, ordering, and cleanup. Follow the repo's exception or result conventions rather than adding a project-wide error wrapper.

## Modules and boundaries

- Validate unknown external input with the existing parser/schema. Annotations, assertions, and brands do not validate runtime data.
- Use module exports rather than static utility classes. Pass dependencies explicitly or capture them in a clearly constructed closure; avoid service locators.
- For JavaScript in the same project, use existing JSDoc/checking conventions without introducing a language migration.
