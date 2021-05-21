require 'json'
require 'pdf-reader'
require 'open-uri'

# A script that parses official name day PDF provided by the government of the Latvia.
def parse_name_days(input_url, output_file_name)
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

    dates = []                   # Array, contains all the "current_date" dictionary instances.
    current_date = {}            # Dictionary, contains current date values, like month number, day number, names, etc.
    current_day_number = nil     # Integer, current day number, for which the names will be collected.
    current_month_number = nil   # Integer, current month number, for which the dates will be collected. Month numbers

    puts "Parsing..."
    reader.pages.each do |page|
        page.text
            .gsub(/^$\n/, '') # remove al the empty new lines.
            .each_line(chomp: true) { |s|
                text = s.gsub(/\s+/, "") # remove all the spaces from the line.
                text_with_spaces = s

                # Script searches for 3 kinds of lines:
                # 1. Line that contains only a month name.
                # All possible month names are saved in
                # the `month_list` array.
                #
                # 2. Lines that starts with a number and
                # a dot (.), followed by names. These names
                # the ones which are written in the calendar.
                #
                # 3. Lines that does not start with a number
                # and contains only names. These names are
                # the additional names for the specific date
                # which are not written in the calendar, but
                # still are celebrated.

                if month_index = month_list.index(text)
                    # Found month title.
                    # Search the list of predefined month names for their index.
                    # For example, "FEBRUĀRIS"

                    current_month_number = month_index + 1

                elsif text_with_spaces.match?(/^22. [[:alpha:]. ]+$/)
                    # Found line that contains a date and main names with
                    # additional text.
                    # This is the special case for the May 22nd where the
                    # date looks like this:
                    #   "22. Emīlija. Visu neparasto un kalendāros neierakstīto vārdu diena"

                    text = text_with_spaces

                    # Remove first 4 characters from the text.
                    # These characters represent the date number,
                    # which we already know.
                    text.slice!(0..3)
                    current_day_number = 22

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

                    if text.match?(/^[[:alpha:]. ]*$/)
                        # Found text that contains characters or dots with space.
                        # For example, "Emīlija. Visu neparasto un kalendāros neierakstīto vārdu diena"

                        names = text.split(". ")
                        current_date[:names] = names
                    end

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
                        # In source PDF, there is additional text
                        # before the first month is found.
                        # These kind of texts can be ignored.
                        next
                    end

                    names = text.split(",")
                    current_date[:additional_names].concat(names)
                end
        }
    end

    # Add last "current_date" object to the "dates" list if it is not empty.
    # This is necessary for December 31st.
    unless current_date.empty?
        dates.push(current_date)
    end

    puts "Writing to file..."
    destination = "output/#{output_file_name}.json"
    File.write(destination, JSON.generate(dates))

    destination = "output/#{output_file_name}_pretty.json"
    File.write(destination, JSON.pretty_generate(dates))

    puts "File created: #{destination}"
end

parse_name_days('https://vvc.gov.lv/advantagecms/export/docs/komisijas/Vardadienu_saraksts_2018.pdf', 'names')
parse_name_days('https://vvc.gov.lv/advantagecms/export/docs/komisijas/Paplasinatais_saraksts_2018.pdf', 'names_extended')
