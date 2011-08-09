require 'tracable'
require 'whinable'

module Defly
end

NoMethodError.send(:include, Defly::Whinable)
