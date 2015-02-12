require "spec_helper"
require "sie/parser/line_parser"

describe Sie::Parser::LineParser, "parse" do
  it "parses lines from a sie file" do
    parser = Sie::Parser::LineParser.new('#TRANS 2400 {"3" "5"} -200 20130101 "Foocorp expense"')
    entry = parser.parse
    expect(entry.label).to eq("trans")
    expect(entry.attributes).to eq({
      "kontonr" => "2400",
      "belopp"  => "-200",
      "transdat" => "20130101",
      "transtext" => "Foocorp expense",
      "objektlista" => [{"dimensionsnr" => "3", "objektnr" => "5"}],
    })
  end
end
