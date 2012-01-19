module TimeWindowDropCollector::Config
  def self.extract( &block )
    @opts = {}
    instance_eval( &block )
    @opts
  end

  def self.client( type, *opts )
    @opts[:client] = type
    @opts[:client_opts] = opts
  end

  def self.window( seconds )
    @opts[:window] = seconds
  end

  def self.slices( num )
    @opts[:slices] = num
  end
end