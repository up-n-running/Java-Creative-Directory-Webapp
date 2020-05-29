<%@ page language="java"
  import="com.extware.extsite.lists.ListItemFile,
          com.extware.utils.DatabaseUtils,
          com.extware.utils.NumberUtils,
          com.extware.utils.PreparedStatementUtils,
          com.extware.utils.StringUtils,
          com.extware.user.UserDetails,
          java.net.URLEncoder,
          java.sql.Connection,
          java.sql.PreparedStatement,
          java.sql.ResultSet"
%><%

UserDetails user = UserDetails.getUser( session );

if( user == null )
{
  response.sendRedirect( "/admin/login.jsp" );
  return;
}

if( !user.isUltra() )
{
  response.sendRedirect( "/admin/blank.html" );
  return;
}

String SELECT_FILE_TYPE_ID_SQL   = "SELECT listTypeAssetTypeId FROM listTypeAssetTypes WHERE assetTypeName=? AND listTypeId=?";
String SELECT_ASSET_PP_COUNT_SQL = "SELECT COUNT(*) postProcessCount FROM assetTypePostProcesses WHERE assetTypeId=?";
String INSERT_FILE_TYPE_SQL      = "INSERT INTO listTypeAssetTypes( listTypeId, assetTypeName, fileType, assetTypeId ) VALUES( ?, ?, ?, ? )";
String UPDATE_FILE_TYPE_SQL      = "UPDATE listTypeAssetTypes SET assetTypeName=?, fileType=?, assetTypeId=? WHERE listTypeAssetTypeId=?";
String DELETE_FILE_TYPE_SQL      = "DELETE FROM listTypeAssetTypes WHERE listTypeAssetTypeId=?";

String UNSET_DEFAULT_FILE_TYPE_SQL = "UPDATE listTypeAssetTypes SET defaultType='f' WHERE listTypeId=?";
String SET_DEFAULT_FILE_TYPE_SQL   = "UPDATE listTypeAssetTypes SET defaultType='t' WHERE listTypeAssetTypeId=?";

int rowsChanged;
int postProcessCount    = ListItemFile.FILE_TYPE_DOWNLOAD;
int listTypeId          = NumberUtils.parseInt( request.getParameter( "listTypeId" ),          -1 );
int assetTypeId         = NumberUtils.parseInt( request.getParameter( "assetTypeId" ),         -1 );
int listTypeAssetTypeId = NumberUtils.parseInt( request.getParameter( "listTypeAssetTypeId" ), -1 );

String thisAssetTypeName;
String errors            = "";
String message           = "";
String mode              = StringUtils.nullString( request.getParameter( "mode" ) ).trim();
String listName          = StringUtils.nullString( request.getParameter( "listName" ) ).trim();
String assetTypeName     = StringUtils.nullString( request.getParameter( "assetTypeName" ) ).trim();

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

