<%@ page language="java" import="
  com.extware.utils.BooleanUtils,
  com.extware.utils.DatabaseUtils,
  com.extware.utils.NumberUtils,
  com.extware.utils.PreparedStatementUtils,
  com.extware.utils.StringUtils,
  com.extware.user.UserDetails,
  java.net.URLEncoder,
  java.sql.Connection,
  java.sql.PreparedStatement,
  java.sql.ResultSet,
  java.sql.SQLException
" %><%!

void updateListLinks( Connection conn, HttpServletRequest request, int newsletterTypeId ) throws SQLException
{
  String SELECT_LIST_IDS_SQL   = "SELECT listTypeId FROM listTypes";
  String INSERT_LIST_LINK_SQL  = "INSERT INTO newsletterTypeListTypes( newsletterTypeId, listTypeId ) VALUES( ?, ? )";
  String DELETE_LIST_LINKS_SQL = "DELETE FROM newsletterTypeListTypes WHERE newsletterTypeId=?";

  PreparedStatement psUpdate = conn.prepareStatement( DELETE_LIST_LINKS_SQL );
  psUpdate.setInt( 1, newsletterTypeId );
  psUpdate.executeUpdate();
  psUpdate.close();

  psUpdate = conn.prepareStatement( INSERT_LIST_LINK_SQL );
  psUpdate.setInt( 1, newsletterTypeId );

  PreparedStatement psList = conn.prepareStatement( SELECT_LIST_IDS_SQL );
  ResultSet rs = psList.executeQuery();

  boolean addLink;

  int listTypeId;

  while( rs.next() )
  {
    listTypeId = rs.getInt( "listTypeId" );

    addLink = BooleanUtils.parseBoolean( request.getParameter( "type_" + listTypeId ) );

    if( addLink )
    {
      psUpdate.setInt( 2, listTypeId );
      psUpdate.executeUpdate();
    }
  }

  rs.close();
  psList.close();
  psUpdate.close();
}

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

String SELECT_TYPE_ID_SQL = "SELECT newsletterTypeId FROM newsletterTypes WHERE newsletterTypeHandle=?";
String INSERT_TYPE_SQL    = "INSERT INTO newsletterTypes( newsletterTypeName, newsletterTypeHandle, description, fromAddress, fromAddressPerSend, htmlHeader, htmlFooter, textHeader, textFooter ) VALUES( ?, ?, ?, ?, ?, ?, ?, ?, ? )";
String UPDATE_TYPE_SQL    = "UPDATE newsletterTypes SET newsletterTypeName=?, newsletterTypeHandle=?, description=?, fromAddress=?, fromAddressPerSend=?, htmlHeader=?, htmlFooter=?, textHeader=?, textFooter=? WHERE newsletterTypeId=?";
String DELETE_TYPE_SQL    = "DELETE FROM newsletterTypes WHERE newsletterTypeId=?";

boolean fromAddressPerSend = BooleanUtils.parseBoolean( request.getParameter( "fromAddressPerSend" ) );

int rowsChanged;
int newsletterTypeId = NumberUtils.parseInt( request.getParameter( "newsletterTypeId" ), -1 );

String errors               = "";
String message              = "";
String mode                 = StringUtils.nullString( request.getParameter( "mode" ) ).trim();
String newsletterTypeName   = StringUtils.nullString( request.getParameter( "newsletterTypeName" ) ).trim();
String newsletterTypeHandle = StringUtils.nullString( request.getParameter( "newsletterTypeHandle" ) ).trim();
String description          = StringUtils.nullString( request.getParameter( "description" ) ).trim();
String fromAddress          = StringUtils.nullString( request.getParameter( "fromAddress" ) ).trim();
String htmlHeader           = StringUtils.nullString( request.getParameter( "htmlHeader" ) ).trim();
String htmlFooter           = StringUtils.nullString( request.getParameter( "htmlFooter" ) ).trim();
String textHeader           = StringUtils.nullString( request.getParameter( "textHeader" ) ).trim();
String textFooter           = StringUtils.nullString( request.getParameter( "textFooter" ) ).trim();

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

