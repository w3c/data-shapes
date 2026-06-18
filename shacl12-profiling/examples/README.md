# Examples

This directory contains example files in pseudo-Turtle format used within the Profiling HTML document.

All examples are included using ReSpect commands like this:

`<div class="turtle" data-include="examples/defining-profiles-of-shacl.ttl"></div>`

## Validation

To validate an example you will need Python installed and the [rdflib](https://pypi.org/project/rdflib/) package installed. You cna then run `validate.py` with any example file as an argument, e.g.:

```bash
python check-rdf.py 01.ttl
```

The script will print "OK" if there are no syntax errors or else an error message.
