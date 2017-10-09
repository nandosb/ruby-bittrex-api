# Bittrex

Basic interaction with Bittrex API
See API details here: https://bittrex.com/home/api

## Installation

Add this line to your application's Gemfile:

    gem 'bittrex', git:'https://github.com/nandosb/ruby-bittrex-api'

And then execute:

    $ bundle

## Usage

    client = Bittrex.new('<your_key>', '<your_secret>')
    markets = client.markets()

## Running unit tests

    cd /your/app/path
    DEBUG=1 rake test

WARNING: Running unit test will perform REAL actions on Bittrex

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
