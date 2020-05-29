<%@ page language="java"
  import="com.extware.asset.image.PostProcess,
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

String SELECT_PP_ID_SQL = "SELECT postProcessId FROM imagePostProcesses WHERE UPPER( processName )=?";
String INSERT_LINK_SQL  = "INSERT INTO assetTypePostProcesses( assetTypeId, postProcessId ) VALUES( ?, ? )";
String DELETE_LINK_SQL  = "DELETE FROM assetTypePostProcesses WHERE assetTypeId=? AND postProcessId=?";

double squareAspectTolerance = NumberUtils.parseDouble( request.getParameter( "squareAspectTolerance" ), -1 );

int rowsChanged;
int assetTypeId   = NumberUtils.parseInt( request.getParameter( "assetTypeId" ),   -1 );
int postProcessId = NumberUtils.parseInt( request.getParameter( "postProcessId" ), -1 );

int landscapeX = NumberUtils.parseInt( request.getParameter( "landscapeX" ), -1 );
int landscapeY = NumberUtils.parseInt( request.getParameter( "landscapeY" ), -1 );
int square     = NumberUtils.parseInt( request.getParameter( "square" ),     -1 );
int portraitX  = NumberUtils.parseInt( request.getParameter( "portraitX" ),  -1 );
int portraitY  = NumberUtils.parseInt( request.getParameter( "portraitY" ),  -1 );

String errors        = "";
String message       = "";
String mode          = StringUtils.nullString( request.getParameter( "mode" ) ).trim().toLowerCase();
String processName   = StringUtils.nullString( request.getParameter( "processName" ) ).trim();
String fileExtension = StringUtils.nullString( request.getParameter( "fileExtension" ) ).trim();
String backFill      = StringUtils.nullString( request.getParameter( "backFill" ) ).trim();

int quality = NumberUtils.parseInt( StringUtils.nullReplace( request.getParameter( "quality" + fileExtension ), request.getParameter( "quality" ) ), -1 );

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

if( mode.equals( "add new" ) && assetTypeId != -1 && postProcessId == -1 )
{
  ps = conn.prepareStatement( SELECT_PP_ID_SQL );
  ps.setString( 1, processName.toUpperCase() );
  rs = ps.executeQuery();

  if( rs.next() )
  {
    errors = "The Rule '" + processName + "' already exists";
  }

  rs.close();
  ps.close();

  if( errors.equals( "" ) )
  {
    PostProcess postProcess = new PostProcess( processName, landscapeX, landscapeY, square, squareAspectTolerance, portraitX, portraitY, fileExtension, quality, backFill );
    postProcess.setDatabaseConnection( conn );
    postProcess.setRow();
    postProcessId = postProcess.postProcessId;
  }
}

if( errors.equals( "" ) && ( mode.equals( "add new" ) || mode.equals( "add existing" ) ) && assetTypeId != -1 && postProcessId != -1 )
{
  ps = conn.prepareStatement( INSERT_LINK_SQL );
  ps.setInt( 1, assetTypeId );
  ps.setInt( 2, postProcessId );
  rowsChanged = ps.executeUpdate();
  ps.close();

  if( rowsChanged == 1 )
  {
    message += "Rule '" + processName + "' added successfully.<br />";
  }
  else if( rowsChanged == 0 )
  {
    errors += "Rule '" + processName + "' not added.<br />";
  }
  else
  {
    message += "Rule '" + processName + "' added with multiple results.<br />";
  }
}
else if( mode.equals( "deletelink" ) && assetTypeId != -1 && postProcessId != -1 )
{
  ps = conn.prepareStatement( DELETE_LINK_SQL );
  ps.setInt( 1, assetTypeId );
  ps.setInt( 2, postProcessId );
  rowsChanged = ps.executeUpdate();
  ps.close();

  if( rowsChanged == 1 )
  {
    message += "Rule '" + processName + "' removed successfully.<br />";
  }
  else if( rowsChanged == 0 )
  {
    errors += "Rule '" + processName + "' not removed.<br />";
  }
  else
  {
    message += "Rule '" + processName + "' removed with multiple results.<br />";
  }
}

conn.close();

%><jsp:include page="edit.jsp" flush="true">
  <jsp:param name="errors" value="<%= errors %>"/>
  <jsp:param name="message" value="<%= message %>"/>
</jsp:include><%

%>