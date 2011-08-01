# defly

A ruby debugging tool.  Easy way to trace function calls and variables.

## Install

Just `gem install defly`.

## Sample Usage

### Input

```ruby
require 'defly'
class Warrior
  attr_accessor :hp, :mp

  def sleep
    self.hp += 10
    self.mp += 2
  end
end

Warrior.new.trace([:hp, :hp=, :mp, :mp=], [:@hp, :@mp]) do |warrior|
  warrior.hp = 10
  warrior.mp = 20
  warrior.sleep
end
```

### Output (Run on IRB)

    Tracing hp, hp=, mp, mp= on Warrior instance
    Tracing @hp, @mp  on Warrior instance
    <<<<< Warrior#hp=(10) # (irb):12:in `block in irb_binding'
        @hp = 10 # undefined
        @mp = nil # undefined
    >>>>> 10
    <<<<< Warrior#mp=(20) # (irb):13:in `block in irb_binding'
        @mp = 20 # undefined
    >>>>> 20
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
    => #<Warrior:0x00000100987488 @defly_methods=[:hp, :hp=, :mp, :mp=], @defly_variables=[:@hp, :@mp], @__defly_level=0, @hp=20, @__defly={:@hp=>20, :@mp=>22}, @mp=22>


## Copyright

Copyright (c) 2011 Andrew Liu. See LICENSE.txt for
further details.

