# Vārdadiena Parser

A script that requests and parses Latvian [name days](https://en.wikipedia.org/wiki/Name_day) into JSON file format.

This Ruby script loads and reads a PDF file from provided URL, parses its content into JSON format and write it to a file.

Links to source PDF files are these:
* [Kalendārvārdu ekspertu komisija](https://www.vvc.gov.lv/lv/kalendarvardu-ekspertu-komisija)
* [Latviešu tradicionālo vārdadienu saraksts](https://www.vvc.gov.lv/lv/media/157/download?attachment)
* [Paplašinātais vārdadienu saraksts](https://www.vvc.gov.lv/lv/media/156/download?attachment)

_These files are provided and maintained by the [Valsts valodas centrs](https://www.vvc.gov.lv/lv)._

## Setup

To better manage the script dependencies, we are using [Bundler](https://bundler.io).

```console
gem install bundler
bundle install
```

## Run

Execute the Terminal command inside the root directory of this project:

```console
bundle exec ruby parser.rb
```

## Output 

Script parses 2 provided PDF files and generates 4 new JSON files inside the `output` directory:

1. [names.json](./output/names.json)

Contains names which are included in the calendar.

2. [names_pretty.json](./output/names_pretty.json)

Contains names which are included in the calendar in a pretty json format.

3. [names_extended.json](./output/names_extended.json)

Contains names which are included in the calendar and also all additional names which are not included in the calendar.

4. [names_extended_pretty.json](./output/names_extended_pretty.json)

Contains names which are included in the calendar and also all additional names which are not included in the calendar in a pretty json format.

### JSON structure

```
[
    {
        "month": Int,                       # Value between 1 - 12.
        "day": Int,                         # Value between 1 - 31.
        "names": Array<String>,             # Name array. No names are represented as an empty array.
        "additional_names": Array<String>   # Additional name array, which are not written in the calendar. 
                                            # No names are represented as an empty array.
    },
    ...
]
```

## Licence

`vardadiena-parser` is released under the MIT License. See [LICENSE](LICENSE) for details.
