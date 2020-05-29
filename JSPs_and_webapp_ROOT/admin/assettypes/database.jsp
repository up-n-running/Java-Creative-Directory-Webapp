<%@ page language="java"
  import="com.extware.utils.DatabaseUtils,
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

String SELECT_ASSET_TYPE_ID_SQL = "SELECT assetTypeId FROM assetTypes WHERE UPPER( assetTypeName )=?";
String INSERT_ASSET_TYPE_SQL    = "INSERT INTO assetTypes( assetTypeName, assetTypeHandle ) VALUES( ?, ? )";
String UPDATE_ASSET_TYPE_SQL    = "UPDATE assetTypes SET assetTypeName=?, assetTypeHandle=? WHERE assetTypeId=?";
String DELETE_ASSET_TYPE_SQL    = "DELETE FROM assetTypes WHERE assetTypeId=?";

int rowsChanged;
int assetTypeId = NumberUtils.parseInt( request.getParameter( "assetTypeId" ), -1 );

String errors          = "";
String message         = "";
String mode            = StringUtils.nullString( request.getParameter( "mode" ) ).trim();
String assetTypeName   = StringUtils.nullString( request.getParameter( "assetTypeName" ) ).trim();
String assetTypeHandle = StringUtils.nullString( request.getParameter( "assetTypeHandle" ) ).trim();

assetTypeHandle = StringUtils.replace( assetTypeHandle, "[^a-zA-Z0-9]+", "" );

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

if( mode.equals( "add" ) && assetTypeId == -1 )
{
  ps = conn.prepareStatement( SELECT_ASSET_TYPE_ID_SQL );
  ps.setString( 1, assetTypeName.toUpperCase() );
  rs = ps.executeQuery();

  if( rs.next() )
  {
    errors = "The Asset Type '" + assetTypeName + "' already exists";
  }

  rs.close();
  ps.close();

  if( errors.equals( "" ) )
  {
    ps = conn.prepareStatement( INSERT_ASSET_TYPE_SQL );
    ps.setString( 1, assetTypeName );
    ps.setString( 2, assetTypeHandle );
    rowsChanged = ps.executeUpdate();
    ps.close();

    if( rowsChanged == 1 )
    {
      message += "Asset Type '" + assetTypeName + "' added successfully.<br />";
    }
    else if( rowsChanged == 0 )
    {
      errors += "Asset Type '" + assetTypeName + "' not added.<br />";
    }
    else
    {
      message += "Asset Type '" + assetTypeName + "' added with multiple results.<br />";
    }
  }
}
else if( mode.equals( "edit" ) && assetTypeId != -1 )
{
  ps = conn.prepareStatement( UPDATE_ASSET_TYPE_SQL );
  ps.setString( 1, assetTypeName );
  ps.setString( 2, assetTypeHandle );
  ps.setInt(    3, assetTypeId );
  rowsChanged = ps.executeUpdate();
  ps.close();

  if( rowsChanged == 1 )
  {
    message += "Asset Type '" + assetTypeName + "' updated successfully.<br />";
  }
  else if( rowsChanged == 0 )
  {
    errors += "Asset Type '" + assetTypeName + "' not updated.<br />";
  }
  else
  {
    message += "Asset Type '" + assetTypeName + "' updated with multiple results.<br />";
  }
}
else if( mode.equals( "delete" ) && assetTypeId != -1 )
{
  ps = conn.prepareStatement( DELETE_ASSET_TYPE_SQL );
  ps.setInt( 1, assetTypeId );
  rowsChanged = ps.executeUpdate();
  ps.close();

  if( rowsChanged == 1 )
  {
    message += "Asset Type '" + assetTypeName + "' deleted successfully.<br />";
  }
  else if( rowsChanged == 0 )
  {
    errors += "Asset Type '" + assetTypeName + "' not deleted.<br />";
  }
  else
  {
    message += "Asset Type '" + assetTypeName + "' deleted with multiple results.<br />";
  }
}

conn.close();

if( mode.equals( "add" ) || mode.equals( "edit" ) )
{
  if( !errors.equals( "" ) )
  {

%><jsp:include page="edit.jsp" flush="true">
  <jsp:param name="errors" value="<%= errors %>"/>
  <jsp:param name="message" value="<%= message %>"/>
</jsp:include><%

  }
  else
  {
    response.sendRedirect( "index.jsp?message=" + URLEncoder.encode( message ) );
  }
}
else
{
  response.sendRedirect( "index.jsp?message=" + URLEncoder.encode( message ) + "&errors=" + URLEncoder.encode( errors ) );
}

%>