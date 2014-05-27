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

Begin by configuring a model.

```ruby
class ConversionFunnel < Mixpannenkoek::Base
  set_api_key 'MY_API_KEY'
  set_api_secret 'MY_API_SECRET'
  set_endpoint 'funnels'
  
  default_scope { set(funnel_id: 123456) }
end
```

Build up a query with `where`, `group`, and `set`.

```ruby
ConversionFunnel.where(date: 31.days.ago..1.day.ago)

ConversionFunnel.where(date: 31.days.ago..1.day.ago).where(user_id: 123).set(interval: 50).group('traffic_source')
```

Operate on the query results fluently

```ruby
ConversionFunnel.where(date: 31.days.ago..1.day.ago).map { |date,data| data['steps'].last['count'] }
#=> [1, 4, 2]
```

Organize your query models with default scopes. Default scopes are heritable, so they will be automatically be applied to subclasses.
```ruby
class ConversionFunnel < Mixpannenkoek::Base
  default_scope { set(interval: 50) }
  default_scope { where(user_type: 'visitor') }
end

# default scopes are heritable
# (GroupedConversionFunnel will get the default scopes
# of ConversionFunnel, in addition to its own)
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
