# tilt-prawn
[![Build Status](https://travis-ci.org/fengb/tilt-prawn.png?branch=master)](https://travis-ci.org/fengb/tilt-prawn)

Adds support for rendering [Prawn](http://prawn.majesticseacreature.com/) templates using [Tilt](https://github.com/rtomayko/tilt).

## Installation

Add this line to your application's Gemfile:

    gem 'tilt-prawn'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tilt-prawn

## Usage

Create a Prawn template file with a `.prawn` extension

Example, in `hello.prawn`:

```ruby
pdf.text "Hello #{name}"
```

Then, render the template with Ruby:

```ruby
require 'tilt/prawn'

template = Tilt.new('hello.prawn')
puts template.render(nil, name: 'Bob')
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
