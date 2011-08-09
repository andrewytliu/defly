module Defly
  module Whinable
    def to_s
      orig_message = super
      position = backtrace[0]
      message = ""
      missing_method = name.to_s
      
      unless /^\(.*\):.*/ =~ position # skipping irb
        file, line, other = position.split(':')        
        code = IO.readlines(file)[line.to_i - 1].chomp
        code.gsub!(/(#{missing_method})/, '<<\1>>')
        message = "#{file.split('/')[-1]}:#{line}> #{code}"
      end
      
      "#{orig_message}\n#{message}"
    end
  end
end