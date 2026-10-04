# TypeScript lint (opt-in)

Optional correctness checks, not mechanical enforcement of design preferences. Select rules that fit existing code and required contracts; do not use implementation counts, class/name bans, or fixed complexity limits as proxies for simplicity.

Reference only - merge into a project's config when asked. Targets ESLint 9 flat config, typescript-eslint v8, and TypeScript 5.8+. Check the project's installed versions before copying.

| Rule | Enforced by |
|---|---|
| Exhaustive union handling, including never-check arms | `@typescript-eslint/switch-exhaustiveness-check` (in no preset) |
| Handle promises and throw `Error` values | `@typescript-eslint/only-throw-error`, `no-floating-promises` |
| No `any`, no blind casts, no `!` | `no-explicit-any`, `consistent-type-assertions`, `no-non-null-assertion` |
| No impossible-case checks | `@typescript-eslint/no-unnecessary-condition` |
| Prefer const when reassignment is unnecessary | `prefer-const` |
| No unused params | `@typescript-eslint/no-unused-vars`, tsconfig `noUnusedParameters` |

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
      "@typescript-eslint/switch-exhaustiveness-check": [
        "error",
        { allowDefaultCaseForExhaustiveSwitch: true, considerDefaultExhaustiveForUnions: false },
      ],
      "@typescript-eslint/consistent-type-assertions": [
        "error",
        { assertionStyle: "as", objectLiteralTypeAssertions: "never" },
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
  "noImplicitReturns": true
}
```
