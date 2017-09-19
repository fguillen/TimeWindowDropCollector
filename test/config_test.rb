require_relative "test_helper"

class ConfigTest < MiniTest::Test
  def setup
    TimeWindowDropCollector::Logger.stubs( :log )
  end

  def test_config
    proc =
      Proc.new do
        client "client", "client_opt1"
        window "window"
        slices "slices"
      end

    config = TimeWindowDropCollector::Config.extract( proc )

    assert_equal( "client",      config[:client] )
    assert_equal( "client_opt1", config[:client_opts] )
    assert_equal( "window",      config[:window] )
    assert_equal( "slices",      config[:slices] )
  end
end
