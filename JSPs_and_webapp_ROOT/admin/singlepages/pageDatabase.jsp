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
//System.out.println( "getting user" );
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
//System.out.println( "user valid" );
String SELECT_PAGE_ID_SQL    = "SELECT textPageId FROM textPages WHERE pageHandle=?";
String INSERT_PAGE_SQL       = "INSERT INTO textPages( pageName, pageHandle, pageContent, updateTimestamp ) VALUES( ?, ?, ?, CURRENT_TIMESTAMP )";
String INSERT_GROUP_XREF_SQL = "INSERT INTO textPageGroupXref( textPageId, groupId ) VALUES( ?, ? )";
String UPDATE_PAGE_SQL       = "UPDATE textPages SET pageName=?, pageHandle=?, pageContent=?, updateTimestamp=CURRENT_TIMESTAMP WHERE textPageId=?";
String UPDATE_PAGE_ADMIN_SQL = "UPDATE textPages SET pageContent=?, updateTimestamp=CURRENT_TIMESTAMP WHERE textPageId=?";
String DELETE_PAGE_SQL       = "DELETE FROM textPages WHERE textPageId=?";
String DELETE_GROUP_XREF_SQL = "DELETE FROM textPageGroupXref WHERE textPageId=?";

int   rowsChanged;
int   textPageId  = NumberUtils.parseInt( request.getParameter( "textPageId" ), -1 );
int[] groupIds    = NumberUtils.parseIntArray( request.getParameterValues( "groupIds" ), -1 );

String errors          = "";
String message         = "";
String mode            = StringUtils.nullString( request.getParameter( "mode" ) ).trim();
String pageName        =  request.getParameter( "pageName" );
String pageHandle      = request.getParameter( "pageHandle" );
String pageContent     = StringUtils.nullString( request.getParameter( "pageContent" ) );

//System.out.println( "mode" );

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

if( mode.equals( "add" ) && textPageId == -1 )
{
  if( pageName.equals( "" ) || pageHandle.equals( "" ) )
  {
    errors += "You must complete the List Name and List Handle fields.<br />";
  }
  else
  {
    ps = conn.prepareStatement( SELECT_PAGE_ID_SQL );
    ps.setString( 1, pageHandle );
    rs = ps.executeQuery();

    if( rs.next() )
    {
      errors += "A page type already exists with the handle '" + pageHandle + "'.<br />";
    }

    rs.close();
    ps.close();

    if( errors.equals( "" ) )
    {
      ps = conn.prepareStatement( INSERT_PAGE_SQL );
      PreparedStatementUtils.setString( ps, 1, pageName );
      PreparedStatementUtils.setString( ps, 2, pageHandle );
      PreparedStatementUtils.setString( ps, 3, pageContent );

      rowsChanged = ps.executeUpdate();

      ps.close();

      if( rowsChanged == 1 )
      {
        message += "Page type '" + pageName + "' added successfully.<br />";
      }
      else if( rowsChanged == 0 )
      {
        errors += "Page type '" + pageName + "' not added.<br />";
      }
      else
      {
        message += "Page type '" + pageName + "' added with multiple results.<br />";
      }

      if( errors.equals( "" ) )
      {
        ps = conn.prepareStatement( SELECT_PAGE_ID_SQL );
        ps.setString( 1, pageHandle );
        rs = ps.executeQuery();

        if( rs.next() )
        {
          textPageId = rs.getInt( "textPageId" );;
        }

        rs.close();
        ps.close();

        ps = conn.prepareStatement( DELETE_GROUP_XREF_SQL );
        ps.setInt( 1, textPageId );
        ps.executeUpdate();
        ps.close();

        if( textPageId != -1 && groupIds.length > 0 )
        {
          ps = conn.prepareStatement( INSERT_GROUP_XREF_SQL );
          ps.setInt( 1, textPageId );

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
else if( mode.equals( "edit" ) && textPageId != -1 )
{

  if( ( pageName != null && pageHandle != null ) && ( pageName.equals( "" ) || pageHandle.equals( "" ) ) )
  {
    errors += "You must complete the Page Name and Page Handle fields.<br />";
  }
  else
  {
    if( pageName == null && pageHandle == null )
    {
      //System.out.println( "updating page" );
      ps = conn.prepareStatement( UPDATE_PAGE_ADMIN_SQL );
      PreparedStatementUtils.setString( ps, 1, pageContent );
      PreparedStatementUtils.setInt   ( ps, 2, textPageId );
    }
    else if ( user.isUltra() )
    {
      ps = conn.prepareStatement( UPDATE_PAGE_SQL );
      PreparedStatementUtils.setString( ps, 1, pageName );
      PreparedStatementUtils.setString( ps, 2, pageHandle );
      PreparedStatementUtils.setString( ps, 3, pageContent );
      PreparedStatementUtils.setInt   ( ps, 4, textPageId );
    }
    else
    {
      //this can never happen - unless you're going directly to this page from a url
      ps = null;
      conn.close();
    }

    rowsChanged = ps.executeUpdate();

    ps.close();

    if( rowsChanged == 1 )
    {
      message += "Page" + ( pageName==null? " " : "'" + pageName + "'" ) + "updated successfully.<br />";
    }
    else if( rowsChanged == 0 )
    {
      errors += "Page" + ( pageName==null? " " : "'" + pageName + "'" ) + "not updated.<br />";
    }
    else
    {
      message += "Page" + ( pageName==null? " " : "'" + pageName + "'" ) + "updated with multiple results.<br />";
    }

    if( errors.equals( "" ) )
    {
      ps = conn.prepareStatement( DELETE_GROUP_XREF_SQL );
      ps.setInt( 1, textPageId );
      ps.executeUpdate();
      ps.close();

      if( textPageId != -1 && groupIds.length > 0 )
      {
        ps = conn.prepareStatement( INSERT_GROUP_XREF_SQL );
        ps.setInt( 1, textPageId );

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
else if( mode.equals( "delete" ) && textPageId != -1 )
{
  ps = conn.prepareStatement( DELETE_PAGE_SQL );
  PreparedStatementUtils.setInt( ps, 1, textPageId );

  rowsChanged = ps.executeUpdate();

  ps.close();

  if( rowsChanged == 1 )
  {
    message += "Page type '" + pageName + "' deleted successfully.<br />";
  }
  else if( rowsChanged == 0 )
  {
    errors += "Page type '" + pageName + "' not deleted.<br />";
  }
  else
  {
    message += "Page type '" + pageName + "' deleted with multiple results.<br />";
  }
}
else
{
  errors += "Invalid Operation (mode='" + mode + "', textPageId=" +  textPageId + ")";
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