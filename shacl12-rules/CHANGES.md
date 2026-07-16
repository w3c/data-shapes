# SHACL 1.2. Rules — CHANGES

This document records major changes and new material that would be of interest to
implementers.

It is not a comprehensive list of changes to the specification.

This file is temporary while the specification is in-development — it is not
intended for publication.


## 2026-07-16
Removed sections of at-risk abbreviation (grammar change) and at-risk tuples.

## 2026-07-07
Grammar: add NOT DATA and WHERE DATA in preparation for grounded patterns
(GH-960 Default triples)

## 2026-07-07
Rewrite of the SRL grammar so that the three areas (data, head templates and
body patterns) each have specific syntax productions.

  Data blocks do not variables, and do not have paths.
  Head templates have variables, but do not have paths.
  Body patterns have variables and paths.

## 2026-07-01 Start change log
