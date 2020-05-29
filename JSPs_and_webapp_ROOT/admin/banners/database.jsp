<%@ page language="java"
  import="com.extware.asset.Asset,
          com.extware.asset.AssetManager,
          com.extware.asset.ProcessResults,
          com.extware.utils.DatabaseUtils,
          com.extware.utils.NumberUtils,
          com.extware.utils.PreparedStatementUtils,
          com.extware.utils.PropertyFile,
          com.extware.utils.SiteUtils,
          com.extware.utils.StringUtils,
          com.extware.utils.UploadUtils,
          com.extware.user.UserDetails,
          java.net.URLEncoder,
          java.sql.Connection,
          java.sql.PreparedStatement,
          java.sql.ResultSet,
          java.sql.SQLException,
          java.util.GregorianCalendar"
%><%!

GregorianCalendar getCalendar( HttpServletRequest request, String baseName )
{
  int day   = NumberUtils.parseInt( request.getParameter( baseName + "Day" ),   -1 );
  int month = NumberUtils.parseInt( request.getParameter( baseName + "Month" ), -1 );
  int year  = NumberUtils.parseInt( request.getParameter( baseName + "Year" ),  -1 );

  if( day != -1 && month != -1 && year != -1 )
  {
    return new GregorianCalendar( year, month - 1, day );
  }

  return null;
}

%><%

UserDetails user = UserDetails.getUser( session );

if( user == null )
{
  response.sendRedirect( "/admin/login.jsp" );
  return;
}

if( !user.isAdmin() )
{
  response.sendRedirect( "/admin/blank.html" );
  return;
}

String SELECT_TYPE_INFO_SQL = "SELECT assetTypeId FROM bannerTypes WHERE bannerTypeId=?";
String INSERT_BANNER_SQL    = "INSERT INTO banners( bannerTypeId, bannerName, linkUrl, assetId, dateLive, dateRemove ) VALUES( ?, ?, ?, ?, ?, ? )";
String UPDATE_BANNER_SQL    = "UPDATE banners SET bannerTypeId=?, bannerName=?, linkUrl=?, assetId=?, dateLive=?, dateRemove=? WHERE bannerId=?";

boolean processFile = false;

if( request.getContentType() != null && request.getContentType().toLowerCase().indexOf( "multipart/form-data" ) == 0 )
{
  request = new UploadUtils( getServletConfig(), request, response );

  processFile = !( (UploadUtils)request ).isFileMissing( ( (UploadUtils)request ).getFileNumber( "file" ) );
}

boolean unpackZips  = false;

int rowsChanged  =  0;
int assetTypeId  = -1;
int bannerId     = NumberUtils.parseInt( request.getParameter( "bannerId" ),     -1 );
int bannerTypeId = NumberUtils.parseInt( request.getParameter( "bannerTypeId" ), -1 );
int assetId      = NumberUtils.parseInt( request.getParameter( "assetId" ),      -1 );

String errors     = "";
String message    = "";
String mode       = StringUtils.nullString( request.getParameter( "mode" ) ).trim();
String bannerName = StringUtils.nullString( request.getParameter( "bannerName" ) ).trim();
String linkUrl    = StringUtils.nullString( request.getParameter( "linkUrl" ) ).trim();

GregorianCalendar dateLive   = getCalendar( request, "dateLive" );
GregorianCalendar dateRemove = getCalendar( request, "dateRemove" );

PropertyFile dataDictionary = PropertyFile.getDataDictionary();

Asset asset = null;

ProcessResults processResults;

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

ps = conn.prepareStatement( SELECT_TYPE_INFO_SQL );
ps.setInt( 1, bannerTypeId );
rs = ps.executeQuery();

if( rs.next() )
{
  assetTypeId = rs.getInt( "assetTypeId" );
}

rs.close();
ps.close();

if( mode.equals( "delete" ) || ( mode.equals( "edit" ) && processFile ) )
{
  try
  {
    asset = new Asset( assetId, conn );

    String webappBaseDir = SiteUtils.getWebappRoot() + dataDictionary.getString( "dirsep" );
    String assetsFolder    = webappBaseDir + dataDictionary.getString( "asset.dir.original."   + asset.assetTypeId );
    String webassetsFolder = webappBaseDir + dataDictionary.getString( "asset.dir.proccessed." + asset.assetTypeId );

    asset.deleteFiles( assetsFolder, webassetsFolder );

    asset.deleteRow();
  }
  catch( SQLException ex )
  {
    errors += "Error deleteing asset database entry " + ex.toString();
  }
  catch( IOException ex )
  {
    errors += "Error deleteing asset files " + ex.toString();
  }
}

if( mode.equals( "add" ) || mode.equals( "edit" ) )
{
  if( processFile )
  {
    ps = conn.prepareStatement( INSERT_BANNER_SQL );
  }
  else
  {
    ps = conn.prepareStatement( UPDATE_BANNER_SQL );
  }

  PreparedStatementUtils.setInt(       ps, 1, bannerTypeId );
  PreparedStatementUtils.setString(    ps, 2, bannerName );
  PreparedStatementUtils.setString(    ps, 3, linkUrl );
  PreparedStatementUtils.setTimestamp( ps, 5, dateLive );
  PreparedStatementUtils.setTimestamp( ps, 6, dateRemove );

  if( processFile )
  {
    processResults = AssetManager.processUpload( assetTypeId, (UploadUtils)request, "file", bannerName, unpackZips );

    for( int i = 0 ; processResults != null && processResults.assets != null && i < processResults.assets.size() ; i++ )
    {
      asset = (Asset)processResults.assets.get( i );
      PreparedStatementUtils.setInt( ps, 4, asset.assetId );

      rowsChanged += ps.executeUpdate();
    }
  }
  else
  {
    PreparedStatementUtils.setInt( ps, 4, assetId );
    PreparedStatementUtils.setInt( ps, 7, bannerId );

    rowsChanged += ps.executeUpdate();
  }

  ps.close();

  if( rowsChanged == 1 )
  {
    message += "1 File processed for '" + bannerName + "' successfully.<br />";
  }
  else if( rowsChanged == 0 )
  {
    errors += "No Files processed for '" + bannerName + "'.<br />";
  }
  else
  {
    message += rowsChanged + " Files processed for '" + bannerName + "' successfully.<br />";
  }
}

if( !mode.equals( "add" ) && !mode.equals( "edit" ) && !mode.equals( "delete" ) )
{
  errors += "Invalid Operation (mode='" + mode + "', bannerId=" + bannerId + ")";
}

conn.close();

if( ( mode.equals( "add" ) || mode.equals( "edit" ) ) && !errors.equals( "" ) )
{

%><jsp:include page="edit.jsp" flush="true" >
  <jsp:param name="errors" value="<%= errors %>"/>
  <jsp:param name="message" value="<%= message %>"/>
</jsp:include><%

}
else
{
  response.sendRedirect( "index.jsp?message=" + URLEncoder.encode( message ) + "&errors=" + URLEncoder.encode( errors ) );
}

%>