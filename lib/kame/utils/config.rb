module Kame
  module Config
    @config = {}
    
    define_method :get, &@config.method(:[])
    define_method :set, &@config.method(:[]=)
  end  
end