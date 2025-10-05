import sys
import re

def parse_src_uri(file_path):
    with open(file_path, "r") as f:
        content = f.read()

    matches = re.findall(r'SRC_URI\s*=\s*(?:"""|\'\'\'|"|\')(.+?)(?:"""|\'\'\'|"|\')', content, re.DOTALL)

    for match in matches:
        lines = [line.strip() for line in match.splitlines() if line.strip()]
        for line in lines:
            if '->' in line:
                src, dest = map(str.strip, line.split('->', 1))
            else:
                src, dest = line, ""
            # Output as pipe-separated values
            print(f"{src}|{dest}")

if __name__ == "__main__":
    parse_src_uri(sys.argv[1])

