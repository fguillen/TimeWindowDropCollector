module TimeWindowDropCollector::Logger
  def self.log( message )
    puts "[TWDC #{Time.now.strftime( "%F %T" )}] #{message}"
  end
end