module Defly
  module Tracable
    def trace(methods, variables, &block)
      trace_method!(methods)
      trace_variable!(variables)
      yield self
      untrace!
      
      self
    end
    
    def trace_method!(methods)
      @__defly_methods ||= []
      
      methods = public_methods(false) if methods.size == 0
      methods.map! {|m| m.to_sym }
      methods -= @__defly_methods
      @__defly_methods |= methods
      
      STDERR << "Tracing #{methods.join(', ')} on #{self.class} instance\n"
      
      methods.each do |m|
        eigenclass.class_eval <<-RUBY, __FILE__, __LINE__
          def #{m}(*args, &block)
            @__defly_level ||= 0
            indent = '    ' * @__defly_level
            
            begin
              STDERR << "\#{indent}<<<<< #{self.class}##{m}(\#{args.join(', ')}) # \#{caller[0]}\n"
              @__defly_level += 1
              result = super
              @__defly_level -= 1
              __defly_check_var(indent) if defined? __defly_check_var
              STDERR << "\#{indent}>>>>> \#{result}\n"
              result
            rescue
              STDERR << "#{m}: \#{$!.class}: \#{$!.message}\n"
              raise
            end
          end
        RUBY
      end
    end
    
    def trace_variable!(variables)
      @__defly_variables ||= []
      
      variables = instance_variables if variables.size == 0
      variables.map! {|v| v.to_sym }
      variables -= @__defly_variables
      @__defly_variables |= variables
      
      STDERR << "Tracing #{variables.join(', ')} on #{self.class} instance\n"
      
      unless eigenclass.instance_methods.include? :__defly_check_var
        eigenclass.class_eval <<-RUBY, __FILE__, __LINE__
          def __defly_check_var(indent)
            @__defly_varmap ||= {}
            
            @__defly_variables.each do |v|
              new_val = instance_variable_get(v)
              if @__defly_varmap[v]
                STDERR << "    \#{indent}\#{v.to_s} = \#{new_val.inspect} # \#{@__defly_varmap[v].inspect} -> \#{new_val.inspect}\n" unless @__defly_varmap[v] == new_val
              else
                STDERR << "    \#{indent}\#{v.to_s} = \#{new_val.inspect} # undefined\n"
              end
              @__defly_varmap[v] = new_val
            end
          end
        RUBY
      end
    end
    
    def untrace!
      [:defly_check_var].concat(@__defly_methods).each do |m|
        eigenclass.remove_method(m) if eigenclass.instance_methods.include? m
      end
    end
    
    def eigenclass
      class << self; self; end
    end
  end
end
