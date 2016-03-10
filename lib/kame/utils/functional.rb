
module Kame
  module Functional
    def void(_)
      nil
    end
    
    def truify(_)
      true
    end
    
    def falsify(_)
      false
    end
    
    def id(_)
      self
    end
  end
end