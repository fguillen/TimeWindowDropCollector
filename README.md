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

Now we have implementation for 3 diferent underneeth cache clients. The implementations of these wrappers just have to define the next methods:

