package iris.ssrs;

import iris.ssrs.api.ArrayOfProperty;
import iris.ssrs.api.ArrayOfWarning;
import iris.ssrs.api.CredentialRetrievalEnum;
import iris.ssrs.api.DataSourceDefinition;
import iris.ssrs.api.ItemTypeEnum;
import iris.ssrs.api.ReportingService2005;
import iris.ssrs.api.ReportingService2005Soap;
import iris.ssrs.api.Warning;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.logging.Logger;
import javax.xml.namespace.QName;

@SuppressWarnings( { "UnusedDeclaration" } )
public class SSRS
{
  /*
  public static void main( final String[] args )
     throws Exception
  {
     final ConsoleHandler handler = new ConsoleHandler();
     handler.setLevel( Level.FINEST );
     SSRS.LOG.setLevel( Level.FINEST );
     SSRS.LOG.addHandler( handler );
     SSRS.LOG.setUseParentHandlers( false );

     final SSRS ssrs = new SSRS( "/PD42/DEV" );
     ssrs.delete( "/" );
     ssrs.mkdir( "Foo" );

     ssrs.mkdir( "DataSources" );
     ssrs.createSQLDataSource( "/DataSources/MyDataSource",
                               "MyServer",
                               "MyDatabase",
                               "MyUsername",
                               "MyPassword" );
     ssrs.mkdir( "Funky/Chicken" );
     ssrs.delete( "Foo2" );
     ssrs.createReport( "Funky/Chicken/ChickPeasAreNice", new File( args[ 0 ] ) );
  }
  */
  private static final Logger LOG = Logger.getLogger( SSRS.class.getName() );
  private static final String BASE_URL = "/Auto";
  private static final String PATH_SEPARATOR = "/";

  private final ReportingService2005Soap _soap;
  private final String _prefix;

  public SSRS( final String prefix )
  {
    if ( null == prefix )
    {
      throw new NullPointerException( "prefix" );
    }
    _prefix = prefix;
    final QName qName =
      new QName( "http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices",
                 "ReportingService2005" );
    final ReportingService2005 service =
      new ReportingService2005( ReportingService2005.class.getResource( "ReportService2005.wsdl" ), qName );
    _soap = service.getReportingService2005Soap();
  }

  public void createSQLDataSource( final String path,
                                   final String connectionString )
  {
    final DataSourceDefinition definition = new DataSourceDefinition();
    definition.setConnectString( connectionString );
    definition.setEnabled( true );
    definition.setExtension( "SQL" );
    definition.setImpersonateUser( false );
    definition.setPrompt( null );
    definition.setCredentialRetrieval( CredentialRetrievalEnum.NONE );
    definition.setWindowsCredentials( false );
    createDataSource( path, definition );
  }

  public void createDataSource( final String path,
                                final DataSourceDefinition definition )
  {
    LOG.info( "Creating DataSource " + path + " with CS " + definition.getConnectString() );
    final String physicalName = toPhysicalFileName( path );
    final String reportName = filenameFromPath( physicalName );
    final String reportDir = dirname( physicalName );

    final ItemTypeEnum type = _soap.getItemType( physicalName );
    if ( ItemTypeEnum.UNKNOWN != type )
    {
      final String s = "Can not create data source as path " + path + " exists and is of type " + type + ".";
      throw new IllegalStateException( s );
    }
    else
    {
      _soap.createDataSource( reportName, reportDir, false, definition, new ArrayOfProperty() );
    }
  }

  public void createReport( final String path, final File file )
  {
    LOG.info( "Creating Report " + path + " from file " + file.getAbsolutePath() );
    final String physicalName = toPhysicalFileName( path );
    LOG.fine( "Creating Report with symbolic item " + path + " as " + physicalName );
    final ItemTypeEnum type = _soap.getItemType( physicalName );
    if ( ItemTypeEnum.UNKNOWN != type )
    {
      final String s = "Can not create report as path " + physicalName + " exists and is of type " + type + ".";
      throw new IllegalStateException( s );
    }
    else
    {
      final byte[] bytes = readFully( path, file );
      final String reportName = filenameFromPath( physicalName );
      final String reportDir = dirname( physicalName );
      LOG.finer( "Invoking createReport(name=" + reportName + ",parentDir=" + reportDir + ")" );
      final ArrayOfWarning warnings =
        _soap.createReport( reportName, reportDir, true, bytes, new ArrayOfProperty() );

      if ( null != warnings )
      {
        final String message =
          "createReport(name=" + reportName + ",parentDir=" + reportDir + ") from " + file.getAbsolutePath();
        logWarnings( message, warnings );
      }
    }
  }

