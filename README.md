# Pratka

Ruby client for Bulgarian courier APIs. Supported couriers:

- [Econt](https://www.econt.com/developers/)
- [Speedy](https://api.speedy.bg/web-api.html)

The gem is in early development and does not have a public API yet.

## Installation

Until the first release, install from GitHub:

```ruby
gem "pratka", github: "tripplesteel/pratka"
```

## Development

```bash
bin/setup          # install dependencies
bundle exec rake   # run specs and RuboCop
bin/console        # IRB session with the gem loaded
```

To release a new version, update `lib/pratka/version.rb` and `CHANGELOG.md`, then run `bundle exec rake release`. That task tags the commit, pushes the tag and publishes the gem to [rubygems.org](https://rubygems.org).

## License

[MIT](LICENSE.txt)
