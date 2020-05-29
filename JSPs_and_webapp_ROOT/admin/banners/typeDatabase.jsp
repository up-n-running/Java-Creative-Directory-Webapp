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

String SELECT_TYPE_ID_SQL = "SELECT bannerTypeId FROM bannerTypes WHERE bannerTypeName=?";
String INSERT_TYPE_SQL    = "INSERT INTO bannerTypes( bannerTypeName, assetTypeId, displayWidth, displayHeight ) VALUES( ?, ?, ?, ? )";
String UPDATE_TYPE_SQL    = "UPDATE bannerTypes SET bannerTypeName=?, assetTypeId=?, displayWidth=?, displayHeight=? WHERE bannerTypeId=?";
String DELETE_TYPE_SQL    = "DELETE FROM bannerTypes WHERE bannerTypeId=?";

int rowsChanged;
int bannerTypeId    = NumberUtils.parseInt( request.getParameter( "bannerTypeId" ),   -1 );
int assetTypeId     = NumberUtils.parseInt( request.getParameter( "assetTypeId" ),    -1 );
int displayWidth    = NumberUtils.parseInt( request.getParameter( "displayWidth" ),  468 );
int displayHeight   = NumberUtils.parseInt( request.getParameter( "displayHeight" ),  60 );

String errors         = "";
String message        = "";
String mode           = StringUtils.nullString( request.getParameter( "mode" ) ).trim();
String bannerTypeName = StringUtils.nullString( request.getParameter( "bannerTypeName" ) ).trim();

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

if( mode.equals( "add" ) && bannerTypeId == -1 )
{
  if( bannerTypeName.equals( "" ) || displayWidth == -1 || displayHeight == -1 )
  {
    errors += "You must complete the Banner Type Name, Display Width and Display Height fields.<br />";
  }
  else
  {
    ps = conn.prepareStatement( SELECT_TYPE_ID_SQL );
    ps.setString( 1, bannerTypeName );
    rs = ps.executeQuery();

    if( rs.next() )
    {
      errors += "A banner type already exists with the name '" + bannerTypeName + "'.<br />";
    }

    rs.close();
    ps.close();

    if( errors.equals( "" ) )
    {
      ps = conn.prepareStatement( INSERT_TYPE_SQL );
      PreparedStatementUtils.setString( ps, 1, bannerTypeName );
      PreparedStatementUtils.setInt(    ps, 2, assetTypeId );
      PreparedStatementUtils.setInt(    ps, 3, displayWidth );
      PreparedStatementUtils.setInt(    ps, 4, displayHeight );

      rowsChanged = ps.executeUpdate();

      ps.close();

      if( rowsChanged == 1 )
      {
        message += "Banner type '" + bannerTypeName + "' added successfully.<br />";
      }
      else if( rowsChanged == 0 )
      {
        errors += "Banner type '" + bannerTypeName + "' not added.<br />";
      }
      else
      {
        message += "Banner type '" + bannerTypeName + "' added with multiple results.<br />";
      }
    }
  }
}
else if( mode.equals( "edit" ) && bannerTypeId != -1 )
{
  if( bannerTypeName.equals( "" ) || displayWidth == -1 || displayHeight == -1 )
  {
    errors += "You must complete the Banner Type Name, Display Width and Display Height fields.<br />";
  }
  else
  {
    ps = conn.prepareStatement( UPDATE_TYPE_SQL );
    PreparedStatementUtils.setString( ps, 1, bannerTypeName );
    PreparedStatementUtils.setInt(    ps, 2, assetTypeId );
    PreparedStatementUtils.setInt(    ps, 3, displayWidth );
    PreparedStatementUtils.setInt(    ps, 4, displayHeight );
    PreparedStatementUtils.setInt(    ps, 5, bannerTypeId );

    rowsChanged = ps.executeUpdate();

    ps.close();

    if( rowsChanged == 1 )
    {
      message += "Banner type '" + bannerTypeName + "' updated successfully.<br />";
    }
    else if( rowsChanged == 0 )
    {
      errors += "Banner type '" + bannerTypeName + "' not updated.<br />";
    }
    else
    {
      message += "Banner type '" + bannerTypeName + "' updated with multiple results.<br />";
    }
  }
}
else if( mode.equals( "delete" ) && bannerTypeId != -1 )
{
  ps = conn.prepareStatement( DELETE_TYPE_SQL );
  PreparedStatementUtils.setInt( ps, 1, bannerTypeId );

  rowsChanged = ps.executeUpdate();

  ps.close();

  if( rowsChanged == 1 )
  {
    message += "Banner type '" + bannerTypeName + "' deleted successfully.<br />";
  }
  else if( rowsChanged == 0 )
  {
    errors += "Banner type '" + bannerTypeName + "' not deleted.<br />";
  }
  else
  {
    message += "Banner type '" + bannerTypeName + "' deleted with multiple results.<br />";
  }
}
else
{
  errors += "Invalid Operation (mode='" + mode + "', bannerTypeId=" +  bannerTypeId + ")";
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
  response.sendRedirect( "types.jsp?message=" + URLEncoder.encode( message ) + "&errors=" + URLEncoder.encode( errors ) );
}

%>