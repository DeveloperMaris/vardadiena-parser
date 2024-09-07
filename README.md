# Vārdadiena Parser

A script that requests and parses Latvian [name days](https://en.wikipedia.org/wiki/Name_day) into JSON file format.

This Python script:
1. reads a `csv` format files containing name days and extended name days, 
1. combines the content of those files into a new data format, 
1. writes the content into a `json` format file.

Source files can be found here:
* [Kalendārvārdu ekspertu komisija](https://www.vvc.gov.lv/lv/kalendarvardu-ekspertu-komisija)
** [Latviešu tradicionālo vārdadienu saraksts](https://www.vvc.gov.lv/lv/media/157/download?attachment)
** [Paplašinātais vārdadienu saraksts](https://www.vvc.gov.lv/lv/media/156/download?attachment)

_These files are provided and maintained by the [Valsts valodas centrs](https://www.vvc.gov.lv/lv)._

## Requirements

* Minimum Python Version: Python 3.6

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
        "month": Int,                       # Value between 1 - 12.
        "day": Int,                         # Value between 1 - 31.
        "names": Array<String>,             # Name array. If the date has no names, it is represented as an empty array.
        "additional_names": Array<String>   # Additional name array, which are not written in the calendar. 
                                            # If the date has no names, it is represented as an empty array.
    },
    ...
]
```

## Licence

`vardadiena-parser` is released under the MIT License. See [LICENSE](LICENSE) for details.
