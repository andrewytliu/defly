require 'tracable'
require 'whinable'

module Defly
end

Object.send(:include, Defly::Tracable)

NoMethodError.send(:include, Defly::Whinable)

def test_blah
  a = 1
  a.abcd
end