
ATTRIBUTES = {
  bold: 1,
  underlined: 4,
  
  red: 31,
  green: 32,
  yellow: 33,
  blue: 34,
  gray: 37,
  
  on_red: 41,
  on_green: 42,
  on_yellow: 43,
  on_blue: 44  
}

module Kame
  module Tty
    ATTRIBUTES.each do |attr, n|
      define_method(attr) { $stdout.isatty ? "\e[#{n}m#{self}\e[0m" : self }
    end
  end  
end

class String
  include Kame::Tty
end