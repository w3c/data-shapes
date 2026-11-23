"""Generate JSON-LD examples with Kurra; run from any working directory.

Requires ``kurra`` on PATH. Source Turtle files are left unchanged.
"""

import re
import subprocess
from pathlib import Path
from tempfile import TemporaryDirectory

PREFIXES = """\
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX ex: <http://example.com/ns#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX prof: <http://www.w3.org/ns/dx/prof/>
PREFIX prov: <http://www.w3.org/ns/prov#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX role: <http://www.w3.org/ns/dx/prof/role/>
PREFIX sh: <http://www.w3.org/ns/shacl#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
"""

# These files illustrate query syntax, despite their .ttl suffix.
SPARQL_EXAMPLES = {"conv-sparql.ttl", "conv-sparql-rl.ttl"}


def main() -> None:
    """Convert every RDF example, including files in subdirectories."""
    examples = Path(__file__).resolve().parent
    converted = 0
    with TemporaryDirectory(prefix="shacl-jsonld-") as temporary:
        merged = Path(temporary) / "merged.ttl"
        for source in sorted(examples.rglob("*.ttl")):
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
                    str(destination),
                ],
                check=True,
            )
            converted += 1
            print(f"Created {destination.relative_to(examples)}")
    print(f"Converted {converted} RDF files")


if __name__ == "__main__":
    main()
