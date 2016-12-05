class CssBeautify
  class << self
    def whitespace?(c)
      c == ' ' || c == "\n" || c == "\t" || c == "\r" || c == "\f"
    end

    def quote?(c)
      c == "\"" || c == "'"
    end

    def name?(c)
      (c >= 'a' && c <= 'z') ||
      (c >= 'A' && c <= 'Z') ||
      (c >= '0' && c <= '9') ||
      '-_*.:#[]'.include?(c)
    end

    def trim_right(input)
      input.sub /\s+\Z/, ''
    end

    STATE_START = 0
    STATE_AT_RULE = 1
    STATE_BLOCK = 2
    STATE_SELECTOR = 3
    STATE_RULESET = 4
    STATE_PROPERTY = 5
    STATE_SEPARATOR = 6
    STATE_EXPRESSION = 7
    STATE_URL = 8

    def beautify(style, options = {})
      openbracesuffix = (options[:openbrace] != 'end-of-line')
      autosemicolon = !!options[:autosemicolon]
      indent = options[:indent] || '    '

      ch = ''
      ch2 = ''
      formatted = ''
      index = 0
      length = style.length
      depth = 0
      state = STATE_START
      comment = false
      blocks = []
      style = style.gsub(/\r\n/, "\n")
      quote = nil

      append_indent = Proc.new { formatted << (indent * depth) }

      open_block = Proc.new do
        formatted = trim_right(formatted)
        if openbracesuffix
          formatted << " {"
        else
          formatted << "\n"
          append_indent.call
          formatted << '{'
        end

        formatted << "\n" unless ch2 == "\n"
        depth = depth + 1
      end

      close_block = Proc.new do
        depth = depth - 1
        formatted = trim_right(formatted)

        if formatted.length > 0 && autosemicolon
          unless (formatted[-1] == ';' || formatted[-1] == '{')
            formatted << ';'
          end
        end

        formatted << "\n"
        append_indent.call
        formatted << '}'

        blocks << formatted
        formatted = ''
      end

      while index < length
        ch = style[index]
        ch2 = style[index + 1]
        index = index + 1

        if quote?(quote)
          formatted << ch

          quote = nil if ch == quote

          if ch == "\\" && ch2 == quote
            formatted << ch2
            index = index + 1
          end
          next
        end

        if quote?(ch)
          formatted << ch
          quote = ch
          next
        end

        if comment
          formatted << ch
          if ch == '*' && ch2 == '/'
            comment = false
            formatted << ch2
            index = index + 1
          end
          next
        end

        if ch == '/' && ch2 == '*'
          comment = true
          formatted << ch << ch2
          index = index + 1
          next
        end

        if state == STATE_START
          if blocks.empty?
            if whitespace?(ch) && formatted.empty?
              next
            end
          end

          if (ch <= ' ') || ch.ord >= 128
            state = STATE_START
            formatted << ch
            next
          end

          if name?(ch) || ch == '@'
            str = trim_right(formatted)

            if str.empty?
              if blocks.length > 0
                formatted = "\n\n"
              end
            else
              if str[-1] == '}' || str[-1] == ';'
                formatted = str + "\n\n"
              else
                while true
                  ch2 = formatted[-1]
                  break unless ch2 == ' ' || ch2.ord == 9
                  formatted = formatted.slice(0, formatted.length - 1)
                end
              end
            end

            formatted << ch
            state = (ch == '@') ? STATE_AT_RULE : STATE_SELECTOR
            next
          end
        end

        if state == STATE_AT_RULE
          if ch == ';'
            formatted << ch
            state = STATE_START
            next
          end

          if ch == '{'
            str = trim_right(formatted)
            open_block.call
            state = (str == '@font-face') ? STATE_RULESET : STATE_BLOCK
            next
          end

          formatted << ch
          next
        end

        if state == STATE_BLOCK
          if name?(ch)
            str = trim_right(formatted)
            if str.empty?
              if blocks.length > 0
                formatted = "\n\n"
              end
            else
              if str[-1] == '}'
                formatted = str + "\n\n"
              else
                while true
                  ch2 = formatted[-1]
                  break unless ch2 == ' ' || ch2.ord == 9
                  formatted = formatted.slice(0, formatted.length - 1)
                end
              end
            end

            append_indent.call
            formatted << ch
            state = STATE_SELECTOR
            next
          end

          if ch == '}'
            close_block.call
            state = STATE_START
            next
          end

          formatted << ch
          next
        end

        if state == STATE_SELECTOR
          if ch == '{'
            open_block.call
            state = STATE_RULESET
            next
          end

          if ch == '}'
            close_block.call
            state = STATE_START
            next
          end

          formatted << ch
          next
        end

        if state == STATE_RULESET
          if ch == '}'
            close_block.call
            state = STATE_START
            state = STATE_BLOCK if depth > 0
            next
          end

          if ch == "\n"
            formatted = trim_right(formatted)
            formatted << "\n"
            next
          end

          unless whitespace?(ch)
            formatted = trim_right(formatted)
            formatted << "\n"
            append_indent.call
            formatted << ch
            state = STATE_PROPERTY
            next
          end

          formatted << ch
          next
        end

        if state == STATE_PROPERTY
          if ch == ':'
            formatted = trim_right(formatted)
            formatted << ': '
            state = STATE_EXPRESSION
            state = STATE_SEPARATOR if whitespace?(ch2)
            next
          end

          if ch == '}'
            close_block.call
            state = STATE_START
            state = STATE_BLOCK if depth > 0
            next
          end

          formatted << ch
          next
        end

        if state == STATE_SEPARATOR
          unless whitespace?(ch)
            formatted << ch
            state = STATE_EXPRESSION
            next
          end

          state = STATE_EXPRESSION if quote?(ch)
          next
        end

        if state == STATE_EXPRESSION
          if ch == '}'
            close_block.call
            state = STATE_START
            state = STATE_BLOCK if depth > 0
            next
          end

          if ch == ';'
            formatted = trim_right(formatted)
            formatted << ";\n"
            state = STATE_RULESET
            next
          end

          formatted << ch

          if ch == '('
            if formatted[-4, 3] == 'url'
              state = STATE_URL
              next
            end
          end

          next
        end

        if state == STATE_URL
          if ch == ')' && formatted[-1] != "\\"
            formatted << ch
            state = STATE_EXPRESSION
            next
          end
        end

        formatted << ch
      end

      formatted = blocks.join('') + formatted
      formatted.strip
    end
  end
end