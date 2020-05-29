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

String SELECT_PROCESS_ID_SQL = "SELECT postProcessId FROM imagePostProcesses WHERE UPPER( processName )=?";
String DELETE_PROCESS_SQL    = "DELETE FROM imagePostProcesses WHERE postProcessId=?";

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

if( mode.equals( "add" ) && postProcessId == -1 )
{
  ps = conn.prepareStatement( SELECT_PROCESS_ID_SQL );
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
  }
}
else if( mode.equals( "edit" ) && postProcessId != -1 )
{
  PostProcess postProcess = new PostProcess( postProcessId, processName, landscapeX, landscapeY, square, squareAspectTolerance, portraitX, portraitY, fileExtension, quality, backFill );
  postProcess.setDatabaseConnection( conn );
  postProcess.setRow();
}
else if( mode.equals( "delete" ) && postProcessId != -1 )
{
  ps = conn.prepareStatement( DELETE_PROCESS_SQL );
  ps.setInt( 1, postProcessId );
  rowsChanged = ps.executeUpdate();
  ps.close();

  if( rowsChanged == 1 )
  {
    message += "Rule '" + processName + "' deleted successfully.<br />";
  }
  else if( rowsChanged == 0 )
  {
    errors += "Rule '" + processName + "' not deleted.<br />";
  }
  else
  {
    message += "Rule '" + processName + "' deleted with multiple results.<br />";
  }
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