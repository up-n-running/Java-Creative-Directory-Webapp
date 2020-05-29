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

if( !user.isAdmin() )
{
  response.sendRedirect( "/admin/blank.html" );
  return;
}

String SELECT_CHARTTYPE_ID_SQL    = "SELECT chartTypeId FROM chartType WHERE chartTypeHandle=?";
String INSERT_CHARTTYPE_SQL       = "INSERT INTO chartType ( chartTypeName, chartTypeHandle, weekStartId, chartLength, col1Name, col2Name, col3Name, col4Name ) VALUES( ?, ?, ?, ?, ?, ?, ?, ? )";
String UPDATE_CHARTTYPE_SQL       = "UPDATE chartType SET chartTypeName=?, chartTypeHandle=?, weekStartId=?, chartLength=?, col1Name=?, col2Name=?, col3Name=?, col4Name=? WHERE chartTypeId=?";
String DELETE_CHARTTYPE_SQL       = "DELETE FROM chartType WHERE chartTypeId=?";

int   rowsChanged;
int chartTypeId  = NumberUtils.parseInt( request.getParameter( "chartTypeId" ), -1 );

String errors          = "";
String message         = "";
String mode            = StringUtils.nullString( request.getParameter( "mode" ) ).trim();
String chartTypeName   = StringUtils.nullString( request.getParameter( "chartTypeName" ) );
String chartTypeHandle = StringUtils.nullString( request.getParameter( "chartTypeHandle" ) ).trim();
int    weekStartId     = NumberUtils.parseInt(   request.getParameter( "weekStartId" ), -1 );
int    chartLength     = NumberUtils.parseInt(   request.getParameter( "chartLength" ), -1 );
String col1Name        = StringUtils.nullString( request.getParameter( "col1Name" ) ).trim();
String col2Name        = StringUtils.nullString( request.getParameter( "col2Name" ) ).trim();
String col3Name        = StringUtils.nullString( request.getParameter( "col3Name" ) ).trim();
String col4Name        = StringUtils.nullString( request.getParameter( "col4Name" ) ).trim();
if( col1Name.equals( "" ) ) { col1Name = null; }
if( col2Name.equals( "" ) ) { col2Name = null; }
if( col3Name.equals( "" ) ) { col3Name = null; }
if( col4Name.equals( "" ) ) { col4Name = null; }


Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

