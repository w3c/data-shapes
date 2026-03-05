# SHACL UI

## Running locally

There are a few useful tasks defined in [Taskfile.yml](Taskfile.yml) to assist with making changes to the content of SHACL UI.

To install Taskfile, see [the Taskfile documentation](https://taskfile.dev).

For example, when updating RDF Turtle files for widget scores, you can run the [SHACL UI validation workflow](../.github/workflows/shacl-ui-validation.yml) to ensure it passes the validation tests.

Inside the `shacl12-ui/` directory, run:

```sh
task validate
```
