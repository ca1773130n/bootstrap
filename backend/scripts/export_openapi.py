#!/usr/bin/env python3
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

from main import app


def main() -> None:
    schema = app.openapi()
    output = Path(__file__).parent.parent.parent / "openapi.json"
    output.write_text(json.dumps(schema, indent=2))
    print(f"Exported OpenAPI schema to {output}")


if __name__ == "__main__":
    main()
