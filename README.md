# Mixpannenkoek

This gem implements a fluent query interface for mixpanel_client.

## Installation

Add this line to your application's Gemfile:

    gem 'mixpannenkoek'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mixpannenkoek

## Usage

### Configure a model

```ruby
class ConversionFunnel < Mixpannenkoek::Base
  set_api_key 'MY_API_KEY'
  set_api_secret 'MY_API_SECRET'
  set_endpoint 'funnels'
  
  default_scope { set(funnel_id: 123456) }
end
```

### Query your data.

```ruby
ConversionFunnel.where(date: 31.days.ago..1.day.ago)
```

### Operate on your data

```ruby
ConversionFunnel.where(date: 31.days.ago..1.day.ago).map { |date,data| data['steps'].last['count'] }
#=> [1, 4, 2]
```

### Slice and dice your data

```ruby
ConversionFunnel.where(date: 31.days.ago..1.day.ago).where(user_id: 123).set(interval: 50).group('traffic_source')
```

### Default scopes
```ruby
class ConversionFunnel < Mixpannenkoek::Base
  default_scope { set(interval: 50) }
  default_scope { where(user_type: 'visitor') }
end

# are heritable
class GroupedConversionFunnel < ConversionFunnel
  default_scope { group('traffic_source') }
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
