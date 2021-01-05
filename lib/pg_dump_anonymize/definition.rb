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
          unless skip_if(line)
            line = anonymize_line(line)
          end
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
      row_context = { row: row_to_hash(values) } # used to share state for a row
      @positional_substitutions.each do |index, val_def|
        values[index] = if val_def.is_a?(Proc)
                          val_def.call(*[values[index], row_context].slice(0, val_def.arity))
                        else
                          val_def
                        end

        # Postgres represents nil/null as '\N' in SQL dumps
        if values[index].nil?
          values[index] = '\N'
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
      @fields = fields_str.gsub('"', '').split(', ')

      rules.map do |target_field, val|
        index = @fields.index(target_field.to_s)
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
      @fields = nil
      @positional_substitutions = nil
    end

    def skip_if(row)
      if skip_if = @attribute_rules.dig(@current_table, :_skip_if)
        !!skip_if.call(row_to_hash(row))
      else
        false
      end
    end

    def delete_if(row)
      if delete_if = @attribute_rules.dig(@current_table, :_delete_if)
        !!delete_if.call(row_to_hash(row))
      else
        false
      end
    end

    def row_to_hash(row)
      return nil unless @fields

      values = row.kind_of?(String) ? row.split("\t") : row

      begin
        Hash[*@fields.zip(values).flatten]
      rescue StandardError => e
        raise "#{e.message}, row_to_hash error encountered: current_table: #{@current_table} -- fields(#{@fields&.length}): #{@fields} -- values(#{values&.length}): #{values}"
      end
    end
  end
end
