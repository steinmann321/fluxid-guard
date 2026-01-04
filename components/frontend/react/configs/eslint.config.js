import js from '@eslint/js';
import jsxA11y from 'eslint-plugin-jsx-a11y';
import react from 'eslint-plugin-react';
import reactHooks from 'eslint-plugin-react-hooks';
import reactRefresh from 'eslint-plugin-react-refresh';
import unicorn from 'eslint-plugin-unicorn';
import globals from 'globals';
import tseslint from 'typescript-eslint';
import boundaries from 'eslint-plugin-boundaries';
import importPlugin from 'eslint-plugin-import';
import promise from 'eslint-plugin-promise';
import regexp from 'eslint-plugin-regexp';
import { defineConfig, globalIgnores } from 'eslint/config';

export default defineConfig([
  globalIgnores(['dist', 'node_modules', 'coverage', '**/coverage/**', 'frontend/coverage/**']),
  {
    files: ['**/*.{ts,tsx}'],
    extends: [
      js.configs.recommended,
      tseslint.configs.recommended,
      reactHooks.configs.flat.recommended,
      reactRefresh.configs.vite,
    ],
    plugins: {
      react,
      'jsx-a11y': jsxA11y,
      unicorn,
      promise,
      import: importPlugin,
      regexp,
      boundaries,
    },
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: 'module',
      globals: globals.browser,
      parserOptions: { projectService: true, tsconfigRootDir: process.cwd() },
    },
    rules: {
      'no-console': 'error',
      eqeqeq: ['error', 'always'],
      curly: ['error', 'all'],
      'no-implicit-coercion': 'error',
      'no-warning-comments': ['error', { terms: ['todo', 'fixme', 'xxx'], location: 'anywhere' }],
      'no-duplicate-imports': 'error',
      complexity: ['error', { max: 10 }],
      'max-depth': ['error', 3],
      'max-nested-callbacks': ['error', 3],
      'max-lines-per-function': ['error', { max: 75, skipBlankLines: false, skipComments: false }],
      'max-params': ['error', 4],
      'max-statements': ['error', 25],
      'react/jsx-boolean-value': ['error', 'always'],
      'react/jsx-key': 'error',
      'react/no-danger': 'error',
      'react/no-array-index-key': 'error',
      'react/jsx-no-useless-fragment': 'error',
      '@typescript-eslint/no-explicit-any': 'error',
      '@typescript-eslint/no-non-null-assertion': 'error',
      '@typescript-eslint/ban-ts-comment': [
        'error',
        {
          'ts-expect-error': 'allow-with-description',
          'ts-ignore': true,
          'ts-nocheck': true,
          'ts-check': false,
        },
      ],
      '@typescript-eslint/no-floating-promises': 'error',
      '@typescript-eslint/no-misused-promises': [
        'error',
        { checksVoidReturn: { attributes: false } },
      ],
      '@typescript-eslint/consistent-type-imports': [
        'error',
        { prefer: 'type-imports', fixStyle: 'inline-type-imports' },
      ],
      '@typescript-eslint/array-type': ['error', { default: 'array-simple' }],
      '@typescript-eslint/explicit-function-return-type': 'error',
      'promise/no-return-wrap': 'error',
      'promise/param-names': 'error',
      'import/no-default-export': 'error',
      'import/no-extraneous-dependencies': ['error', { devDependencies: false }],
      'unicorn/prefer-node-protocol': 'error',
      'unicorn/prefer-switch': 'error',
      'unicorn/no-null': 'error',
      'regexp/no-dupe-characters-character-class': 'error',
      'regexp/no-unused-capturing-group': 'error',
      'boundaries/entry-point': ['error', { default: 'allow' }],
      'boundaries/no-unknown': 'error',
      'boundaries/no-ignored': 'error',
    },
    settings: {
      react: { version: 'detect' },
      'boundaries/elements': [
        { type: 'app', pattern: '^src/app' },
        { type: 'features', pattern: '^src/features' },
        { type: 'shared', pattern: '^src/shared' },
      ],
      'boundaries/ignore': ['**/*.test.ts', '**/*.test.tsx', '**/*.spec.ts', '**/*.spec.tsx'],
    },
  },
  {
    files: ['vite.config.ts', 'vitest.config.ts', 'eslint.config.js'],
    plugins: {
      import: importPlugin,
    },
    rules: {
      'import/no-default-export': 'off',
      'import/no-extraneous-dependencies': ['error', { devDependencies: true }],
    },
  },
  {
    files: ['**/*.test.{ts,tsx}', '**/*.spec.{ts,tsx}', 'src/test/**/*.{ts,tsx}', '**/*-env.d.ts', '**/*test-utils.{ts,tsx}', '**/*test-helpers.{ts,tsx}'],
    plugins: {
      import: importPlugin,
    },
    rules: {
      'import/no-extraneous-dependencies': ['error', { devDependencies: true }],
      'max-lines-per-function': ['error', { max: 150, skipBlankLines: false, skipComments: false }],
    },
  },
]);
