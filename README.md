# RoundCloud

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/round_cloud`. To experiment with that code, run `bin/console` for an interactive prompt.

## Installation

Add this line to your gemspec file:

```ruby
spec.add_development_dependency 'round_cloud'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install round_cloud

## Usage

add this section to your circleci.yml
```yaml
deployment:
  feature_branch:
    branch: /^t.*/
    commands:
      - bundle exec round_cloud release --pre

  stable:
    branch: master
    commands:
      - bundle exec round_cloud release
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment. Run `bundle exec round_cloud` to use the gem in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/saks/round_cloud.

