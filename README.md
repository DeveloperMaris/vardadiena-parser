# Vārdadiena Parser

A script that reads and parses Latvian [name days](https://en.wikipedia.org/wiki/Name_day) into JSON file format.

This Python script:
1. reads two `csv` files containing the traditional and extended name day lists,
1. combines them into a flat, one-row-per-name data format,
1. merges the result with the previous output, tracking when names disappear from the source (see [The `removed` field](#the-removed-field)),
1. writes the content into a `json` file.

Source files can be found here:
* [Kalendārvārdu ekspertu komisija](https://www.vvc.gov.lv/lv/kalendarvardu-ekspertu-komisija)
* [Latviešu tradicionālo vārdadienu saraksts](https://www.vvc.gov.lv/lv/media/157/download?attachment)
* [Paplašinātais vārdadienu saraksts](https://www.vvc.gov.lv/lv/media/156/download?attachment)

_These files are provided and maintained by the [Valsts valodas centrs](https://www.vvc.gov.lv/lv)._

## Requirements

* Minimum Python version: Python 3.7 (uses `datetime.fromisoformat`)
* Development is pinned to Python 3.12.2 via `.python-version`
* No third-party dependencies

## Run

Execute the Terminal command inside the root directory of this project.

As parameters, provide the paths to the "namedays.csv" and "namedays_extended.csv" files.

```console
python3 namedays_parser.py "input/tradic_vardadienu_saraksts.csv" "input/paplasinatais_saraksts.csv"
```

## Output 

Script parses 2 provided `csv` files and generates a `json` file in `output` directory:

[namedays.json](./output/namedays.json)

File contains names which are included in the calendar and all additional names 
which are not included in the calendar in a pretty json format.

### JSON structure

```
[
    {
        "month": Int,                        # Value between 1 - 12.
        "day": Int,                          # Value between 1 - 31.
        "name": String,                      # Name. If the date has no name, it is represented as an empty string.
        "is_additional_calendar_name": Bool, # Provides information if this name is an additional calendar name.
        "removed": Int|null                  # Unix timestamp when the name disappeared from the source, or null if still present.
    },
    ...
]
```

The list contains one entry per name (not per date) and is sorted by `(month, day, is_additional_calendar_name, name)` so that source updates produce stable, diff-friendly output.

### The `removed` field

Each run merges the freshly parsed data with the previous `output/namedays.json`, identifying entries by `(month, day, name)`. This lets callers tell "name no longer in the calendar" apart from "name was never there":

* Name present in the current source → `removed` is `null`. If a previous run had marked it removed, the field is cleared.
* Name in the previous output but missing from the current source → `removed` is set to the current Unix timestamp (integer seconds since 1970-01-01 UTC, which `Date(timeIntervalSince1970:)` consumes directly in Swift).
* A name that already has a `removed` timestamp and is still missing keeps its original timestamp, so the value reflects when the name was last seen.

## Licence

`vardadiena-parser` is released under the MIT License. See [LICENSE](LICENSE) for details.
