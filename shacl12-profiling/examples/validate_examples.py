from pathlib import Path
from kurra.file import merge
from kurra.shacl import validate
from rdflib import Graph

prefixes = open("_prefixes.ttl").read()

for f in sorted(Path(__file__).parent.glob("*.ttl")):
    if "_" not in f.name:
        g = Graph().parse(data=prefixes + "\n\n" + open(f).read())
        print(f"{f} OK")
