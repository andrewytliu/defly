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
      @defly_methods ||= []
      
      methods = public_methods(false) if methods.size == 0
      methods.map! {|m| m.to_sym }
      methods -= @defly_methods
      @defly_methods |= methods
      
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
              defly_check_var(indent) if defined? defly_check_var
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
      @defly_variables ||= []
      
      variables = instance_variables if variables.size == 0
      variables.map! {|v| v.to_sym }
      variables -= @defly_variables
      @defly_variables |= variables
      
      STDERR << "Tracing #{variables.join(', ')}  on #{self.class} instance\n"
      
      eigenclass.remove_method :defly_check_var_list if eigenclass.instance_methods.include? :defly_check_var_list
      
      eigenclass.class_eval <<-RUBY, __FILE__, __LINE__
        def defly_check_var_list
          [#{@defly_variables.map(&:inspect).join(', ')}]
        end
      RUBY
      
      unless eigenclass.instance_methods.include? :defly_check_var
        eigenclass.class_eval <<-RUBY, __FILE__, __LINE__
          def defly_check_var(indent)
            @__defly ||= {}
            
            var_list = defly_check_var_list
            var_list.each do |v|
              new_val = instance_variable_get(v)
              if @__defly[v]
                STDERR << "    \#{indent}\#{v.to_s} = \#{new_val.inspect} # \#{@__defly[v].inspect} -> \#{new_val.inspect}\n" unless @__defly[v] == new_val
              else
                STDERR << "    \#{indent}\#{v.to_s} = \#{new_val.inspect} # undefined\n"
              end
              @__defly[v] = new_val
            end
          end
        RUBY
      end
    end
    
    def untrace!
      [:defly_check_var_list, :defly_check_var].concat(@defly_methods) do |m|
        eigenclass.remove_method(m) if eigenclass.instance_methods.include? m
      end
    end
    
    def eigenclass
      class << self; self; end
    end
  end
end