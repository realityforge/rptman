module SSRS
  def self.info(message)
    Java::OrgRealityforgeSqlserverSsrs::SSRS.info(message)
  end
end
