from pathlib import Path
from rdflib import Graph

prefixes = open("_prefixes.ttl").read()

for f in sorted(Path(__file__).parent.glob("*.ttl")):
    if "_" not in f.name:
        d = prefixes + "\n\n" + open(f).read()
        g = Graph().parse(data=d)
        print(f"{f} OK")
