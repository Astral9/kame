require 'kame/core'
require 'kame/utils/tty'

KAME_FILES = ['Kamefile', 'kamefile']

include Kame::Delegator

loaded = false

KAME_FILES.each do |f|
  begin
    load f
    puts "loaded #{f}."
    loaded = true
    break
  rescue LoadError
  end
end

require 'pry'
binding.pry
