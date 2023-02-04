# pg_dump_anonymize

Anonymizing pg_dump data isn't always straight forward. This tool helps. It has no dependencies, other than ruby. Another good thing is that sensitive data doesn't need to ever be stored temporarily as this can be used with Unix pipes and the data is passed through as IO data.

`pg_dump_anonymize` does not anonymize any data automatically. It is very much BYOAD (Bring Your Own Anonymizing Definition). Inside your anonymizing definition, you can use any ruby gems you like, such as [faker](https://github.com/faker-ruby/faker). This gem makes applying anonymizing definitions to `pg_dump` output easy.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pg_dump_anonymize'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install pg_dump_anonymize

## Usage

`pg_dump_anonymize` does not anonymize any data by default. You must provide your own anonymizing definition. The gem currently requires the format of output `pg_dump` is plain text (not compressed) and uses the default `COPY` behavior instead of `INSERT INTO`.

Example usage:

```
pg_dump --no-privileges --no-owner <database-name> | pg_dump_anonymize -d sample_definition.rb > anonymized_dump.sql
```

You can also pipe the anonymized SQL directly into `psql` to avoid intermediate SQL dump files.

### Definition File

The definition file is any ruby code you'd like, but it must return a hash with table names as the top level keys and attribute names nested under the table keys. Any faking ruby gems dependencies, and other gem dependencies you may choose to use in your definitions, are gems that will need to be available on the server this is ran on.

Example:

```ruby
{
  table_1: {
    sensitive_field_1: 'some string value',
    sensitive_field_2: -> { rand(100) },
    sensitive_field_3: -> (original_value, row_context) do
      if original_value
        'xxxxx'
      end.tap { |new_val| row_context[field_3_val] = new_val }
    end,
    sensitive_field_4: -> (_original_value, row_context) do
      row_context[:field_3_val] ? 'foo' : 'bar'
    end
  },
  table_2: {
    sensitive_field_3: nil
  }
}
```

Here is a more concrete example using the [faker gem](https://github.com/faker-ruby/faker).

```ruby
require 'faker'

{
  users: {
    first_name: -> { Faker::Name.first_name },
    last_name: -> { Faker::Name.last_name },
    email: -> { Faker::Internet.email },
    city: 'Portland'
  },
  accounts: {
    bank_name: -> { Faker::Bank.name },
    account_num: -> { Faker::Bank.account_number },
    routing_num: -> { Faker::Bank.routing_number }
  }
}
```

## Todo
- [ ] Write some tests (so far this has been tested manually)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Performance

This has been tested with a 1GB dump file, and it took 11 seconds on a 2013 MacBook Pro to anonymize it. It largely depends on how much you're anonymizing, and the anonymizing definitions you're applying. So milage will vary. Still, this is plenty fast for most of my needs.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/pg_dump_anonymize.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
