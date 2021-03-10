# name-day-parser

Ruby script, which loads PDF file and parses its content to a json format.

# Usage

## Install dependencies

```
```console
gem install bundler
bundle install
```

## Run parser

```
```console
bundle exec ruby parser.rb
```

## Result 

Script parses 2 PDFs and generates 2 JSON files:

1. [names.json](./names.json)

Contains names which are included in the calendar.

* [names_extended.json](./names_extended.json)

Contains names which are included in the calendar and also all additional names which are not included in the calendar.

### File structure

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
