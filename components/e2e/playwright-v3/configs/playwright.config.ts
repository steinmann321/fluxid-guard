import { defineConfig, devices } from "@playwright/test";

export default defineConfig({
  testDir: "./tests",
  reporter: "list",
  timeout: 30000,
  workers: 1,
  fullyParallel: false,
  use: {
    baseURL: "http://localhost:5173",
    trace: "on-first-retry",
    video: "retain-on-failure",
    screenshot: "only-on-failure",
  },
  projects: [
    {
      name: "chromium",
      use: { ...devices["Desktop Chrome"] },
    },
    // Temporarily disable firefox and webkit to prevent SQLite concurrency issues
    // during invoice number generation. Re-enable after migrating to PostgreSQL.
    // {
    //   name: "firefox",
    //   use: { ...devices["Desktop Firefox"] },
    // },
    // {
    //   name: "webkit",
    //   use: { ...devices["Desktop Safari"] },
    // },
  ],
  webServer: [
    {
      command:
        "cd ../backend && .venv/bin/python manage.py seed_test_data && .venv/bin/python manage.py runserver 8000",
      url: "http://localhost:8000/api/health/",
      timeout: 120000,
      reuseExistingServer: true,
    },
    {
      command: "cd ../frontend && npm run dev",
      url: "http://localhost:5173",
      timeout: 120000,
      reuseExistingServer: true,
    },
  ],
});
