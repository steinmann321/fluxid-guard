import js from "@eslint/js";
import globals from "globals";
import tseslint from "typescript-eslint";
import playwright from "eslint-plugin-playwright";
import { defineConfig, globalIgnores } from "eslint/config";

export default defineConfig([
  globalIgnores(["test-results", "node_modules"]),
  {
    files: ["**/*.{ts,tsx}"],
    extends: [
      js.configs.recommended,
      tseslint.configs.recommended,
      playwright.configs["flat/recommended"],
    ],
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: "module",
      globals: { ...globals.node, ...globals.browser },
      parserOptions: {
        projectService: true,
        tsconfigRootDir: process.cwd(),
      },
    },
    rules: {
      "no-console": ["error", { allow: ["warn", "error"] }],
      eqeqeq: ["error", "always"],
      curly: ["error", "all"],
      "no-implicit-coercion": "error",
      "no-warning-comments": [
        "error",
        { terms: ["todo", "fixme", "xxx"], location: "anywhere" },
      ],
      "no-duplicate-imports": "error",
      "max-lines": [
        "error",
        { max: 600, skipBlankLines: false, skipComments: false },
      ],
      "@typescript-eslint/no-explicit-any": "error",
      "@typescript-eslint/no-non-null-assertion": "error",
      "@typescript-eslint/ban-ts-comment": [
        "error",
        {
          "ts-expect-error": "allow-with-description",
          "ts-ignore": true,
          "ts-nocheck": true,
          "ts-check": false,
        },
      ],
      "@typescript-eslint/no-floating-promises": "error",
      "@typescript-eslint/no-misused-promises": [
        "error",
        { checksVoidReturn: { attributes: false } },
      ],
      "@typescript-eslint/consistent-type-imports": [
        "error",
        { prefer: "type-imports", fixStyle: "inline-type-imports" },
      ],
      "@typescript-eslint/explicit-function-return-type": "error",
      // Playwright strict anti-flakiness
      "playwright/no-conditional-in-test": "error",
      "playwright/no-element-handle": "error",
      "playwright/no-focused-test": "error",
      "playwright/no-standalone-expect": "error",
      "playwright/no-skipped-test": "error",
      "playwright/no-useless-not": "error",
      "playwright/prefer-comparison-matcher": "error",
      "playwright/prefer-locator": "error",
      "playwright/prefer-to-have-length": "error",
      "playwright/expect-expect": [
        "error",
        { assertFunctionNames: ["expect", "checkA11y"] },
      ],
      "playwright/missing-playwright-await": "error",
      "playwright/no-networkidle": "error",
      "playwright/no-wait-for-timeout": "error",
      "playwright/no-page-pause": "error",
    },
  },
]);
