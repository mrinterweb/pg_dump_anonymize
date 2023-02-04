RSpec.describe PgDumpAnonymize do
  it "has a version number" do
    expect(PgDumpAnonymize::VERSION).not_to be nil
  end

  it "can process a file with no transformations, producing an exact copy" do
    def_file = "spec/fixtures/empty_def_file.rb"
    dump_file = File.open("spec/fixtures/sample_dump.sql")
    out_file = Tempfile.new('foo')

    PgDumpAnonymize.anonymize(def_file, dump_file, out_file)

    dump_file.rewind
    out_file.rewind
    expect(dump_file.read).to eql(out_file.read)
  end

  it "can process a file with a static transformation" do
    def_file = "spec/fixtures/static_def.rb"
    dump_file = File.open("spec/fixtures/sample_dump.sql")
    out_file = Tempfile.new('foo')

    PgDumpAnonymize.anonymize(def_file, dump_file, out_file)

    out_file.rewind
    expect(out_file.grep(/test user/i)).to eql([])
    out_file.rewind
    expect(out_file.grep(/Jimbo/i).size).to eql(3)
  end

  it "can process a file with a dynamic transformation" do
    def_file = "spec/fixtures/dynamic_definition.rb"
    dump_file = File.open("spec/fixtures/sample_dump.sql")
    out_file = Tempfile.new('foo')

    PgDumpAnonymize.anonymize(def_file, dump_file, out_file)

    out_file.rewind
    expect(out_file.grep(/test user/i)).to eql([])
    out_file.rewind
    matches = out_file.grep(/Jimbo/i)
    line1, line2, line3 = matches

    jimboA, jimboB, jimboC = matches.map do |line|
      values = line.split("\t")
      values[1]
    end
    expect(jimboA).not_to eql(jimboB)
    expect(jimboA).not_to eql(jimboC)
    expect(jimboB).not_to eql(jimboC)
  end

  it "treats def file table references to absent tables as a noop" do
    def_file = "spec/fixtures/inapplicable_def_file.rb"
    dump_file = File.open("spec/fixtures/sample_dump.sql")
    out_file = Tempfile.new('foo')

    PgDumpAnonymize.anonymize(def_file, dump_file, out_file)

    dump_file.rewind
    out_file.rewind
    expect(dump_file.read).to eql(out_file.read)
  end
end
