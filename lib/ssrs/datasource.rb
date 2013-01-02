module SSRS
  class DataSource
    BASE_PATH = 'DataSources'
    attr_accessor :name, :host, :instance, :database, :datasource_id, :username, :password

    def initialize(name)
      self.name = name
      self.datasource_id = SecureRandom.uuid.to_s
    end

    def host_spec
      "#{self.host}#{self.instance.nil? ? '' : '\\'}#{self.instance}"
    end

    def symbolic_name
      "#{DataSource::BASE_PATH}/#{self.name}"
    end

    def connection_string
      auth_details = unless ( self.username || self.password )
        'Integrated Security=SSPI'
      else
        "User Id=#{self.username};Password=#{self.password}"
      end
      "Data Source=#{self.host_spec};Initial Catalog=#{self.database};#{auth_details};"
    end

    def write(file)
      file.write <<XML
<RptDataSource xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <Name>#{self.name}</Name>
  <ConnectionProperties>
    <Extension>SQL</Extension>
    <ConnectString>#{connection_string}</ConnectString>
  </ConnectionProperties>
  <DataSourceID>#{self.datasource_id}</DataSourceID>
</RptDataSource>
XML
    end
  end  
end