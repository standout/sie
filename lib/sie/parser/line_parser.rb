require "sie/parser/tokenizer"
require "sie/parser/entry"
require "sie/parser/sie_file"

module Sie
  class Parser
    class LineParser
      pattr_initialize :line

      def parse
        tokens = tokenize(line)
        first_token = tokens.shift

        entry = Entry.new(first_token.label)
        line_entry_type = first_token.entry_type

        ti = ai = 0
        while ti < tokens.size && ai < line_entry_type.size
          attr_entry_type = line_entry_type[ai]

          if attr_entry_type.is_a?(Hash)
            label = attr_entry_type[:name]
            type = attr_entry_type[:type]
            entry.attributes[label] ||= []

            ti += 1
            hash_tokens = []
            while !tokens[ti].is_a?(Sie::Parser::Tokenizer::EndArrayToken)
              hash_tokens << tokens[ti].value
              ti += 1
            end

            hash_tokens.each_slice(type.size).each do |slice|
              entry.attributes[label] << Hash[type.zip(slice)]
            end
          else
            label = attr_entry_type
            entry.attributes[label] = tokens[ti].value
          end

          ti += 1
          ai += 1
        end

        entry
      end

      private

      def tokenize(line)
        Tokenizer.new(line).tokenize
      end
    end
  end
end
