# Mixpannenkoek

This gem implements a fluent query interface for the [mixpanel_client](https://github.com/keolo/mixpanel_client) gem.

[![Code Climate](https://codeclimate.com/github/Springest/mixpannenkoek.png)](https://codeclimate.com/github/Springest/mixpannenkoek)

## Installation

Add this line to your application's Gemfile:

    gem 'mixpannenkoek'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mixpannenkoek

## Usage

Begin by creating and configuring a model. In Rails you might place this in `app/models/conversion_funnel.rb`. You *must* set the api_key, api_secret, and endpoint. These properties are heritable, so in the following example, `OtherFunnel` will have the api_key, api_secret and endpoint already set.

```ruby
class Funnel::Base < Mixpannenkoek::Base
  set_api_key 'MY_API_KEY'
  set_api_secret 'MY_API_SECRET'
  set_endpoint 'funnels' # or any other endpoint
end

class Funnel::Conversions < Funnel::Base
  default_scope { set(funnel_id: 123456) }
end
```

With mixpanel_client, you might run a query like this:

```ruby
client = Mixpanel::Client.new(
  api_key:    'MY_API_KEY', 
  api_secret: 'MY_API_SECRET'
)

data = client.request(
  'funnels',
  funnel_id: 123456,
  from_date: '2014-01-01',
  to_date:   '2014-01-31',
  interval:  31,
  on:        'properties["traffic_source"]',
  where:     'properties["user_type"] = "visitor" AND properties["landing_page"] = "homepage"',
)
```

With mixpannenkoek, you would write it like this (making use of the models defined above):

```ruby
Funnel::Conversions.where(date: Date.parse('2014-01-01')..Date.parse('2014-01-31')).set(interval: 31).group('traffic_source').where(user_type: 'visitor').where(landing_page: 'homepage')
```

`where` allows you to easily build the `where` parameter of the request.

`group` corresponds to the `on` parameter.

`set` sets any other parameters in the request (in this case, `funnel_id` is mandatory).

This gem also supports `default_scope`, which is also heritable. Some of the parameters above might instead be set in the model, to save time.

```ruby
class Funnel::Conversions < Funnel::Base
  default_scope { set(funnel_id: 123456) }
  default_scope { set(interval: 31) }
  default_scope { where(user_type: 'visitor') }
end
```

Building up the query then becomes a little bit easier:

```ruby
Funnel::Conversions.where(date: Date.parse('2014-01-01')..Date.parse('2014-01-31')).group('traffic_source').where(landing_page: 'homepage')
```

Note: you are not required to set the `funnel_id` in the model itself. The following queries are possible:

```ruby
Funnel::Base.set(funnel_id: 987654).where(date: range)
```

Operating on the response data is also fluent. Just call a method (including `[]`). This will trigger a request to the mixpanel API and make the response data available:

```ruby
Funnel::Conversions.where(date: 31.days.ago..1.day.ago).response_data
#=> {"2010-05-24"=>
  {"analysis"=>
    {"completion"=>0.0646793595800525,
     "starting_amount"=>762,
     "steps"=>3,
     "worst"=>2},
   "steps"=>
    [{"count"=>762,
      "goal"=>"pages",
      "overall_conv_ratio"=>1.0,
      "step_conv_ratio"=>1.0},
     {"count"=>69,
      "goal"=>"View signup",
      "overall_conv_ratio"=>0.09055118110236221,
      "step_conv_ratio"=>0.09055118110236221},
     {"count"=>10,
      "goal"=>"View docs",
      "overall_conv_ratio"=>0.0646793595800525,
      "step_conv_ratio"=>0.7142857142857143}]},
 "2010-05-31"=>
  {"analysis"=>
    {"completion"=>0.12362030905077263,
     "starting_amount"=>906,
     "steps"=>2,
     "worst"=>2},
   "steps"=>
    [{"count"=>906,
      "goal"=>"homepage",
      "overall_conv_ratio"=>1.0,
      "step_conv_ratio"=>1.0},
     {"count"=>112,
      "goal"=>"View signup",
      "overall_conv_ratio"=>0.12362030905077263,
      "step_conv_ratio"=>0.12362030905077263}]}}
      
Funnel::Conversions.where(date: 31.days.ago..1.day.ago)['2010-05-24']['steps'][0]['count']
#=> 762

Funnel::Conversions.where(date: 31.days.ago..1.day.ago).map { |date,data| data['steps'].last['count'] }
#=> [10, 112]
```

Query objects are also immutable. So it's possible to organize your code in the following manner:

```ruby
query_1 = Funnel::Conversions.where(date: 31.days.ago..1.day.ago)
query_2 = query_1.where(traffic_source: 'google') # this leaves query_1 unchanged
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
