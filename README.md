# Time Window Drop Collector

System to keep record of an _amount_ for a concrete duration.

With _Time Window Drop Collector_ you can define a **maximun time** you want to keep the record.

You can also keep record for **different keys**.

## How to use

### Install

    gem install time_window_drop_collector

### Config

These are the default values

    twdc =
      TimeWindowDropCollector.new do
        client :memcache, "localhost:11211"     # underneeth client
        window 600                              # in seconds
        slices 10                               # one slice every minute
      end

### Use

    twdc.drop( "id1" )
    twdc.drop( "id1" )
    twdc.drop( "id2" )
    twdc.drop( ["id1", "id2"] )

    twdc.count( "id1" )  # => 3

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

At the moment this wrapper does not support auto-key-clean so the stored keys will be there until anyone delete them.