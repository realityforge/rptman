module SSRS
  def self.info(message)
    Java.iris.ssrs.SSRS.info(message)
  end
end
