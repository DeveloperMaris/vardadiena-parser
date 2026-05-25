# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Run

The repository has no build, lint, or test setup — it is a single standalone Python script (`namedays_parser.py`) with no third-party dependencies. Python 3.12.2 is pinned via `.python-version` (README states Python 3.6 minimum).

Run against the bundled CSVs:

```console
python3 namedays_parser.py "input/tradic_vardadienu_saraksts.csv" "input/paplasinatais_saraksts.csv"
```

Output is written to `output/namedays.json` (directory is created if missing).

## Architecture

The script transforms two comma-delimited CSVs from [Valsts valodas centrs](https://www.vvc.gov.lv/lv/kalendarvardu-ekspertu-komisija) into a flat JSON list. Three-stage pipeline in `namedays_parser.py`:

1. `parse_csv` reads each file into `{day, month, names[]}` records. Date column is formatted like `22.05.` (trailing period stripped before splitting on `.`). Names are whitespace-split, with periods and commas stripped, but em dashes (`–`) are preserved as placeholders for "no name."
2. `combine_namedays` joins the traditional list (`namedays`) with the extended list (`namedays_extended`) by `(day, month)`. Each traditional name becomes an entry with `is_additional_calendar_name: false`; names that appear only in the extended file for the same date become entries with `is_additional_calendar_name: true`. Em-dash placeholders are converted to empty strings at this stage.
3. `merge_with_previous` reads the existing `output/namedays.json` (if any), unions it with the freshly computed snapshot by `(month, day, name)`, and sets the `removed` field on each entry (see below). The final list is sorted by `(month, day, is_additional_calendar_name, name)` so source updates produce stable, diff-friendly output.

Output schema (one row per name, not per date):

```
{ "month": Int, "day": Int, "name": String, "is_additional_calendar_name": Bool, "removed": String|null }
```

### `removed` semantics

`removed` records when a name disappears from the source files so callers can distinguish "name no longer in the calendar" from "name was never there." Rules, applied per `(month, day, name)`:

- Name in the current source → `removed: null`. If a previous run had it marked removed, the field is cleared on the next run.
- Name in the previous output but missing from the current source → `removed` set to the current UTC timestamp (`datetime.now(timezone.utc).isoformat()`).
- Name already had a `removed` timestamp and is still missing → the original timestamp is preserved (do not refresh on every run). This is what makes the field meaningful as "when last seen."

The identity key is `(month, day, name)` — independent of `is_additional_calendar_name`. The flag stored on a removed entry is the last-known value from the source.

### Special case: May 22

May 22 in the source CSV contains the literal phrase `"Visu neparasto un kalendāros neierakstīto vārdu diena"` ("Day of all unusual names not written in calendars") alongside actual names. The parser detects `day == 22 and month == 5`, strips that phrase before the whitespace split (so it isn't shredded into per-word "names"), then re-appends it as a single trailing entry. Preserve this branch when editing `parse_csv`.

### Known parser artifact

The extended source uses parenthetical Latgalian dialect annotations like `Borbala (LTG: Buorbala)`. The whitespace splitter shreds these into junk "names" (`(LTG:`, `Buorbala)`, etc.). The merge step's `(month, day, name)` dedup collapses repeated `(LTG:` fragments, but the junk fragments themselves still land in the output as standalone entries. Fixing this requires teaching `parse_csv` about the parenthetical syntax.

### Input file contract

CSVs must be `,`-delimited with a header row and exactly two columns (`date`, `names`). Rows with the wrong column count, empty date, or unparseable date are logged and skipped — they do not abort the run, but `main` does abort if either parsed dataset ends up empty.
