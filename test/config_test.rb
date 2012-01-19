require_relative "test_helper"

class ConfigTest < Test::Unit::TestCase
  def setup
    TimeWindowDropCollector::Logger.stubs( :log )
  end

  def test_config
    config =
      TimeWindowDropCollector::Config.extract do
        client "client", "client_opt1", "client_opt2"
        window "window"
        slices "slices"
      end

    assert_equal( "client", config[:client] )
    assert_equal( ["client_opt1", "client_opt2"], config[:client_opts] )
    assert_equal( "window", config[:window] )
    assert_equal( "slices", config[:slices] )
  end
end