  public void delete( final String path )
  {
    LOG.info( "Deleting item " + path );
    final String physicalName = toPhysicalFileName( path );
    LOG.fine( "Deleting symbolic item " + path + " as " + physicalName );
    final ItemTypeEnum type = _soap.getItemType( physicalName );
    if ( ItemTypeEnum.UNKNOWN == type )
    {
      LOG.finer( "Skipping invocation of deleteItem(item=" + physicalName + ") as item does not exist." );
    }
    else
    {
      LOG.finer( "Invoking deleteItem(item=" + physicalName + ")" );
      _soap.deleteItem( physicalName );
    }
  }

  public void mkdir( final String filePath )
  {
    LOG.info( "Creating dir " + filePath );
    final String physicalName = toPhysicalFileName( filePath );
    LOG.fine( "Creating symbolic dir " + filePath + " as " + physicalName );
    final StringBuilder path = new StringBuilder();
    for ( final String dir : physicalName.substring( 1 ).split( PATH_SEPARATOR ) )
    {
      final String parentDir = ( path.length() == 0 ) ? PATH_SEPARATOR : path.toString();
      final ItemTypeEnum type = _soap.getItemType( join( path.toString(), dir ) );
      if ( ItemTypeEnum.UNKNOWN == type )
      {
        LOG.finer( "Invoking createFolder(dir=" + dir + ",parentDir=" + parentDir + ")" );
        _soap.createFolder( dir, parentDir, new ArrayOfProperty() );
      }
      else if ( ItemTypeEnum.FOLDER != type )
      {
        final String s = "Path " + path + " exists and is not a folder but a " + type;
        throw new IllegalStateException( s );
      }
      else
      {
        final String message =
          "Skipping invocation of createFolder(dir=" + dir + ",parentDir=" + parentDir + ") as folder exists";
        LOG.finer( message );
      }
      path.append( PATH_SEPARATOR );
      path.append( dir );
    }
  }

  private String filenameFromPath( final String path )
  {
    final int index = path.lastIndexOf( PATH_SEPARATOR );
    if ( -1 == index )
    {
      return path;
    }
    else
    {
      return path.substring( index + 1 );
    }
  }

  private String dirname( final String path )
  {
    final int index = path.lastIndexOf( PATH_SEPARATOR );
    if ( -1 == index )
    {
      return "";
    }
    else
    {
      return path.substring( 0, index );
    }
  }

  private String join( final String path, final String name )
  {
    return path + PATH_SEPARATOR + name;
  }

  private String toPhysicalFileName( final String name )
  {
    return nameComponent( BASE_URL ) + nameComponent( _prefix ) + nameComponent( name );
  }

  private String nameComponent( final String name )
  {
    if ( 0 == name.length() || PATH_SEPARATOR.equals( name ) )
    {
      return "";
    }
    else if ( name.startsWith( PATH_SEPARATOR ) )
    {
      return name;
    }
    else
    {
      return PATH_SEPARATOR + name;
    }
  }


  private void logWarnings( final String message,
                            final ArrayOfWarning warnings )
  {
    for ( final Warning warning : warnings.getWarning() )
    {
      LOG.warning( "Action '" + message + "' resulted in warning " +
                   " Code=" + warning.getCode() +
                   " ObjectName=" + warning.getObjectName() +
                   " ObjectType=" + warning.getObjectType() +
                   " Severity=" + warning.getSeverity() +
                   " Message=" + warning.getMessage() );
    }
  }

  private byte[] readFully( final String name, final File file )
  {
    if ( !file.exists() )
    {
      final String message = "Report file " + file.getAbsolutePath() + " for " + name + " does not exist.";
      throw new IllegalStateException( message );
    }
    try
    {
      final byte[] bytes = new byte[(int) file.length()];
      new DataInputStream( new FileInputStream( file ) ).readFully( bytes );
      return bytes;
    }
    catch ( IOException e )
    {
      throw new IllegalStateException( "Unable to load report file " + file.getAbsolutePath() );
    }
  }
}