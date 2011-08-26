require 'rib/core'
require 'rib/more'

module Defly
  module Inspectable
    def watch_error error
      @__defly_watch ||= []
      @__defly_watch << error
    end
    
    def raise error
      @__defly_watch ||= []
      
      if @__defly_watch.include? error.class or @__defly_watch.include? error
        puts ">>>>> Error received:"
        p error
        puts ">>>>> "
        
        Rib.enable_anchor do
          Rib.anchor self
        end
      end
      super
    end
  end
end