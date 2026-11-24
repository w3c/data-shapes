"""Generate compact JSON-LD fragments with Kurra and PyLD.

Requires ``kurra`` on PATH and the ``PyLD`` Python package. Run from any working
directory, optionally passing filenames relative to this examples directory.
The fragments omit the shared context and outer graph wrapper. Source Turtle
files are left unchanged.
"""

import argparse
import json
import re
import subprocess
from pathlib import Path
from tempfile import TemporaryDirectory

from pyld import jsonld

# Keep this in sync with the JSON-LD context in index.html.
CONTEXT = {
    "dcterms": "http://purl.org/dc/terms/",
    "ex": "http://example.com/ns#",
    "owl": "http://www.w3.org/2002/07/owl#",
    "prof": "http://www.w3.org/ns/dx/prof/",
    "prov": "http://www.w3.org/ns/prov#",
    "rdf": "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
    "rdfs": "http://www.w3.org/2000/01/rdf-schema#",
    "role": "http://www.w3.org/ns/dx/prof/role/",
    "sh": "http://www.w3.org/ns/shacl#",
    "xsd": "http://www.w3.org/2001/XMLSchema#",
}
PREFIXES = "".join(f"PREFIX {prefix}: <{iri}>\n" for prefix, iri in CONTEXT.items())
# Additional Turtle defaults used by the Prez example; these are not part of
# the shared JSON-LD context, so their IRIs remain expanded in the output.
PREFIXES += """\
PREFIX schema: <https://schema.org/>
PREFIX shext: <http://example.com/shacl-extension#>
"""

# These files illustrate query syntax, despite their .ttl suffix.
SPARQL_EXAMPLES = {"conv-sparql.ttl", "conv-sparql-rl.ttl"}


def compact_fragment(document: dict | list) -> str:
    """Compact JSON-LD and omit only its context and outer graph wrapper."""
    compacted = jsonld.compact(document, {"@context": CONTEXT})
    compacted.pop("@context", None)
    if set(compacted) == {"@graph"}:
        nodes = compacted["@graph"]
    else:
        nodes = [compacted] if compacted else []
    fragment = ",\n".join(
        json.dumps(node, ensure_ascii=False, indent=2) for node in nodes
    )
    return fragment + "\n" if fragment else ""


def main() -> None:
    """Convert selected RDF examples, or all examples when none are specified."""
    examples = Path(__file__).resolve().parent
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "sources",
        nargs="*",
        type=Path,
        help="Turtle filenames relative to the examples directory (default: all)",
    )
    args = parser.parse_args()
    sources = sorted(
        {(examples / source).resolve() for source in args.sources}
        if args.sources
        else examples.rglob("*.ttl")
    )
    for source in sources:
        if (
            not source.is_relative_to(examples)
            or source.suffix != ".ttl"
            or not source.is_file()
        ):
            parser.error(f"Expected a Turtle file within {examples}: {source}")
    converted = 0
    with TemporaryDirectory(prefix="shacl-jsonld-") as temporary:
        merged = Path(temporary) / "merged.ttl"
        expanded = Path(temporary) / "expanded.jsonld"
        for source in sources:
            if source.name == "_prefixes.ttl":
                print(f"Skipped {source.name}: prefix declarations, not an RDF example")
                continue
            if source.parent == examples and source.name in SPARQL_EXAMPLES:
                print(f"Skipped {source.name}: SPARQL syntax, not RDF")
                continue
            # Resolve relative IRIs against the published example location,
            # rather than leaking a temporary or local filesystem path.
            base = (
                "https://www.w3.org/TR/shacl12-profiling/examples/"
                + source.relative_to(examples).as_posix()
            )
            # Escape literal newlines: Kurra otherwise strips blank lines
            # inside multiline strings before parsing Turtle.
            content = re.sub(
                r'"""(?:\\.|(?!""").)*"""|\'\'\'(?:\\.|(?!\'\'\').)*\'\'\'',
                lambda match: match[0].replace("\n", r"\n"),
                source.read_text(encoding="utf-8"),
                flags=re.DOTALL,
            )
            merged.write_text(
                f"BASE <{base}>\n" + PREFIXES + "\n" + content,
                encoding="utf-8",
            )
            destination = source.with_suffix(".jsonld")
            subprocess.run(
                [
                    "kurra",
                    "file",
                    "reformat",
                    str(merged),
                    "--output-format",
                    "json-ld",
                    "--output-filename",
                    str(expanded),
                ],
                check=True,
            )
            fragment = compact_fragment(
                json.loads(expanded.read_text(encoding="utf-8"))
            )
            destination.write_text(fragment, encoding="utf-8")
            converted += 1
            print(f"Created {destination.relative_to(examples)}")
    print(f"Converted {converted} RDF files")


if __name__ == "__main__":
    main()
