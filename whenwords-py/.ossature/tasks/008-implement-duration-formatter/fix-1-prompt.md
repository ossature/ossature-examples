<error_output>
```
[Errno 2] No such file or directory: 'src/whenwords/duration.py'
```
</error_output>

<verify_command>
python -m py_compile src/whenwords/duration.py
</verify_command>

<task>
**Implement Duration Formatter**: Implement the core duration formatting logic in duration.py. Handles positive numbers of seconds, conversion, plurals, verbose and compact styles, max_units truncation, negative/NaN/Inf validations, and unit cascade rules (e.g. 12 months -> 1 year). For the rounding of the smallest displayed unit and cascade rules, follow standard half-up comparison.
</task>