if( mode.equals( "add" ) && newsletterTypeId == -1 )
{
  if( newsletterTypeName.equals( "" ) || newsletterTypeHandle.equals( "" ) || description.equals( "" ) || fromAddress.equals( "" ) )
  {
    errors += "You must complete the Newsletter Name, Newsletter Handle, Description and From Address fields.<br />";
  }
  else
  {
    ps = conn.prepareStatement( SELECT_TYPE_ID_SQL );
    ps.setString( 1, newsletterTypeHandle );
    rs = ps.executeQuery();

    if( rs.next() )
    {
      errors += "A newsletter type already exists with the handle '" + newsletterTypeHandle + "'.<br />";
    }

    rs.close();
    ps.close();

    if( errors.equals( "" ) )
    {
      ps = conn.prepareStatement( INSERT_TYPE_SQL );
      PreparedStatementUtils.setString( ps, 1, newsletterTypeName );
      PreparedStatementUtils.setString( ps, 2, newsletterTypeHandle );
      PreparedStatementUtils.setString( ps, 3, description );
      PreparedStatementUtils.setString( ps, 4, fromAddress );
      PreparedStatementUtils.setString( ps, 5, ( ( fromAddressPerSend ) ? "t" : "f" ) );
      PreparedStatementUtils.setString( ps, 6, htmlHeader );
      PreparedStatementUtils.setString( ps, 7, htmlFooter );
      PreparedStatementUtils.setString( ps, 8, textHeader );
      PreparedStatementUtils.setString( ps, 9, textFooter );

      rowsChanged = ps.executeUpdate();

      ps.close();

      ps = conn.prepareStatement( SELECT_TYPE_ID_SQL );
      ps.setString( 1, newsletterTypeHandle );
      rs = ps.executeQuery();

      if( rs.next() )
      {
        newsletterTypeId = rs.getInt( "newsletterTypeId" );
      }

      rs.close();
      ps.close();

      updateListLinks( conn, request, newsletterTypeId );

      if( rowsChanged == 1 )
      {
        message += "Newsletter Type '" + newsletterTypeName + "' added successfully.<br />";
      }
      else if( rowsChanged == 0 )
      {
        errors += "Newsletter Type '" + newsletterTypeName + "' not added.<br />";
      }
      else
      {
        message += "Newsletter Type '" + newsletterTypeName + "' added with multiple results.<br />";
      }
    }
  }
}
else if( mode.equals( "edit" ) && newsletterTypeId != -1 )
{
  if( newsletterTypeName.equals( "" ) || newsletterTypeHandle.equals( "" ) || description.equals( "" ) || fromAddress.equals( "" ) )
  {
    errors += "You must complete the Newsletter Name, Newsletter Handle, Description and From Address fields.<br />";
  }
  else
  {
    ps = conn.prepareStatement( UPDATE_TYPE_SQL );
    PreparedStatementUtils.setString( ps,  1, newsletterTypeName );
    PreparedStatementUtils.setString( ps,  2, newsletterTypeHandle );
    PreparedStatementUtils.setString( ps,  3, description );
    PreparedStatementUtils.setString( ps,  4, fromAddress );
    PreparedStatementUtils.setString( ps,  5, ( ( fromAddressPerSend ) ? "t" : "f" ) );
    PreparedStatementUtils.setString( ps,  6, htmlHeader );
    PreparedStatementUtils.setString( ps,  7, htmlFooter );
    PreparedStatementUtils.setString( ps,  8, textHeader );
    PreparedStatementUtils.setString( ps,  9, textFooter );
    PreparedStatementUtils.setInt(    ps, 10, newsletterTypeId );

    rowsChanged = ps.executeUpdate();

    ps.close();

    updateListLinks( conn, request, newsletterTypeId );

    if( rowsChanged == 1 )
    {
      message += "Newsletter Type '" + newsletterTypeName + "' updated successfully.<br />";
    }
    else if( rowsChanged == 0 )
    {
      errors += "Newsletter Type '" + newsletterTypeName + "' not updated.<br />";
    }
    else
    {
      message += "Newsletter Type '" + newsletterTypeName + "' updated with multiple results.<br />";
    }
  }
}
else if( mode.equals( "delete" ) && newsletterTypeId != -1 )
{
  ps = conn.prepareStatement( DELETE_TYPE_SQL );
  PreparedStatementUtils.setInt( ps, 1, newsletterTypeId );

  rowsChanged = ps.executeUpdate();

  ps.close();

  if( rowsChanged == 1 )
  {
    message += "Newsletter Type '" + newsletterTypeName + "' deleted successfully.<br />";
  }
  else if( rowsChanged == 0 )
  {
    errors += "Newsletter Type '" + newsletterTypeName + "' not deleted.<br />";
  }
  else
  {
    message += "Newsletter Type '" + newsletterTypeName + "' deleted with multiple results.<br />";
  }
}
else
{
  errors += "Invalid Operation (mode='" + mode + "', newsletterTypeId=" +  newsletterTypeId + ")";
}

conn.close();

if( ( mode.equals( "add" ) || mode.equals( "edit" ) ) && !errors.equals( "" ) )
{

%><jsp:include page="typeEdit.jsp" flush="true" >
  <jsp:param name="errors" value="<%= errors %>"/>
  <jsp:param name="message" value="<%= message %>"/>
</jsp:include><%

}
else
{
  response.sendRedirect( "typeList.jsp?message=" + URLEncoder.encode( message ) + "&errors=" + URLEncoder.encode( errors ) );
}

%>