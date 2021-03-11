# name-day-parser

A script that provides Latvian [name days](https://en.wikipedia.org/wiki/Name_day) in JSON file format.

This Ruby script loads and reads a PDF file from provided URL, parses its content into JSON format and write it to a file.

Links to source PDF files are these:
* [https://vvc.gov.lv/advantagecms/export/docs/komisijas/Vardadienu_saraksts_2018.pdf](https://vvc.gov.lv/advantagecms/export/docs/komisijas/Vardadienu_saraksts_2018.pdf)
* [https://vvc.gov.lv/advantagecms/export/docs/komisijas/Paplasinatais_saraksts_2018.pdf](https://vvc.gov.lv/advantagecms/export/docs/komisijas/Paplasinatais_saraksts_2018.pdf)

_These files are provided and maintained by the Latvian government._

# Usage

## Install dependencies

To better manage the script dependencies, we are using [Bundler](https://bundler.io).

```console
gem install bundler
bundle install
```

## Run parser

Execute the Terminal command inside the root directory of this project:

```console
bundle exec ruby parser.rb
```

## Result 

Script parses 2 provided PDF files and generates 2 new JSON files inside the `output` directory:

1. [names.json](./output/names.json)

Contains names which are included in the calendar.

* [names_extended.json](./output/names_extended.json)

Contains names which are included in the calendar and also all additional names which are not included in the calendar.

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

# Licence

`name-day-parser` is released under the MIT License. See [LICENSE](LICENSE) for details.
