# frozen_string_literal: true

module PgDumpAnonymize
  # This is used to define rules and apply the rules when parsing the dump sql file
  class Definition
    def initialize(attribute_rules)
      @attribute_rules = attribute_rules
      @current_table = nil
      @positional_substitutions = nil
    end

    def process_line(line)
      if @current_table
        if end_stdin?(line)
          clear_current_table
        else
          line = anonymize_line(line)
        end
      else
        process_copy_line(line)
      end
      line
    end

    private

    # This assumes the line is a tab delimited data line
    def anonymize_line(line)
      values = line.split("\t")
      row_context = {} # used to share state for a row
      @positional_substitutions.each do |index, val_def|
        values[index] = if val_def.is_a?(Proc)
                          val_def.call(*[values[index], row_context].slice(0, val_def.arity))
                        else
                          val_def
                        end
      end
      values.join("\t")
    end

    def process_copy_line(line)
      match_data = line.match(line_regex)
      return unless match_data

      table = match_data[:table_name].to_sym
      fields = match_data[:field_defs]

      @current_table = table
      @positional_substitutions = find_positions(fields, @attribute_rules[table])
    end

    # Finds the positional range of the attribute to be replaced
    # returns an array of arrays. The inner array is [<field_index>, <anonymous_value>]
    def find_positions(fields_str, rules)
      fields = fields_str.gsub('"', '').split(', ')

      rules.map do |target_field, val|
        index = fields.index(target_field.to_s)
        [index, val] if index
      end.compact
    end

    def line_regex
      @line_regex ||= /^COPY public\.(?<table_name>#{table_names.join('|')}) \((?<field_defs>.*)\) FROM stdin;$/
    end

    # stdin is escaped with a line that is just '\.'
    def end_stdin?(line)
      line =~ /^\\.$/
    end

    def table_names
      @attribute_rules.keys
    end

    def clear_current_table
      @current_table = nil
      @positional_substitutions = nil
    end
  end
end
