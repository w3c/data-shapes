import sys
from rdflib import Graph

prefixes = open("_prefixes.ttl").read()
example_data = open(sys.argv[1]).read()

example_data = example_data.replace("&lt;", "<")

total = prefixes + "\n\n" + example_data

# print(total)
g = Graph().parse(data=total, format="turtle")
print("ok")