module TimeWindowDropCollector::Logger
  def self.log( message )
    puts "[TWDC #{Time.now.strftime( "%F %T" )}] #{message}" if ENV["TWDC_DEBUG"]
  end
end