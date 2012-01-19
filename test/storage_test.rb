require File.expand_path( File.dirname( __FILE__ ) + '/../../test_helper' )

class StorageTest <  ActiveSupport::TestCase
  context "DeliveryWindow::Storage" do

    setup do
    end

    context "keys" do
      should "return proper key when time is present" do
        timestamp = Time.new( 2012,1,2,3,4 )
        assert_equal( "delivery_window_666_201201020304", DeliveryWindow::Storage.key_for( 666, timestamp ))
      end

      should "return proper key when time is not present" do
        DeliveryWindow::Storage.stubs( :timestamp ).returns( Time.new( 2012,4,3,2,1 ))
        assert_equal( "delivery_window_666_201204030201", DeliveryWindow::Storage.key_for( 666 ))
      end

      should "return 10 keys for the last 10 minutes" do

          keys =  ["delivery_window_666_201201031416",
                   "delivery_window_666_201201031415",
                   "delivery_window_666_201201031414",
                   "delivery_window_666_201201031413",
                   "delivery_window_666_201201031412",
                   "delivery_window_666_201201031411",
                   "delivery_window_666_201201031410",
                   "delivery_window_666_201201031409",
                   "delivery_window_666_201201031408",
                   "delivery_window_666_201201031407"]

        Delorean.time_travel_to( '2012-01-03 15:16' ) do
          assert_equal( keys, DeliveryWindow::Storage.keys_for( 666 ))
        end
      end
    end

    context "adding to the store" do
      should "add offer_ids to the store" do
        DeliveryWindow::Storage.expects( :incr ).times( 5 )
        DeliveryWindow::Storage.add( [1, 2, 3, 4, 5] )
      end

      should "increment the count for a given offer" do
        DeliveryWindow::Storage.expects( :key_for ).with( 666 ).returns( "key" )
        DeliveryWindow::Storage.client.expects( :incr ).with( "key" )
        DeliveryWindow::Storage.incr( 666 )
      end
    end

    should "calculate the count for a given offer_id based on the response from storage" do
      keys = [
        "delivery_window_666_201201031416",
        "delivery_window_666_201201031415",
        "delivery_window_666_201201031414",
        "delivery_window_666_201201031413",
        "delivery_window_666_201201031412"
      ]

      values = [1, 2, 3, 4, 5]

      DeliveryWindow::Storage.expects( :keys_for ).with( 666 ).returns( keys )
      DeliveryWindow::Storage.client.expects( :values_for ).with( keys ).returns( values )

      assert_equal( 15, DeliveryWindow::Storage.count( 666 ))
    end

    context "integration" do
      should "count" do
        offer_1 = 1
        offer_2 = 2
        offer_3 = 3

        DeliveryWindow::Storage.add( [offer_1] )
        DeliveryWindow::Storage.add( [offer_2] )
        DeliveryWindow::Storage.add( [offer_3] )
        DeliveryWindow::Storage.add( [offer_2] )
        DeliveryWindow::Storage.add( [offer_1, offer_2] )

        assert_equal( 2, DeliveryWindow::Storage.count( offer_1 ))
        assert_equal( 3, DeliveryWindow::Storage.count( offer_2 ))
        assert_equal( 1, DeliveryWindow::Storage.count( offer_3 ))
      end

      should "keep store of the count for 10 minutes" do

        offer_1 = 1

        Delorean.time_travel_to( '2012-01-03 11:00' ) do
          DeliveryWindow::Storage.add( [offer_1] )
        end

        Delorean.time_travel_to( '2012-01-03 11:01' ) do
          DeliveryWindow::Storage.add( [offer_1] )
        end

        Delorean.time_travel_to( '2012-01-03 11:02' ) do
          DeliveryWindow::Storage.add( [offer_1] )
        end

        Delorean.time_travel_to( '2012-01-03 11:03' ) do
          DeliveryWindow::Storage.add( [offer_1] )
        end

        Delorean.time_travel_to( '2012-01-03 11:04' ) do
          DeliveryWindow::Storage.add( [offer_1] )
        end

        Delorean.time_travel_to( '2012-01-03 11:05' ) do
          DeliveryWindow::Storage.add( [offer_1] )
        end

        Delorean.time_travel_to( '2012-01-03 11:06' ) do
          DeliveryWindow::Storage.add( [offer_1] )
        end

        Delorean.time_travel_to( '2012-01-03 11:07' ) do
          DeliveryWindow::Storage.add( [offer_1] )
        end

        Delorean.time_travel_to( '2012-01-03 11:08' ) do
          DeliveryWindow::Storage.add( [offer_1] )
        end

        Delorean.time_travel_to( '2012-01-03 11:09' ) do
          DeliveryWindow::Storage.add( [offer_1] )
        end

        Delorean.time_travel_to( '2012-01-03 11:10' ) do
          DeliveryWindow::Storage.add( [offer_1] )
        end

        # counters
        Delorean.time_travel_to( '2012-01-03 10:59' ) do
          assert_equal( 0, DeliveryWindow::Storage.count( offer_1 ))
        end

        Delorean.time_travel_to( '2012-01-03 11:00' ) do
          assert_equal( 1, DeliveryWindow::Storage.count( offer_1 ))
        end

        Delorean.time_travel_to( '2012-01-03 11:05' ) do
          assert_equal( 6, DeliveryWindow::Storage.count( offer_1 ))
        end

        Delorean.time_travel_to( '2012-01-03 11:10' ) do
          assert_equal( 10, DeliveryWindow::Storage.count( offer_1 ))
        end

        Delorean.time_travel_to( '2012-01-03 11:15' ) do
          assert_equal( 5, DeliveryWindow::Storage.count( offer_1 ))
        end

        Delorean.time_travel_to( '2012-01-03 11:19' ) do
          assert_equal( 1, DeliveryWindow::Storage.count( offer_1 ))
        end

        Delorean.time_travel_to( '2012-01-03 11:20' ) do
          assert_equal( 0, DeliveryWindow::Storage.count( offer_1 ))
        end
      end

     # should "handle 30000 req/min over 3000 offers XXX" do

     #    offer_ids = ( 1..10 ).to_a

     #    DeliveryWindow.unstub( :store )
     #    DeliveryWindow::Storage.unstub( :cache )

     #    DeliveryWindow::Storage.client.cache.flush

     #    Benchmark.bm do |x|
     #      x.report do
     #        1000.times do
     #          DeliveryWindow::RedisStore.add( offer_ids )
     #        end
     #      end

     #      x.report do
     #        1000.times do
     #          offer_ids.each do |o|
     #            DeliveryWindow::RedisStore.count( o )
     #          end
     #        end
     #      end
     #    end
     #    puts 'starting memcache'


     #    Benchmark.bm do |x|
     #      x.report do
     #        1000.times do
     #          DeliveryWindow::Storage.add( offer_ids )
     #        end
     #      end

     #      x.report do
     #        1000.times do
     #          offer_ids.each do |o|
     #            DeliveryWindow::Storage.count( o )
     #          end
     #        end
     #      end
     #    end

     #    # assert_equal( 1000, DeliveryWindow::RedisStore.count( offer_ids.sample ))
     #  end


    end
  end
end