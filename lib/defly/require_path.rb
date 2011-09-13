module Defly
  module RequirePath
    def require name, opts = {}
      ret = super name
      require_path = nil

      if opts[:verbose]
        $LOAD_PATH.each do |path|
          full_path = File.join path, "#{name}.rb"

          if File.exist? full_path
            require_path = full_path
            break
          end
        end

        if require_path
          puts "Requiring #{require_path}"
        else
          puts "#{name} cannot be required"
        end
      end

      ret
    end
  end
end