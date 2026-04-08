#!/usr/bin/env python3

from __future__ import annotations

import json
import sys
from pathlib import Path


ALLOWED_BUNDLES = {"lite", "balanced", "quality"}


def main() -> int:
    if len(sys.argv) != 2:
        raise SystemExit("usage: validate_model_manifest.py <path>")

    manifest_path = Path(sys.argv[1])
    data = json.loads(manifest_path.read_text(encoding="utf-8"))

    version = data.get("version")
    bundles = data.get("bundles")

    if not isinstance(version, str) or not version.strip():
        raise SystemExit("manifest version must be a non-empty string")

    if not isinstance(bundles, list) or not bundles:
        raise SystemExit("manifest bundles must be a non-empty list")

    unknown = [bundle for bundle in bundles if bundle not in ALLOWED_BUNDLES]
    if unknown:
        raise SystemExit(f"manifest contains unsupported bundles: {unknown}")

    print(f"validated manifest {manifest_path} ({version})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
