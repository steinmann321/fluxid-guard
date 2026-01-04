/** @type {import('dependency-cruiser').IConfiguration} */
module.exports = {
  forbidden: [
    { name: 'not-to-unresolvable', severity: 'error', from: {}, to: { couldNotResolve: true } },
    { name: 'no-circular', severity: 'error', from: {}, to: { circular: true } },
    { name: 'no-orphans', severity: 'error', from: { orphan: true, path: '^src', pathNot: '/types\\.ts$' }, to: {} },
    {
      name: 'not-to-dev-dep',
      severity: 'error',
      from: { pathNot: '(\\.(spec|test)\\.(ts|tsx)$|^src/test/|-env\\.d\\.ts$|test-helpers\\.ts$)' },
      to: { dependencyTypes: ['npm-dev'] },
    },
    { name: 'no-deprecated', severity: 'error', from: {}, to: { dependencyTypes: ['deprecated'] } },
  ],
  options: {
    doNotFollow: { path: 'node_modules' },
    tsConfig: { fileName: './tsconfig.app.json' },
    enhancedResolveOptions: {
      exportsFields: ['exports'],
      conditionNames: ['import', 'require', 'node', 'default'],
    },
    reporterOptions: {},
  },
};
