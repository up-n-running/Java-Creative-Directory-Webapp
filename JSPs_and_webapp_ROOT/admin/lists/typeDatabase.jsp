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

String SELECT_TYPE_ID_SQL    = "SELECT listTypeId FROM listTypes WHERE listHandle=?";
String INSERT_TYPE_SQL       = "INSERT INTO listTypes( listName, listHandle, orderColumn, titleLabel, standfirstLabel, bodyLabel, dateLabel, updateTimestamp ) VALUES( ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP )";
String INSERT_GROUP_XREF_SQL = "INSERT INTO listTypeGroupXref( listTypeId, groupId ) VALUES( ?, ? )";
String UPDATE_TYPE_SQL       = "UPDATE listTypes SET listName=?, listHandle=?, orderColumn=?, titleLabel=?, standfirstLabel=?, bodyLabel=?, dateLabel=?, updateTimestamp=CURRENT_TIMESTAMP WHERE listTypeId=?";
String DELETE_TYPE_SQL       = "DELETE FROM listTypes WHERE listTypeId=?";
String DELETE_GROUP_XREF_SQL = "DELETE FROM listTypeGroupXref WHERE listTypeId=?";

int   rowsChanged;
int   listTypeId  = NumberUtils.parseInt( request.getParameter( "listTypeId" ), -1 );
int[] groupIds    = NumberUtils.parseIntArray( request.getParameterValues( "groupIds" ), -1 );

String errors          = "";
String message         = "";
String mode            = StringUtils.nullString( request.getParameter( "mode" ) ).trim();
String listName        = StringUtils.nullString( request.getParameter( "listName" ) ).trim();
String listHandle      = StringUtils.nullString( request.getParameter( "listHandle" ) ).trim();
String orderColumn     = StringUtils.nullString( request.getParameter( "orderColumn" ) ).trim();
String titleLabel      = StringUtils.nullString( request.getParameter( "titleLabel" ) ).trim();
String standfirstLabel = StringUtils.nullString( request.getParameter( "standfirstLabel" ) ).trim();
String bodyLabel       = StringUtils.nullString( request.getParameter( "bodyLabel" ) ).trim();
String dateLabel       = StringUtils.nullString( request.getParameter( "dateLabel" ) ).trim();

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

if( mode.equals( "add" ) && listTypeId == -1 )
{
  if( listName.equals( "" ) || listHandle.equals( "" ) )
  {
    errors += "You must complete the List Name and List Handle fields.<br />";
  }
  else
  {
    ps = conn.prepareStatement( SELECT_TYPE_ID_SQL );
    ps.setString( 1, listHandle );
    rs = ps.executeQuery();

    if( rs.next() )
    {
      errors += "A list type already exists with the handle '" + listHandle + "'.<br />";
    }

    rs.close();
    ps.close();

    if( errors.equals( "" ) )
    {
      ps = conn.prepareStatement( INSERT_TYPE_SQL );
      PreparedStatementUtils.setString( ps, 1, listName );
      PreparedStatementUtils.setString( ps, 2, listHandle );
      PreparedStatementUtils.setString( ps, 3, orderColumn );
      PreparedStatementUtils.setString( ps, 4, titleLabel );
      PreparedStatementUtils.setString( ps, 5, standfirstLabel );
      PreparedStatementUtils.setString( ps, 6, bodyLabel );
      PreparedStatementUtils.setString( ps, 7, dateLabel );

      rowsChanged = ps.executeUpdate();

      ps.close();

      if( rowsChanged == 1 )
      {
        message += "List type '" + listName + "' added successfully.<br />";
      }
      else if( rowsChanged == 0 )
      {
        errors += "List type '" + listName + "' not added.<br />";
      }
      else
      {
        message += "List type '" + listName + "' added with multiple results.<br />";
      }

      if( errors.equals( "" ) )
      {
        ps = conn.prepareStatement( SELECT_TYPE_ID_SQL );
        ps.setString( 1, listHandle );
        rs = ps.executeQuery();

        if( rs.next() )
        {
          listTypeId = rs.getInt( "listTypeId" );;
        }

        rs.close();
        ps.close();

        ps = conn.prepareStatement( DELETE_GROUP_XREF_SQL );
        ps.setInt( 1, listTypeId );
        ps.executeUpdate();
        ps.close();

        if( listTypeId != -1 && groupIds.length > 0 )
        {
          ps = conn.prepareStatement( INSERT_GROUP_XREF_SQL );
          ps.setInt( 1, listTypeId );

          for( int i = 0 ; i < groupIds.length ; i++ )
          {
            ps.setInt( 2, groupIds[i] );
            ps.executeUpdate();
          }

          ps.close();
        }
      }
    }
  }
}
else if( mode.equals( "edit" ) && listTypeId != -1 )
{
  if( listName.equals( "" ) || listHandle.equals( "" ) )
  {
    errors += "You must complete the List Name and List Handle fields.<br />";
  }
  else
  {
    ps = conn.prepareStatement( UPDATE_TYPE_SQL );
    PreparedStatementUtils.setString( ps, 1, listName );
    PreparedStatementUtils.setString( ps, 2, listHandle );
    PreparedStatementUtils.setString( ps, 3, orderColumn );
    PreparedStatementUtils.setString( ps, 4, titleLabel );
    PreparedStatementUtils.setString( ps, 5, standfirstLabel );
    PreparedStatementUtils.setString( ps, 6, bodyLabel );
    PreparedStatementUtils.setString( ps, 7, dateLabel );
    PreparedStatementUtils.setInt(    ps, 8, listTypeId );

    rowsChanged = ps.executeUpdate();

    ps.close();

    if( rowsChanged == 1 )
    {
      message += "List type '" + listName + "' updated successfully.<br />";
    }
    else if( rowsChanged == 0 )
    {
      errors += "List type '" + listName + "' not updated.<br />";
    }
    else
    {
      message += "List type '" + listName + "' updated with multiple results.<br />";
    }

    if( errors.equals( "" ) )
    {
      ps = conn.prepareStatement( DELETE_GROUP_XREF_SQL );
      ps.setInt( 1, listTypeId );
      ps.executeUpdate();
      ps.close();

      if( listTypeId != -1 && groupIds.length > 0 )
      {
        ps = conn.prepareStatement( INSERT_GROUP_XREF_SQL );
        ps.setInt( 1, listTypeId );

        for( int i = 0 ; i < groupIds.length ; i++ )
        {
          ps.setInt( 2, groupIds[i] );
          ps.executeUpdate();
        }

        ps.close();
      }
    }
  }
}
else if( mode.equals( "delete" ) && listTypeId != -1 )
{
  ps = conn.prepareStatement( DELETE_TYPE_SQL );
  PreparedStatementUtils.setInt( ps, 1, listTypeId );

  rowsChanged = ps.executeUpdate();

  ps.close();

  if( rowsChanged == 1 )
  {
    message += "List type '" + listName + "' deleted successfully.<br />";
  }
  else if( rowsChanged == 0 )
  {
    errors += "List type '" + listName + "' not deleted.<br />";
  }
  else
  {
    message += "List type '" + listName + "' deleted with multiple results.<br />";
  }
}
else
{
  errors += "Invalid Operation (mode='" + mode + "', listTypeId=" +  listTypeId + ")";
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