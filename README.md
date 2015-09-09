# PvOutputWrapper

As the name suggests, this gem wraps parts of the www.pvoutput.org [public api](http://www.pvoutput/api) so that you can easily call it from within your Ruby program. Results are available in raw and formatted form.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pv_output_wrapper'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pv_output_wrapper

## Usage

Methods names and parameters are the same as those defined by pvoutput.org. Documentation for this gem is effectively the same as that which is found at [pvoutput.org](http://www.pvoutput/api).

### Example
```ruby
request = PvOutputWrapper::Request.new('pvoutput_api_key', 'pvoutput_system_id')
params = { :df => 20150101 }
# Returns a PvOutputWrapper::Response instance
response = request.get_statistic(params)
# Returns a hash
parsed_statistics = response.body.parse
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/pv_output_wrapper.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

