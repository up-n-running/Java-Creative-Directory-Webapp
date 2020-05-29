<%@ page language="java"
  import="com.extware.asset.Asset,
          com.extware.asset.AssetManager,
          com.extware.asset.ProcessResults,
          com.extware.asset.image.PostProcess,
          com.extware.extsite.lists.ListItemFile,
          com.extware.utils.DatabaseUtils,
          com.extware.utils.NumberUtils,
          com.extware.utils.PropertyFile,
          com.extware.utils.PreparedStatementUtils,
          com.extware.utils.SiteUtils,
          com.extware.utils.StringUtils,
          com.extware.utils.UploadUtils,
          com.extware.user.UserDetails,
          java.net.URLEncoder,
          java.sql.Connection,
          java.sql.PreparedStatement,
          java.sql.ResultSet,
          java.sql.SQLException,
          java.io.IOException"
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


//String SELECT_FILE_INFO_SQL = "SELECT l.fileType, t.assetTypeId FROM listTypeAssetTypes l INNER JOIN assetTypes t ON l.assetTypeId=t.assetTypeId WHERE l.listTypeAssetTypeId=?";
String INSERT_FILE_SQL      = "INSERT INTO textPageFiles( textPageId, assetId ) VALUES( ?, ? )";
//String UPDATE_FILE_SQL      = "UPDATE listItemFiles SET listItemId=?, title=?, fileType=?, listTypeAssetTypeId=?, assetId=? WHERE listItemFileId=?";

//String UNSET_DEFAULT_FILE_TYPE_SQL = "UPDATE listItemFiles SET defaultFile='f' WHERE listItemId=?";
//String SET_DEFAULT_FILE_TYPE_SQL   = "UPDATE listItemFiles SET defaultFile='t' WHERE listItemFileId=?";

boolean processFile = false;

if( request.getContentType() != null && request.getContentType().toLowerCase().indexOf( "multipart/form-data" ) == 0 )
{
  request = new UploadUtils( getServletConfig(), request, response );
  processFile = !( (UploadUtils)request ).isFileMissing( ( (UploadUtils)request ).getFileNumber( "file" ) );
}

PropertyFile dataDictionary = PropertyFile.getDataDictionary();
PropertyFile richTextProps = new PropertyFile( "com.extware.properties.RichText" );

boolean unpackZips = false;

//int fileType            = -1;
int assetTypeId         = richTextProps.getInt( "richTextAssetTypeId" );
int rowsChanged         =  0;
int textPageId          = NumberUtils.parseInt( request.getParameter( "textPageId" ), -1 );
int assetId             = NumberUtils.parseInt( request.getParameter( "assetId" ),             -1 );
//int listTypeId          = NumberUtils.parseInt( request.getParameter( "listTypeId" ),          -1 );
//int listItemId          = NumberUtils.parseInt( request.getParameter( "listItemId" ),          -1 );
//int listItemFileId      = NumberUtils.parseInt( request.getParameter( "listItemFileId" ),      -1 );
//int listTypeAssetTypeId = NumberUtils.parseInt( request.getParameter( "listTypeAssetTypeId" ), -1 );

String assetTypeName;
String errors        = "";
String message       = "";
String mode          = StringUtils.nullString( request.getParameter( "mode" ) ).trim();
String pageName      = StringUtils.nullString( request.getParameter( "pageName" ) ).trim();
String title         = pageName + " Image";



Asset asset = null;

ProcessResults processResults;

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
//ResultSet rs;

//ps = conn.prepareStatement( SELECT_FILE_INFO_SQL );
//ps.setInt( 1, listTypeAssetTypeId );
//rs = ps.executeQuery();

//if( rs.next() )
//{
//  fileType    = rs.getInt( "fileType" );
//  assetTypeId = rs.getInt( "assetTypeId" );
//
//  unpackZips = ( fileType == ListItemFile.FILE_TYPE_INLINE );
//}

//rs.close();
//ps.close();

if( mode.equals( "delete" ) )
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

if( mode.equals( "add" ) )
{
  if( processFile )
  {
    ps = conn.prepareStatement( INSERT_FILE_SQL );

    ps.setInt(    1, textPageId );
//System.out.println( "extSite: calling AssetManager.processUpload, assetTypeId = " + assetTypeId + ", (UploadUtils)request = " + (UploadUtils)request + ", file, title = " + title + ", unpackZips = " + unpackZips );
    processResults = AssetManager.processUpload( assetTypeId, (UploadUtils)request, "file", title, unpackZips );

    for( int i = 0 ; processResults != null && processResults.assets != null && i < processResults.assets.size() ; i++ )
    {
      asset = (Asset)processResults.assets.get( i );
      ps.setInt( 2, asset.assetId );
      //message += "\n\n" + "asset = " + asset.toString() + ", id= " + asset.assetId+ "\n\n";
      rowsChanged += ps.executeUpdate();
    }

    ps.close();
  }




  if( rowsChanged == 1 )
  {
    message += "1 File processed for '" + title + "' successfully.<br />";
  }
  else if( rowsChanged == 0 )
  {
    errors += "No Files processed for '" + title + "'.<br />";
  }
  else
  {
    message += rowsChanged + " Files processed for '" + title + "' successfully.<br />";
  }
}


if( !mode.equals( "add" ) && !mode.equals( "edit" ) && !mode.equals( "delete" ) && !mode.equals( "default" ) )
{
  errors += "Invalid Operation";
}

conn.close();


%><jsp:include page="files.jsp" flush="true" >
  <jsp:param name="errors" value="<%= errors %>"/>
  <jsp:param name="message" value="<%= message %>"/>
  <jsp:param name="pageName" value="<%= pageName %>"/>
  <jsp:param name="textPageId" value="<%= textPageId %>"/>
</jsp:include><%


%>