#!/usr/bin/env bash
set -euo pipefail

# Enforce migration-based fixtures for Django.
# Blocks commits containing JSON fixtures, requiring data migrations instead.

# Get all staged files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null || true)

if [ -z "$STAGED_FILES" ]; then
    exit 0
fi

# Check for JSON fixture files in backend
JSON_FIXTURES=$(echo "$STAGED_FILES" | grep -E '^backend/.*/fixtures/.*\.json$' || true)

if [ -n "$JSON_FIXTURES" ]; then
    echo ""
    echo "❌ JSON fixtures detected:"
    echo ""
    echo "$JSON_FIXTURES" | sed 's/^/  /'
    echo ""
    echo "This project enforces migration-based fixtures."
    echo ""
    echo "Instead of JSON fixtures, create a data migration:"
    echo ""
    echo "  cd backend"
    echo "  python manage.py makemigrations <app_name> --empty --name load_initial_data"
    echo ""
    echo "Then implement the migration using Django's migration framework:"
    echo ""
    echo "  from django.db import migrations"
    echo ""
    echo "  def load_data(apps, schema_editor):"
    echo "      MyModel = apps.get_model('app_name', 'MyModel')"
    echo "      MyModel.objects.create(name='example', ...)"
    echo ""
    echo "  class Migration(migrations.Migration):"
    echo "      dependencies = [...]"
    echo "      operations = ["
    echo "          migrations.RunPython(load_data),"
    echo "      ]"
    echo ""
    echo "Benefits of data migrations:"
    echo "  ✓ Type-safe and refactor-friendly"
    echo "  ✓ Version controlled with schema changes"
    echo "  ✓ Can use Django ORM"
    echo "  ✓ Better for complex relationships"
    echo ""
    echo "Documentation:"
    echo "  https://docs.djangoproject.com/en/stable/topics/migrations/#data-migrations"
    echo ""
    exit 1
fi

exit 0
