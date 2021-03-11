require 'json'
require 'pdf-reader'
require 'open-uri'

# A script that parses official name day PDF provided by the government of the Latvia.
def parse_name_days(input_url, output_file)
    puts "Reading: #{input_url}"
    io = URI.open(input_url)
    reader = PDF::Reader.new(io)

    # List of predefined month names.
    month_list = [
        "JANVĀRIS",
        "FEBRUĀRIS",
        "MARTS",
        "APRĪLIS",
        "MAIJS",
        "JŪNIJS",
        "JŪLIJS",
        "AUGUSTS",
        "SEPTEMBRIS",
        "OKTOBRIS",
        "NOVEMBRIS",
        "DECEMBRIS"
    ]

    current_day_number = nil     # Integer, current day number, for which the names will be collected.
    current_month_number = nil   # Integer, current month number, for which the dates will be collected. Month numbers
    current_date = {}            # Dictionary, contains current date values, like month number, day number, names, etc.
    dates = []                   # Array, contains all the "current_date" dictionary instances.

    puts "Parsing..."
    reader.pages.each do |page|
        page.text
            .gsub(/^$\n/, '') # remove al the empty new lines.
            .each_line(chomp: true) { |s|
                text = s.gsub(/\s+/, "") # remove all the spaces from the line.

                if month_index = month_list.index(text)
                    # Found month title.
                    # Search the list of predefined month names for their index.
                    # For example, "FEBRUĀRIS"

                    current_month_number = month_index + 1

                elsif text.match?(/^\d+\.[[:alpha:],–]+$/)
                    # Found line that contains a date and main names.
                    # Search for a line that starts with a number, after which
                    # follows a single dot (.), and then names
                    # separated with commas.
                    # For example:
                    #   "22.Ārija,Rigonda,Adrians,Adriāna,Adrija"
                    #   "29.–", a special date for the February 29th.

                    # Split the line by the dot in 2 pieces, where one contains
                    # the date and the second contains the names.
                    result = text.split(".")
                    current_day_number = result[0].to_i

                    # If "current_date" contains values, save them into the dates
                    # array and create a fresh instance, because we have moved to
                    # a different date.
                    unless current_date.empty?
                        dates.push(current_date)
                    end

                    # Create a fresh dictionary instance for the new date.
                    current_date = {
                        :month => current_month_number,
                        :day => current_day_number,
                        :names => [],
                        :additional_names => []
                    }

                    if result[1].match?(/^[[:alpha:],]*$/)
                        # Found text that contains characters or commas.
                        # For example, "Ārija,Rigonda,Adrians,Adriāna,Adrija"

                        names = result[1].split(",")
                        current_date[:names] = names
                    end

                elsif text.match?(/^[[:alpha:],]*$/)
                    # Found line that contains additional names for the specific day.
                    # Search for a line that contains only names separated by commas.
                    # For example, "Ārija,Rigonda,Adrians,Adriāna,Adrija"

                    if current_month_number.nil?
                        # Texts before the first month is found can be ignored.
                        next
                    end

                    names = text.split(",")
                    current_date[:additional_names] = names
                end
        }
    end

    # Add last "current_date" object to the "dates" list if it is not empty.
    # This is necessary for December 31st.
    unless current_date.empty?
        dates.push(current_date)
    end

    puts "Writing to file..."
    destination = "output/#{output_file}"
    File.write(destination, dates.to_json)

    puts "File created: #{destination}"
end

parse_name_days('https://vvc.gov.lv/advantagecms/export/docs/komisijas/Vardadienu_saraksts_2018.pdf', 'names.json')
parse_name_days('https://vvc.gov.lv/advantagecms/export/docs/komisijas/Paplasinatais_saraksts_2018.pdf', 'names_extended.json')
