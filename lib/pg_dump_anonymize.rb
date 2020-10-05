# frozen_string_literal: true

require 'pg_dump_anonymize/version'
require 'pg_dump_anonymize/definition'
require 'pg_dump_anonymize/stream_handler'

module PgDumpAnonymize
  class Error < StandardError; end

  def self.anonymize(definitions_file_path, input_io, output_io)
    definitions = eval(File.open(definitions_file_path).read) # rubocop:disable Security/Eval

    input_io.each_line do |line|
      output_io.write definitions.process_line(line)
    end
  end
end
