#!/usr/bin/env python3

from typing import List

import json
import sys

def main(args: List[str]) -> int:
    if len(args) < 2:
        print("crush_db.py <database json file>")
        return 0

    data = []
    with open(args[1]) as f:
        for line in f:
            line_data = json.loads(line)
            data.append(line_data)

    packages = {}
    for entry in data:
        name = entry["package"]

        if name not in packages:
            packages[name] = []

        del entry["package"]

        if "description" in entry:
            entry["description"] = entry["description"].strip()
            if not entry["description"]:
                del entry["description"]  # delete empty descriptions

        packages[name].append(entry)

    print(json.dumps(packages, sort_keys=True, separators=(',', ':')))

    return 0

exit(main(sys.argv))
