import csv
import json
import sys
import os

def parse_csv(file_path):
    parsed_data = []
    with open(file_path, mode='r', encoding='utf-8') as file:
        reader = csv.reader(file, delimiter=';')
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

            # Split names and filter out names containing the "–" symbol
            names = [name for name in names.split() if "–" not in name]
            parsed_data.append({
                "day": day,
                "month": month,
                "names": names
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
        
        combined_data.append({
            "month": day_entry['month'],
            "day": day_entry['day'],
            "names": day_entry['names'],
            "additional_names": additional_names
        })
    
    print(f"Combined data: {combined_data}")
    return combined_data

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
    
    with open(output_file, 'w', encoding='utf-8') as json_file:
        json.dump(combined_data, json_file, ensure_ascii=False, indent=2)

    print(f"Output written to {output_file}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python script.py <namedays_file> <namedays_extended_file>")
        sys.exit(1)
    
    namedays_file = sys.argv[1]
    namedays_extended_file = sys.argv[2]
    
    main(namedays_file, namedays_extended_file)
