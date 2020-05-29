<%@ page language="java"
  import="com.extware.common.DataDictionary,
          com.extware.utils.DatabaseUtils,
          com.extware.utils.NumberUtils,
          com.extware.utils.StringUtils,
          com.extware.user.UserDetails,
          java.sql.Connection,
          java.sql.PreparedStatement"
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

String insertTypeSql = "INSERT INTO objTypes( siteId, typeName, typePlural, typeHandle, typeNameLabel ) VALUES( ?, ?, ?, ? )";
String updateTypeSql = "UPDATE objTypes SET typeName=?, typePlural=?, typeHandle=?, typeNameLabel=? WHERE objTypeId=?";
String deleteTypeSql = "DELETE FROM objTypes WHERE objTypeId=?";

int typeId = NumberUtils.parseInt( request.getParameter( "typeId" ), -1 );

String function      = StringUtils.nullString( request.getParameter( "function" ) );
String typeName      = StringUtils.nullString( request.getParameter( "typeName" ) );
String typePlural    = StringUtils.nullString( request.getParameter( "typePlural" ) );
String typeHandle    = StringUtils.nullString( request.getParameter( "typeHandle" ) );
String typeNameLabel = StringUtils.nullString( request.getParameter( "typeNameLabel" ) );

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;

if( function.equals( "add" ) && !typeName.equals( "" ) )
{
  ps = conn.prepareStatement( insertTypeSql );
  ps.setInt   ( 1, user.siteId );
  ps.setString( 2, typeName );
  ps.setString( 3, typePlural );
  ps.setString( 4, typeHandle );
  ps.setString( 5, typeNameLabel );
  ps.executeUpdate();
  ps.close();
}
else if( function.equals( "edit" ) && !typeName.equals( "" ) && typeId != -1 )
{
  ps = conn.prepareStatement( updateTypeSql );
  ps.setString( 1, typeName );
  ps.setString( 2, typePlural );
  ps.setString( 3, typeHandle );
  ps.setString( 4, typeNameLabel );
  ps.setInt(    5, typeId );
  ps.executeUpdate();
  ps.close();
}
else if( function.equals( "delete" ) && typeId != -1 )
{
  ps = conn.prepareStatement( deleteTypeSql );
  ps.setInt( 1, typeId );
  ps.executeUpdate();
  ps.close();
}

conn.close();

response.sendRedirect( "index.jsp" );

%>