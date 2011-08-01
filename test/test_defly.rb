require 'helper'

class TestDefly < Test::Unit::TestCase
  should "properly trace" do
    class C
      attr_accessor :a
      
      def b c
        self.a = c
        @a = 10
      end
    end
    
    C.new.trace([:a, :a=, :b], [:@a]) do |d|
      d.a = 10
      d.a = 20
      d.b 40
    end
  end
end
