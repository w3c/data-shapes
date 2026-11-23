"""Regenerate profiling JSON-LD snippets; run from any working directory.

Requires Kurra 3.2.1 on PATH, or --kurra PATH, and its PyLD dependency. Shared prefixes are merged only
into temporary inputs. Outputs omit @context and @graph wrappers and are meant
to be read with _prefixes.jsonld. Embedded SPARQL prefix declarations are kept.
"""

import argparse
import json
import re
import subprocess
from pathlib import Path
from tempfile import TemporaryDirectory

from pyld import jsonld

EXAMPLES = Path(__file__).resolve().parent
ROOT = EXAMPLES.parent
DIRECTORIES = ("alignments", "conventions", "examples", "null-profiles")
PREFIX_FILE = EXAMPLES / "_prefixes.ttl"
CONTEXT_FILE = EXAMPLES / "_prefixes.jsonld"
SPARQL_EXAMPLES = {"conv-sparql.ttl", "conv-sparql-rl.ttl"}

# Protect strings, comments and IRIs when recognizing real Turtle directives.
TOKENS = re.compile(
    r"(?P<prefix>^[ \t]*(?:@prefix|PREFIX)[ \t]+"
    r"(?P<name>[A-Za-z_][\w.-]*|):[ \t]*<(?P<namespace>[^>\r\n]*)>"
    r"[ \t]*\.?[ \t]*(?:\r?\n)?)"
    r'|(?P<string>"""(?:\\.|(?!""").)*"""|\'\'\'(?:\\.|(?!\'\'\').)*\'\'\''
    r'|"(?:\\.|[^"\\\r\n])*"|\'(?:\\.|[^\'\\\r\n])*\')'
    r"|(?P<comment>\#[^\r\n]*)|(?P<iri><[^<>\r\n]*>)",
    re.MULTILINE | re.DOTALL,
)


def prefix_mappings(content: str) -> dict[str, str]:
    """Read declarations outside strings and comments."""
    return {
        match["name"]: match["namespace"]
        for match in TOKENS.finditer(content)
        if match["prefix"] is not None
    }


def strip_shared_prefixes(content: str, shared: dict[str, str]) -> str:
    """Remove shared declarations, preserving prefixes inside literal strings."""

    def replace(match: re.Match[str]) -> str:
        if match["prefix"] is not None and match["name"] in shared:
            if shared[match["name"]] != match["namespace"]:
                raise ValueError(f"Conflicting shared prefix: {match['name']}:")
            return ""
        return match[0]

    return TOKENS.sub(replace, content).lstrip("\r\n")


def protect_multiline_literals(content: str) -> str:
    """Protect literal blank lines from Kurra's line-oriented input cleanup."""

    def replace(match: re.Match[str]) -> str:
        if match["string"] is not None:
            return match[0].replace("\r", r"\r").replace("\n", r"\n")
        return match[0]

    return TOKENS.sub(replace, content)


def run_kurra(executable: str, *arguments: str) -> None:
    """Require successful formatting/conversion."""
    subprocess.run([executable, "file", "reformat", *arguments], check=True)


def snippet(document: dict) -> dict | list:
    """Extract graph contents, including the single-node compaction case."""
    if "@graph" in document:
        return document["@graph"]
    return {key: value for key, value in document.items() if key != "@context"}


def main() -> None:
    """Stage all conversions successfully before writing repository files."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--kurra", default="kurra", help="Kurra 3.2.1 executable")
    args = parser.parse_args()
    version = subprocess.run(
        [args.kurra, "--version"], check=True, capture_output=True, text=True
    ).stdout.strip()
    if version != "3.2.1":
        parser.error(f"Kurra 3.2.1 is required; found {version!r}")
    prefixes = PREFIX_FILE.read_text(encoding="utf-8")
    shared = prefix_mappings(prefixes)
    context = json.loads(CONTEXT_FILE.read_text(encoding="utf-8"))
    mappings = context.get("@context", context)
    for name, namespace in shared.items():
        if mappings.get(name) != namespace:
            raise ValueError(f"Shared Turtle and JSON-LD prefixes disagree: {name}")

    staged: dict[Path, str] = {}
    converted = created = cleaned = 0
    with TemporaryDirectory(prefix="shacl-jsonld-") as temporary:
        merged = Path(temporary) / "merged.ttl"
        formatted = Path(temporary) / "formatted.ttl"
        output = Path(temporary) / "compacted.jsonld"
        canonical = Path(temporary) / "canonical.jsonld"
        for directory in DIRECTORIES:
            for source in sorted((ROOT / directory).rglob("*.ttl")):
                if source == PREFIX_FILE or source.name in SPARQL_EXAMPLES:
                    continue
                original = source.read_text(encoding="utf-8")
                body = strip_shared_prefixes(original, shared)
                # Relative IRIs belong to the published source location.
                base = (
                    "https://www.w3.org/TR/shacl12-profiling/"
                    + source.relative_to(ROOT).as_posix()
                )
                merged.write_text(
                    f"BASE <{base}>\n{prefixes}\n" + protect_multiline_literals(body),
                    encoding="utf-8",
                )
                if body != original:
                    # Format a complete temporary Turtle graph, then strip its
                    # shared declarations to produce the prefix-free snippet.
                    run_kurra(args.kurra, str(merged), "-o", str(formatted))
                    staged[source] = strip_shared_prefixes(
                        formatted.read_text(encoding="utf-8"), shared
                    )
                    cleaned += 1
                run_kurra(
                    args.kurra,
                    str(merged),
                    "-f",
                    "json-ld",
                    "-t",
                    str(CONTEXT_FILE),
                    "-o",
                    str(output),
                )
                document = json.loads(output.read_text(encoding="utf-8"))
                # RDF graph iteration order and anonymous-node IDs vary between
                # runs. Normalize them before the final Kurra compaction so
                # repeated conversions do not create meaningless file changes.
                normalized = jsonld.normalize(
                    document,
                    {"algorithm": "URDNA2015", "format": "application/n-quads"},
                )
                canonical.write_text(
                    json.dumps(jsonld.from_rdf(normalized)), encoding="utf-8"
                )
                run_kurra(
                    args.kurra,
                    str(canonical),
                    "-f",
                    "json-ld",
                    "-t",
                    str(CONTEXT_FILE),
                    "-o",
                    str(output),
                )
                document = json.loads(output.read_text(encoding="utf-8"))
                destination = source.with_suffix(".jsonld")
                created += not destination.exists()
                staged[destination] = (
                    json.dumps(snippet(document), ensure_ascii=False, indent=4) + "\n"
                )
                converted += 1
                print(f"Converted {source.relative_to(ROOT)}")
        for destination, content in staged.items():
            if (
                not destination.exists()
                or destination.read_text(encoding="utf-8") != content
            ):
                destination.write_text(content, encoding="utf-8")
    print(
        f"Generated {converted} JSON-LD snippets ({created} new); "
        f"removed shared prefix declarations from {cleaned} Turtle files."
    )


if __name__ == "__main__":
    main()
