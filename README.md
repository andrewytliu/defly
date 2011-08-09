# defly

A ruby debugging tool.  Easy way to trace function calls and variables.

## Feature
* Trace method calls: including arguments and return values
* Trace variable changes
* Showing source code when NoMethodError occurred

## Install

Just `gem install defly`.

## Sample Usage

### Input

```ruby
require 'defly'
class Warrior
  include Defly::Tracable
  attr_accessor :hp, :mp

  def sleep
    self.hp += 10
    self.mp += 2
  end
end

Warrior.new.trace([:hp, :hp=, :mp, :mp=, :sleep], [:@hp, :@mp]) do |warrior|
  warrior.hp = 10
  warrior.mp = 20
  warrior.sleep
end
```

### Output (Run on IRB)

    Tracing hp, hp=, mp, mp=, sleep on Warrior instance
    Tracing @hp, @mp  on Warrior instance
    <<<<< Warrior#hp=(10) # (irb):12:in `block in irb_binding'
        @hp = 10 # undefined
        @mp = nil # undefined
    >>>>> 10
    <<<<< Warrior#mp=(20) # (irb):13:in `block in irb_binding'
        @mp = 20 # undefined
    >>>>> 20
    <<<<< Warrior#sleep() # (irb):14:in `block in irb_binding'
        <<<<< Warrior#hp() # (irb):6:in `sleep'
        >>>>> 10
        <<<<< Warrior#hp=(20) # (irb):6:in `sleep'
            @hp = 20 # 10 -> 20
        >>>>> 20
        <<<<< Warrior#mp() # (irb):7:in `sleep'
        >>>>> 20
        <<<<< Warrior#mp=(22) # (irb):7:in `sleep'
            @mp = 22 # 20 -> 22
        >>>>> 22
    >>>>> 22

## Copyright

Copyright (c) 2011 Andrew Liu. See LICENSE.txt for
further details.

