# rptman

This tool includes code and a suite of rake tasks for uploading SSRS
reports to a server. The tool can also generate project files for
the "SQL Server Business Intelligence Development Studio".

## Installation

The extension is packaged as a ruby gem named 'rptman', consult the ruby
gems installation steps but typically it is

    $ gem install rptman

## Basic Overview

Reports are stored in sub-directories of a <report-dir>. The filename
of the report must end with ".rdl". The directory hierarchy on the local
file system is mirrored on the SSRS server during an upload. So if a file
exists with the name

    <report-dir>/IRIS/Coordination/Tour Of Duty Report.rdl

It will be uploaded to the SSRS server with the path

    /IRIS/Coordination/Tour Of Duty Report

Every top level directory on the local file system that includes a report
file is deleted when it during the upload process. So in the above scenario
the /IRIS directory on SSRS server is deleted prior to uploading the
directory. It is assumed that every report in a particular hierarchy is
stored in one location.

The tool can also create data source definitions and these are placed in a
directory named "/DataSources".

The gem supports prefixing all paths with when uploading to the SSRS server.
It is possible to prefix all reports managed by this tool with /Auto so as
to distinguish them from reports uploaded through other means. If multiple
people are working of the same SSRS instance it is also possible to decorate
the prefix with a username or environment. (i.e. /Auto/PD42/DEV)

The configuration data for determining which SSRS instance and prefix to use
is in a yaml file with a format described below. The easiest way to use the
tool is to create a ruby script such as the following;

    gem 'rptman'

    require 'rptman'

    # The configuration file
    SSRS::Config.config_filename = "database.yml"

    # The directory in which the reports are stored
    SSRS::Config.reports_dir = "reports"

    # Define a data source named IRIS_CENTRAL that has
    # configration data stored under the key 'central'
    SSRS::Config.define_datasource('IRIS_CENTRAL','central')

    # actually run the tool
    SSRS::Shell.run

The script can then be run with a -h parameter to see the various options.

## Rake/Buildr integration

Rptman also integrates with [Buildr](http://buildr.apache.org) or [Rake](http://rake.rubyforge.org/)
by defining the following tasks:

    $ buildr rptman:ssrs:delete                       # Delete reports from the SSRS server
    $ buildr rptman:ssrs:upload                       # Upload reports and datasources to SSRS server
    $ buildr rptman:ssrs:upload_reports               # Upload just reports to SSRS server
    $ buildr rptman:vs_projects:clean                 # Clean generated Visual Studio/BIDS projects
    $ buildr rptman:vs_projects:generate              # Generate MS VS projects for each report dir

## Configuration Format

The configuration is stored in a yaml file. The configuration file format
allows for multiple "environments" (a.k.a. configuration) in one file. Most
configuration files will have "development" and "production" environments.
There must be one section for each SQL Server or SSRS instance. Each section
is named "<key>_<environment>" where the key for SSRS servers is "ssrs". The
key for SQL Server instances must correspond to the key specified in the
invocation of "SSRS::Config.define_datasource(<name>,<key>)" above. If nil is
supplied as the <key> parameter then a section named "<environment>" is used.

The SSRS server must specify the report_target and prefix keys. The SQL Server
instances must specify the database and host keys and may optionally specify
the username, password and instance keys. If username and password are not
specified then integrated security is used.

Here is an example configuration file:

    ssrs_development:
      report_target: http://ssrs-dev.example.com/SSRS01_WS
      prefix: /Auto/PD42/DEV

    central_development:
      database: PD42_IRIS_CENTRAL_DEV
      username: MyUsername
      password: MyPassword
      host: sqlserver-dev.example.com
      instance: myinstance

    ssrs_production:
      report_target: http://ssrs.example.com/SSRS01_WS
      prefix: /Auto
      domain: example.com
      username: MyUsername
      password: MyPassword

    central_production:
      database: IRIS_CENTRAL
      username: MyUsername
      password: MyPassword
      host: sqlserver.example.com
      instance: myinstance

### Project Configurations

The "SQL Server Business Intelligence Development Studio" allows each project to
have zero or more "Configurations". These configurations roughly correspond to the
concept of environments in the above configuration.

By default the tool creates a "Debug" and "DebugLocal" configuration that use the
settings from the "development" environment. The "DebugLocal" configuration is
differentiated in that it builds and deploys the report by default. The tool will
also create a "Release" configuration that use the settings from the "production"
environment if a "production" environment exists in the configuration file.

## Credit

The gem was initially developed by StockSoftware for use in the Department
of Sustainability and Environment, Victoria, Australia.
