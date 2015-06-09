module SSRS
  def self.info(message)
    Java::IrisSSRS::SSRS.info(message)
  end
end
Java::IrisSSRS::SSRS.setupLogger(false)