if( mode.equals( "add" ) && chartTypeId == -1 )
{
  if( chartTypeName.equals( "" ) || chartTypeHandle.equals( "" ) )
  {
    errors += "You must complete the Name and Handle fields.<br />";
  }

  if( chartLength < 0 )
  {
    errors += "You must complete a Chart Length (number of rows)<br />";
  }

  if( ( col4Name != null && col3Name == null ) || ( col3Name != null && col2Name == null ) || ( col2Name != null && col1Name == null ) )
  {
    errors += "You are not allowed an empty Column Title in an earlier Column than a non-empty Column Title.<br />";
  }
  else if( col1Name == null )
  {
    errors += "You must have at least 1 Column Title.<br />";
  }

  if ( errors.equals( "" ) )
  {
    ps = conn.prepareStatement( SELECT_CHARTTYPE_ID_SQL );
    ps.setString( 1, chartTypeHandle );
    rs = ps.executeQuery();

    if( rs.next() )
    {
      errors += "A chart page type already exists with the handle '" + chartTypeHandle + "'.<br />";
    }

    rs.close();
    ps.close();

    if( errors.equals( "" ) )
    {
      ps = conn.prepareStatement( INSERT_CHARTTYPE_SQL );

      PreparedStatementUtils.setString( ps, 1, chartTypeName );
      PreparedStatementUtils.setString( ps, 2, chartTypeHandle );
      PreparedStatementUtils.setInt(    ps, 3, weekStartId );
      PreparedStatementUtils.setInt(    ps, 4, chartLength );
      PreparedStatementUtils.setString( ps, 5, col1Name );
      PreparedStatementUtils.setString( ps, 6, col2Name );
      PreparedStatementUtils.setString( ps, 7, col3Name );
      PreparedStatementUtils.setString( ps, 8, col4Name );
      //PreparedStatementUtils.setInt(    ps, 9, chartTypeId );

      rowsChanged = ps.executeUpdate();

      ps.close();

      if( rowsChanged == 1 )
      {
        message += "Chart type '" + chartTypeName + "' added successfully.<br />";
      }
      else if( rowsChanged == 0 )
      {
        errors += "Chart type '" + chartTypeName + "' not added.<br />";
      }
      else
      {
        message += "Chart type '" + chartTypeName + "' added with multiple results.<br />";
      }

      if( errors.equals( "" ) )
      {
        ps = conn.prepareStatement( SELECT_CHARTTYPE_ID_SQL );
        ps.setString( 1, chartTypeHandle );
        rs = ps.executeQuery();

        if( rs.next() )
        {
          chartTypeId = rs.getInt( "chartTypeId" );;
        }

        rs.close();
        ps.close();
      }
    }
  }
}
else if( mode.equals( "edit" ) && chartTypeId != -1 )
{

  if( ( chartTypeName != null && chartTypeHandle != null ) && ( chartTypeName.equals( "" ) || chartTypeHandle.equals( "" ) ) )
  {
    errors += "You must complete the Name and Handle fields.<br />";
  }
  else
  {
    ps = conn.prepareStatement( UPDATE_CHARTTYPE_SQL );
    PreparedStatementUtils.setString( ps, 1, chartTypeName   );
    PreparedStatementUtils.setString( ps, 2, chartTypeHandle );
    PreparedStatementUtils.setInt(    ps, 3, weekStartId     );
    PreparedStatementUtils.setInt   ( ps, 4, chartLength     );
    PreparedStatementUtils.setString( ps, 5, col1Name        );
    PreparedStatementUtils.setString( ps, 6, col2Name        );
    PreparedStatementUtils.setString( ps, 7, col3Name        );
    PreparedStatementUtils.setString( ps, 8, col4Name        );
    PreparedStatementUtils.setInt(    ps, 9, chartTypeId );

    rowsChanged = ps.executeUpdate();

    ps.close();

    if( rowsChanged == 1 )
    {
      message += "Chart Type" + ( chartTypeName==null? " " : "'" + chartTypeName + "'" ) + "updated successfully.<br />";
    }
    else if( rowsChanged == 0 )
    {
      errors += "Chart Type" + ( chartTypeName==null? " " : "'" + chartTypeName + "'" ) + "not updated.<br />";
    }
    else
    {
      message += "Chart Type" + ( chartTypeName==null? " " : "'" + chartTypeName + "'" ) + "updated with multiple results.<br />";
    }

  }
}
else if( mode.equals( "delete" ) && chartTypeId != -1 )
{
  ps = conn.prepareStatement( DELETE_CHARTTYPE_SQL );
  PreparedStatementUtils.setInt( ps, 1, chartTypeId );

  rowsChanged = ps.executeUpdate();

  ps.close();

  if( rowsChanged == 1 )
  {
    message += "Chart type '" + chartTypeName + "' deleted successfully.<br />";
  }
  else if( rowsChanged == 0 )
  {
    errors += "Chart type '" + chartTypeName + "' not deleted.<br />";
  }
  else
  {
    message += "Chart type '" + chartTypeName + "' deleted with multiple results.<br />";
  }
}
else
{
  errors += "Invalid Operation (mode='" + mode + "', chartTypeId=" +  chartTypeId + ")";
}

conn.close();

if( mode.equals( "add" ) || mode.equals( "edit" ) )
{
  if( !errors.equals( "" ) )
  {

%><jsp:include page="edit.jsp" flush="true" >
  <jsp:param name="errors" value="<%= errors %>"/>
  <jsp:param name="message" value="<%= message %>"/>
</jsp:include><%

  }
  else
  {
    response.sendRedirect( "index.jsp?message=" + URLEncoder.encode( message ) + "&reloadMenu=t" );
  }
}
else
{
  response.sendRedirect( "index.jsp?message=" + URLEncoder.encode( message ) + "&errors=" + URLEncoder.encode( errors ) + "&reloadMenu=t" );
}

%>