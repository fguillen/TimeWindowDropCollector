# Time Window Drop Collector

System to keep record of an _amount_ for a concrete duration.

With _Time Window Drop Collector_ you can define a **maximun time** you want to keep the record.

You can also keep record for **different keys**.

## How to use

### Install

    gem install time_window_drop_collector

### Config

    twdc =
      TimeWindowDropCollector.new do
        client <client>, <client_opts>     # underneeth client
        window <seconds>                   # in seconds
        slices <num of slices>             # one slice every minute
      end

These are the default values

    twdc =
      TimeWindowDropCollector.new do
        client :memcache, "localhost:11211"     # underneeth client
        window 600                              # in seconds
        slices 10                               # one slice every minute
      end

#### Client
Can be:

* :memcache
* :redis
* :rails
* :mock

### Use

    twdc.drop( "id1" )
    twdc.drop( "id1" )
    twdc.drop( "id2" )
    ts = twdc.drop( "id1", 4 )

    twdc.count( "id1" )  # => 6
    twdc.count( "id2" )  # => 1

    twdc.pick( ts, "id1", 2)
    twdc.count( "id1" )  # => 4

    # after 10 minutes
    twdc.count( "id1" )  # => 0

## Cache clients wrappers

Now we have implementation for 3 diferent underneeth cache clients.

### Memcache

It uses the Dalli Client for memcache.

    twdc =
      TimeWindowDropCollector.new do
        client :memcache, "localhost:11211"
      end

### Rails cache

It uses the `Rails.cache` accesible

    twdc =
      TimeWindowDropCollector.new do
        client :rails_cache
      end


### Redis

    twdc =
      TimeWindowDropCollector.new do
        client :redis, { :host => "host", :port => "port" }
      end

