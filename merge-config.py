#!/usr/bin/env python3
"""
Configuration Merger Utility
Merges TOML and JSON configuration files safely without overwriting existing values.
"""

import argparse
import json
import sys
from pathlib import Path
from typing import Any, Dict


def merge_dicts(base: Dict[str, Any], additions: Dict[str, Any]) -> Dict[str, Any]:
    """
    Recursively merge two dictionaries.
    - For nested dicts: merge recursively
    - For lists: extend with new items (no duplicates)
    - For primitives: keep base value if exists, otherwise use addition
    """
    result = base.copy()

    for key, value in additions.items():
        if key not in result:
            result[key] = value
        elif isinstance(value, dict) and isinstance(result[key], dict):
            result[key] = merge_dicts(result[key], value)
        elif isinstance(value, list) and isinstance(result[key], list):
            # Extend list with new items, avoiding duplicates
            for item in value:
                if item not in result[key]:
                    result[key].append(item)
        # If key exists and is not dict/list, keep base value (don't overwrite)

    return result


def merge_json(base_file: Path, additions_file: Path, output_file: Path) -> None:
    """Merge JSON files (typically package.json)."""
    try:
        with open(base_file, 'r') as f:
            base = json.load(f)
    except FileNotFoundError:
        print(f"Warning: Base file {base_file} not found, using additions only")
        base = {}

    with open(additions_file, 'r') as f:
        additions = json.load(f)

    merged = merge_dicts(base, additions)

    with open(output_file, 'w') as f:
        json.dump(merged, f, indent=2)
        f.write('\n')  # Add trailing newline

    print(f"✓ Merged {base_file.name} + {additions_file.name} → {output_file}")


def merge_toml(base_file: Path, additions_file: Path, output_file: Path) -> None:
    """Merge TOML files (typically pyproject.toml)."""
    try:
        import tomllib
    except ImportError:
        try:
            import tomli as tomllib
        except ImportError:
            print("Error: tomllib/tomli not available. Install tomli: pip install tomli")
            sys.exit(1)

    try:
        import tomli_w
    except ImportError:
        print("Error: tomli_w not available. Install it: pip install tomli_w")
        sys.exit(1)

    try:
        with open(base_file, 'rb') as f:
            base = tomllib.load(f)
    except FileNotFoundError:
        print(f"Warning: Base file {base_file} not found, using additions only")
        base = {}

    with open(additions_file, 'rb') as f:
        additions = tomllib.load(f)

    merged = merge_dicts(base, additions)

    with open(output_file, 'wb') as f:
        tomli_w.dump(merged, f)

    print(f"✓ Merged {base_file.name} + {additions_file.name} → {output_file}")


def main():
    parser = argparse.ArgumentParser(
        description="Merge configuration files (JSON or TOML) safely"
    )
    parser.add_argument(
        "base",
        type=Path,
        help="Base configuration file to merge into"
    )
    parser.add_argument(
        "additions",
        type=Path,
        help="Additions file containing new configuration"
    )
    parser.add_argument(
        "-o", "--output",
        type=Path,
        help="Output file (defaults to overwriting base file)"
    )
    parser.add_argument(
        "-t", "--type",
        choices=["json", "toml", "auto"],
        default="auto",
        help="File type to merge (default: auto-detect from extension)"
    )

    args = parser.parse_args()

    # Determine file type
    if args.type == "auto":
        ext = args.base.suffix.lower()
        if ext == ".json":
            file_type = "json"
        elif ext == ".toml":
            file_type = "toml"
        else:
            print(f"Error: Cannot auto-detect type from extension '{ext}'")
            print("Please specify --type json or --type toml")
            sys.exit(1)
    else:
        file_type = args.type

    # Determine output file
    output = args.output or args.base

    # Perform merge
    try:
        if file_type == "json":
            merge_json(args.base, args.additions, output)
        else:
            merge_toml(args.base, args.additions, output)
    except Exception as e:
        print(f"Error during merge: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