if( mode.equals( "add" ) && listTypeId != -1 && listTypeAssetTypeId == -1 )
{
  if( assetTypeName.equals( "" ) )
  {
    errors += "You must complete the File Type Name.<br />";
  }
  else
  {
    ps = conn.prepareStatement( SELECT_FILE_TYPE_ID_SQL );
    ps.setString( 1, assetTypeName );
    ps.setInt(    2, listTypeId );
    rs = ps.executeQuery();

    if( rs.next() )
    {
      errors += "A file type already exists with the name '" + assetTypeName + "'.<br />";
    }

    rs.close();
    ps.close();

    if( errors.equals( "" ) )
    {
      ps = conn.prepareStatement( SELECT_ASSET_PP_COUNT_SQL );
      ps.setInt( 1, assetTypeId );
      rs = ps.executeQuery();

      if( rs.next() )
      {
        postProcessCount = rs.getInt( "postProcessCount" );
      }

      rs.close();
      ps.close();

      ps = conn.prepareStatement( INSERT_FILE_TYPE_SQL );

      ps.setInt(    1, listTypeId );
      ps.setString( 2, assetTypeName );
      ps.setInt(    3, ( ( postProcessCount > 0 ) ? ListItemFile.FILE_TYPE_INLINE : ListItemFile.FILE_TYPE_DOWNLOAD ) );
      ps.setInt(    4, assetTypeId );

      rowsChanged = ps.executeUpdate();

      ps.close();

      if( rowsChanged == 1 )
      {
        message += "File type '" + listName + "' added successfully.<br />";
      }
      else if( rowsChanged == 0 )
      {
        errors += "File type '" + listName + "' not added.<br />";
      }
      else
      {
        message += "File type '" + listName + "' added with multiple results.<br />";
      }
    }
  }
}
else if( mode.equals( "edit" ) && listTypeId != -1 && listTypeAssetTypeId != -1 )
{
  if( assetTypeName.equals( "" ) )
  {
    errors += "You must complete the File Type Name.<br />";
  }
  else
  {
    ps = conn.prepareStatement( SELECT_ASSET_PP_COUNT_SQL );
    ps.setInt( 1, assetTypeId );
    rs = ps.executeQuery();

    if( rs.next() )
    {
      postProcessCount = rs.getInt( "postProcessCount" );
    }

    rs.close();
    ps.close();

    ps = conn.prepareStatement( UPDATE_FILE_TYPE_SQL );

    ps.setString( 1, assetTypeName );
    ps.setInt(    2, ( ( postProcessCount > 0 ) ? ListItemFile.FILE_TYPE_INLINE : ListItemFile.FILE_TYPE_DOWNLOAD ) );
    ps.setInt(    3, assetTypeId );
    ps.setInt(    4, listTypeAssetTypeId );

    rowsChanged = ps.executeUpdate();

    ps.close();

    if( rowsChanged == 1 )
    {
      message += "File type '" + listName + "' updated successfully.<br />";
    }
    else if( rowsChanged == 0 )
    {
      errors += "File type '" + listName + "' not updated.<br />";
    }
    else
    {
      message += "File type '" + listName + "' updated with multiple results.<br />";
    }
  }
}
else if( mode.equals( "delete" ) && listTypeId != -1 && listTypeAssetTypeId != -1 )
{
  ps = conn.prepareStatement( DELETE_FILE_TYPE_SQL );
  PreparedStatementUtils.setInt( ps, 1, listTypeAssetTypeId );

  rowsChanged = ps.executeUpdate();

  ps.close();

  if( rowsChanged == 1 )
  {
    message += "File type '" + listName + "' deleted successfully.<br />";
  }
  else if( rowsChanged == 0 )
  {
    errors += "File type '" + listName + "' not deleted.<br />";
  }
  else
  {
    message += "File type '" + listName + "' deleted with multiple results.<br />";
  }
}
else if( mode.equals( "default" ) && listTypeId != -1 && listTypeAssetTypeId != -1 )
{
  ps = conn.prepareStatement( UNSET_DEFAULT_FILE_TYPE_SQL );
  PreparedStatementUtils.setInt( ps, 1, listTypeId );

  rowsChanged = ps.executeUpdate();

  ps.close();

  ps = conn.prepareStatement( SET_DEFAULT_FILE_TYPE_SQL );
  PreparedStatementUtils.setInt( ps, 1, listTypeAssetTypeId );

  rowsChanged = ps.executeUpdate();

  ps.close();

  if( rowsChanged == 1 )
  {
    message += "Default file type set successfully.<br />";
  }
  else if( rowsChanged == 0 )
  {
    errors += "Default file type not set.<br />";
  }
  else
  {
    message += "Default file type set with multiple results.<br />";
  }
}
else
{
  errors += "Invalid Operation (mode='" + mode + "', listTypeId=" +  listTypeId + ")";
}

conn.close();

if( ( mode.equals( "add" ) || mode.equals( "edit" ) ) && !errors.equals( "" ) )
{

%><jsp:include page="fileTypeEdit.jsp" flush="true" >
  <jsp:param name="errors" value="<%= errors %>"/>
  <jsp:param name="message" value="<%= message %>"/>
</jsp:include><%

}
else
{
  response.sendRedirect( "fileTypes.jsp?listTypeId=" + listTypeId + "&listName=" + URLEncoder.encode( listName ) + "&message=" + URLEncoder.encode( message ) + "&errors=" + URLEncoder.encode( errors ) );
}

%>