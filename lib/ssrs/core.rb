module SSRS
  def self.info(message)
    defined?(JRUBY_VERSION) ? Java::OrgRealityforgeSqlserverSsrs::SSRS.info(message) : Java.org.realityforge.sqlserver.ssrs.SSRS.info(message)
  end
end
