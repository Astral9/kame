
module Kame
  module Shortcuts
    def rm(*args)
      Kame::Action.new 'rm', *args  
    end

    def rm_rf(*args)
      Kame::Action.new 'rm', '-rf', *args
    end

    def echo(*args)
      Kame::Action.new 'echo', *args
    end

    def shell(*args)
      Kame::Action.new(*args)
    end

    def pexit(*args)
      Kame::Action.new 'exit', *args
    end

    def cc(*args)
      Kame::FooAction.new :cc, 'gcc', args
    end
  end
end