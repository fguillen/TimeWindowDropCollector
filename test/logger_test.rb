require_relative "test_helper"

class LoggerTest < MiniTest::Test
  def setup
    @old_env = ENV["TWDC_DEBUG"]
    ENV["TWDC_DEBUG"] = "on"
  end

  def teardown
    ENV["TWDC_DEBUG"] = @old_env
  end

  def test_log
    IO.any_instance.expects( :puts ).with( "[TWDC 2001-02-01 04:05:06] hello!" )

    Delorean.time_travel_to( "2001-02-01 04:05:06" ) do
      TimeWindowDropCollector::Logger.log( "hello!" )
    end
  end
end
