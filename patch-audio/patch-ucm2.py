#!/usr/bin/env python3
import sys
import re

# ANSI color codes for formatting
GREEN = '\033[0;32m'
RED = '\033[0;31m'
YELLOW = '\033[1;33m'
CYAN = '\033[1;36m'
NC = '\033[0m' # No Color

def main():
    if len(sys.argv) < 2:
        print(f"{RED}[-] Error: No UCM file path provided.{NC}")
        sys.exit(1)

    path = sys.argv[1]
    try:
        with open(path, "r") as f:
            content = f.read()
    except FileNotFoundError:
        print(f"{RED}[-] Error: File not found at {path}{NC}")
        sys.exit(1)

    # 1. Turn all switches off by default to eliminate startup feedback
    content = content.replace("cset \"name='Speaker Switch' on\"", "cset \"name='Speaker Switch' off\"")
    content = content.replace("cset \"name='Headphone Switch' on\"", "cset \"name='Headphone Switch' off\"")
    content = content.replace("cset \"name='Line Out Switch' on\"", "cset \"name='Line Out Switch' off\"")
    content = content.replace("cset \"name='Internal Mic Switch' on\"", "cset \"name='Internal Mic Switch' off\"")
    content = content.replace("cset \"name='Headset Mic Switch' on\"", "cset \"name='Headset Mic Switch' off\"")
    content = content.replace("cset \"name='Headset Mic 2 Switch' on\"", "cset \"name='Headset Mic 2 Switch' off\"")

    # 2. Inject 25% default volume into Speaker EnableSequence blocks
    pattern = re.compile(r'(SectionDevice\."Speaker"\s*\{\s*EnableSequence\s*\[\s*cset\s*"name=\'Speaker Switch\' (?:on|off)"\s*)\]', re.DOTALL)

    def add_volume(match):
        return match.group(1) + '\t\t\t\tcset "name=\'Speaker Playback Volume\' 25%"]'

    content, count = pattern.subn(add_volume, content)
    if count == 0:
        content = content.replace(
            'cset "name=\'Speaker Switch\' off"',
            'cset "name=\'Speaker Switch\' off"\n\t\t\t\tcset "name=\'Speaker Playback Volume\' 25%"'
        )

    try:
        with open(path, "w") as f:
            f.write(content)
        print(f"{GREEN}[+] Successfully updated UCM2 configuration defaults and volume.{NC}")
    except Exception as e:
        print(f"{RED}[-] Error writing to UCM file: {e}{NC}")
        sys.exit(1)

if __name__ == "__main__":
    main()