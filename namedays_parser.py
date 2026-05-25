import csv
import datetime
import json
import sys
import os

def clean_names(name_list):
    """Remove periods and extra whitespaces from names but keep em dashes."""
    cleaned_names = []
    for name in name_list:
        name = name.replace('.', '').replace(',', '').strip()  # Remove periods and commas, trim whitespace, but keep em dashes
        if name:  # Only add non-empty names
            cleaned_names.append(name)
    return cleaned_names

def parse_csv(file_path):
    parsed_data = []
    special_case_string = "Visu neparasto un kalendāros neierakstīto vārdu diena"
    
    with open(file_path, mode='r', encoding='utf-8') as file:
        reader = csv.reader(file, delimiter=',')
        next(reader)  # Skip header row
        for row in reader:
            if len(row) != 2:
                print(f"Skipping row due to unexpected number of columns: {row}")
                continue  # Skip rows that don't have exactly 2 columns
            
            day_str, names = row
            day_str = day_str.strip()  # Remove any leading/trailing whitespace
            if not day_str:
                print(f"Skipping row due to empty date field: {row}")
                continue  # Skip if the day string is empty

            try:
                day, month = map(int, day_str[:-1].split('.'))  # Remove trailing '.' and split
            except ValueError:
                print(f"Skipping row due to invalid date format: {row}")
                continue  # Skip rows with invalid date format

            # Special case for May 22
            if day == 22 and month == 5:
                # Remove the special string from the names
                if special_case_string in names:
                    names = names.replace(special_case_string, '').strip()
                names_list = clean_names(names.split())
                # Add the special string back to the end
                names_list.append(special_case_string)
            else:
                names_list = clean_names(names.split())

            parsed_data.append({
                "day": day,
                "month": month,
                "names": names_list
            })
    
    print(f"Parsed data from {file_path}: {parsed_data}")
    return parsed_data

def combine_namedays(namedays, namedays_extended):
    combined_data = []
    
    for day_entry in namedays:
        additional_names = []
        
        for ext_entry in namedays_extended:
            if day_entry['day'] == ext_entry['day'] and day_entry['month'] == ext_entry['month']:
                additional_names = [name for name in ext_entry['names'] if name not in day_entry['names']]
                break
        
        # Convert all names to individual entries with the "is_additional_calendar_name" field.
        # Final ordering is applied later in merge_with_previous so removed entries also sort in.
        for name in day_entry['names']:
            # Replace "–" with an empty string when adding to the result
            combined_data.append({
                "month": day_entry['month'],
                "day": day_entry['day'],
                "name": "" if name == "–" else name,
                "is_additional_calendar_name": False
            })

        for name in additional_names:
            combined_data.append({
                "month": day_entry['month'],
                "day": day_entry['day'],
                "name": "" if name == "–" else name,
                "is_additional_calendar_name": True
            })
    
    print(f"Combined data: {combined_data}")
    return combined_data

def merge_with_previous(current, previous_path):
    """Merge the current snapshot with the previous JSON output.

    Identity is (month, day, name). Names still present in the source get
    "removed": null. Names that existed previously but are missing from the
    current source get "removed" set to the current UTC timestamp the first
    time they vanish; later runs preserve that original timestamp so it
    reflects when the name actually disappeared. If a name reappears in the
    source, "removed" goes back to null.
    """
    if os.path.exists(previous_path):
        with open(previous_path, 'r', encoding='utf-8') as f:
            previous = json.load(f)
    else:
        previous = []

    now_iso = datetime.datetime.now(datetime.timezone.utc).isoformat()

    current_by_key = {(r["month"], r["day"], r["name"]): r for r in current}
    previous_by_key = {(r["month"], r["day"], r["name"]): r for r in previous}

    merged = []
    for key in current_by_key.keys() | previous_by_key.keys():
        month, day, name = key
        if key in current_by_key:
            r = current_by_key[key]
            merged.append({
                "month": month,
                "day": day,
                "name": name,
                "is_additional_calendar_name": r["is_additional_calendar_name"],
                "removed": None,
            })
        else:
            r = previous_by_key[key]
            prev_removed = r.get("removed")
            merged.append({
                "month": month,
                "day": day,
                "name": name,
                "is_additional_calendar_name": r["is_additional_calendar_name"],
                "removed": prev_removed if prev_removed is not None else now_iso,
            })

    merged.sort(key=lambda r: (r["month"], r["day"], r["is_additional_calendar_name"], r["name"]))
    return merged

def main(namedays_file, namedays_extended_file):
    namedays = parse_csv(namedays_file)
    namedays_extended = parse_csv(namedays_extended_file)

    if not namedays or not namedays_extended:
        print("Error: One of the parsed datasets is empty. Please check the input files.")
        sys.exit(1)

    combined_data = combine_namedays(namedays, namedays_extended)

    output_folder = "output"
    output_file = os.path.join(output_folder, "namedays.json")

    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    merged = merge_with_previous(combined_data, output_file)

    with open(output_file, 'w', encoding='utf-8') as json_file:
        json.dump(merged, json_file, ensure_ascii=False, indent=2)

    print(f"Output written to {output_file}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python script.py <namedays_file> <namedays_extended_file>")
        sys.exit(1)
    
    namedays_file = sys.argv[1]
    namedays_extended_file = sys.argv[2]
    
    main(namedays_file, namedays_extended_file)
