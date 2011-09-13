# defly

A ruby debugging tool.  Easy way to trace function calls and variables.

## Install

Just `gem install defly`.

## Feature
* Trace method calls: including arguments and return values
* Trace variable changes
* Showing source code when NoMethodError is thrown
* Opening a shell when a particular error occurred
* Showing the exact path of required library

## Tracing method and instance variables

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

Warrior.debug!
Warrior.new.trace([:hp, :hp=, :mp, :mp=, :sleep], [:@hp, :@mp]) do |warrior|
  warrior.hp = 10
  warrior.mp = 20
  warrior.sleep
end
```

### Output (Run on IRB)

    Tracing hp, hp=, mp, mp=, sleep on Warrior instance
    Tracing @hp, @mp on Warrior instance
    <<<<< Warrior#hp=(10) # (irb):14:in `block in irb_binding'
        @hp = 10 # undefined
        @mp = nil # undefined
    >>>>> 10
    <<<<< Warrior#mp=(20) # (irb):15:in `block in irb_binding'
        @mp = 20 # undefined
    >>>>> 20
    <<<<< Warrior#sleep() # (irb):16:in `block in irb_binding'
        <<<<< Warrior#hp() # (irb):7:in `sleep'
        >>>>> 10
        <<<<< Warrior#hp=(20) # (irb):7:in `sleep'
            @hp = 20 # 10 -> 20
        >>>>> 20
        <<<<< Warrior#mp() # (irb):8:in `sleep'
        >>>>> 20
        <<<<< Warrior#mp=(22) # (irb):8:in `sleep'
            @mp = 22 # 20 -> 22
        >>>>> 22
    >>>>> 22

## Better Error Message

### NoMethodError

Showing the exact code and the position of the error.

```ruby
irb(main):001:0> require 'defly'
=> true
irb(main):002:0> require 'bug'
NoMethodError: undefined method `is_annoying' for "debugging":String
bug.rb:1> "debugging".<<is_annoying>>
	from /Users/eggegg/bug.rb:1:in `<top (required)>'
	...
```

## Inspecting error

### Input

```ruby
class Rocket
  def launch
    @reason = "Bugs invasion"
    raise "Engine Fail"
  end
end

Rocket.debug!
rocket = Rocket.new
rocket.watch_error "Engine Fail"
rocket.launch
```

### Output

    >>>>> Error received:
    "Engine Fail"
    >>>>>
    #<Rocket:0(0)>> @reason
    => "Bugs invasion"
    #<Rocket:0(0)>>

## Showing the require path
```ruby
irb(main):001:0> require 'defly'
=> true
irb(main):002:0> require 'shoulda', :verbose => true
shoulda cannot be required
LoadError: no such file to load -- shoulda
  from /Users/eggegg/.rvm/rubies/ruby-1.9.2-p290/lib/ruby/site_ruby/1.9.1/rubygems/custom_require.rb:36:in `require'
  from /Users/eggegg/.rvm/rubies/ruby-1.9.2-p290/lib/ruby/site_ruby/1.9.1/rubygems/custom_require.rb:36:in `require'
  from /Users/eggegg/.rvm/gems/ruby-1.9.2-p290/gems/defly-0.2.0/lib/defly/require_path.rb:23:in `require'
  from (irb):2
  from /Users/eggegg/.rvm/rubies/ruby-1.9.2-p290/bin/irb:16:in `<main>'
irb(main):003:0> require 'rdoc', :verbose => true
Requiring /Users/eggegg/.rvm/rubies/ruby-1.9.2-p290/lib/ruby/1.9.1/rdoc.rb
=> true
```

## Copyright

Copyright (c) 2011 Andrew Liu. See LICENSE.txt for
further details.
