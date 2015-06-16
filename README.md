# Gtt::Downloader

Download archive.zip from Google Translator Toolkit.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gtt-downloader'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gtt-downloader

Gtt::Downloader requires chromdriver:

    $ brew install chromedriver

## Usage

    $ LABEL="example" GMAIL_ADDR="your gmail address" GMAIL_PASS="your gmail pass" gtt-downloader

## TODO

- [x] download archive.zip(multiple files)
- [ ] download single file

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yasslab/gtt-downloader. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

Copyright &copy; 2015 [YassLab](http://yasslab.jp)

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
