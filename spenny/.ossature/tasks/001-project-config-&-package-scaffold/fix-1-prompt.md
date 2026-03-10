<error_output>
```
warning: The `tool.uv.dev-dependencies` field (used in `pyproject.toml`) is deprecated and will be removed in a future release; use `dependency-groups.dev` instead
warning: `VIRTUAL_ENV=/Users/beshr/src/code/ossature/.venv` does not match the project environment path `.venv` and will be ignored; use `--active` to target the active environment instead
Using CPython 3.14.3 interpreter at: /opt/homebrew/opt/python@3.14/bin/python3.14
Creating virtual environment at: .venv
   Building spenny @ file:///Users/beshr/src/code/ossature-examples/spenny/output
  × Failed to build `spenny @ file:///Users/beshr/src/code/ossature-examples/spenny/output`
  ├─▶ The build backend returned an error
  ╰─▶ Call to `hatchling.build.build_editable` failed (exit status: 1)

      [stderr]
      Traceback (most recent call last):
        File "<string>", line 11, in <module>
          wheel_filename =
      backend.build_editable("/Users/beshr/.cache/uv/builds-v0/.tmpx9XBHK", {}, None)
        File
      "/Users/beshr/.cache/uv/builds-v0/.tmp3s8epd/lib/python3.14/site-packages/hatchling/build.py",
      line 83, in build_editable
          return os.path.basename(next(builder.build(directory=wheel_directory,
      versions=["editable"])))
      
      ~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        File
      "/Users/beshr/.cache/uv/builds-v0/.tmp3s8epd/lib/python3.14/site-packages/hatchling/builders/plugin/interface.py",
      line 92, in build
          self.metadata.validate_fields()
          ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^^
        File
      "/Users/beshr/.cache/uv/builds-v0/.tmp3s8epd/lib/python3.14/site-packages/hatchling/metadata/core.py",
      line 266, in validate_fields
          self.core.validate_fields()
          ~~~~~~~~~~~~~~~~~~~~~~~~~^^
        File
      "/Users/beshr/.cache/uv/builds-v0/.tmp3s8epd/lib/python3.14/site-packages/hatchling/metadata/core.py",
      line 1366, in validate_fields
          getattr(self, attribute)
          ~~~~~~~^^^^^^^^^^^^^^^^^
        File
      "/Users/beshr/.cache/uv/builds-v0/.tmp3s8epd/lib/python3.14/site-packages/hatchling/metadata/core.py",
      line 531, in readme
          raise OSError(message)
      OSError: Readme file does not exist: README.md

      hint: This usually indicates a problem with the package or the build environment.
```
</error_output>

<verify_command>
uv run python -c 'import spenny'
</verify_command>

<current_file path="pyproject.toml">
```
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "spenny"
version = "0.1.0"
description = "A command-line expense tracker"
readme = "README.md"
requires-python = ">=3.14"
license = "MIT"
keywords = ["expense", "tracker", "cli"]
authors = [{ name = "Author", email = "author@example.com" }]
classifiers = [
    "Programming Language :: Python :: 3",
    "License :: OSI Approved :: MIT License",
    "Operating System :: OS Independent",
]

[project.scripts]
spenny = "spenny.cli:main"

[tool.uv]
dev-dependencies = []

```
</current_file>

<current_file path="src/spenny/__init__.py">
```
# Package marker for spenny
"""Spenny is a command-line expense tracker."""

```
</current_file>

<task>
**Project Config & Package Scaffold**: Create pyproject.toml with project metadata, dependencies, and the spenny entry point. Also create the src/spenny/__init__.py package marker. This establishes the installable package structure under uv.
</task>