require "sie/parser/tokenizer"
require "sie/parser/entry"
require "sie/parser/sie_file"

module Sie
  class Parser
    class LineParser
      pattr_initialize :line

      def parse
        tokens = tokenize(line)
        first_token = tokens.first
        entry = Entry.new(first_token.label)
        line_entry_type = first_token.entry_type

        attributes_with_tokens(line_entry_type, tokens[1..-1]).each do |attr, *tokens|
          label = attr.is_a?(Hash) ? attr[:name] : attr
          if tokens.size == 1
            entry.attributes[label] = tokens.first
          else
            values = tokens.each_slice(attr[:type].size).map { |slice| Hash[attr[:type].zip(slice)] }
            entry.attributes[label] = values
          end
        end

        entry
      end

      private

      def attributes_with_tokens(line_entry_type, tokens)
        line_entry_type.map { |attr_entry_type|
          if attr_entry_type.is_a?(String)
            token = tokens.shift
            next unless token
            [attr_entry_type, token.value]
          else
            token = tokens.shift
            if !token.is_a?(Tokenizer::BeginArrayToken)
              raise "ERROR"
            end

            hash_tokens = []
            while token = tokens.shift
              break if token.is_a?(Tokenizer::EndArrayToken)
              hash_tokens << token.value
            end

            [attr_entry_type, *hash_tokens]
          end
        }.compact
      end

      def tokenize(line)
        Tokenizer.new(line).tokenize
      end
    end
  end
end
