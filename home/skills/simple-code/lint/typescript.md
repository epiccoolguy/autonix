# TypeScript lint (opt-in)

Reference only - merge into a project's config when asked. Targets ESLint 9 flat config, typescript-eslint v8, and TypeScript 5.8+. Check the project's installed versions before copying.

| Rule | Enforced by |
|---|---|
| Exhaustive match, no default arm | `@typescript-eslint/switch-exhaustiveness-check` (in no preset) |
| No classes except `Error` subclasses | `no-restricted-syntax`, `@typescript-eslint/no-extraneous-class` |
| Nesting depth 3 | `max-depth` (counts blocks inside the function) |
| Errors are values; only throw `Error` | `@typescript-eslint/only-throw-error`, `no-floating-promises` |
| No `any`, no blind casts, no `!` | `no-explicit-any`, `consistent-type-assertions`, `no-non-null-assertion` |
| No impossible-case checks | `@typescript-eslint/no-unnecessary-condition` |
| Immutable by default | `no-param-reassign`, `prefer-const` |
| No unused params | `@typescript-eslint/no-unused-vars`, tsconfig `noUnusedParameters` |
| Banned name suffixes | `@typescript-eslint/naming-convention` |
| No enums, namespaces, parameter properties | tsconfig `erasableSyntaxOnly` |

`eslint.config.js`:
```js
import { defineConfig } from "eslint/config";
import tseslint from "typescript-eslint";

export default defineConfig(
  tseslint.configs.strictTypeChecked,
  tseslint.configs.stylisticTypeChecked,
  {
    languageOptions: {
      parserOptions: { projectService: true, tsconfigRootDir: import.meta.dirname },
    },
    rules: {
      "max-depth": ["error", 3],
      "no-param-reassign": "error",
      "no-restricted-syntax": [
        "error",
        {
          selector: "ClassDeclaration:not([superClass.name=/Error$/])",
          message: "Use a type and functions; classes only for Error subclasses.",
        },
      ],
      "@typescript-eslint/switch-exhaustiveness-check": [
        "error",
        { allowDefaultCaseForExhaustiveSwitch: false, considerDefaultExhaustiveForUnions: false },
      ],
      "@typescript-eslint/consistent-type-assertions": [
        "error",
        { assertionStyle: "as", objectLiteralTypeAssertions: "never" },
      ],
      "@typescript-eslint/naming-convention": [
        "error",
        {
          selector: ["typeLike", "function", "variable"],
          format: null,
          custom: { regex: "(Manager|Helper|Util|Utils|Factory|Impl|Base)$", match: false },
        },
      ],
    },
  },
);
```

`tsconfig.json` `compilerOptions`:
```json
{
  "strict": true,
  "noUncheckedIndexedAccess": true,
  "noUnusedLocals": true,
  "noUnusedParameters": true,
  "noFallthroughCasesInSwitch": true,
  "noImplicitReturns": true,
  "erasableSyntaxOnly": true
}
```
Framework repos that need classes or decorators (NestJS, Angular) drop `no-restricted-syntax` and `erasableSyntaxOnly`.
