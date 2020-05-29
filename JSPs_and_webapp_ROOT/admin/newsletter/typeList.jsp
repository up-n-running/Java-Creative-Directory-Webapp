<%@ page language="java" import="
  com.extware.utils.BooleanUtils,
  com.extware.utils.DatabaseUtils,
  com.extware.utils.StringUtils,
  com.extware.user.UserDetails,
  java.net.URLEncoder,
  java.sql.Connection,
  java.sql.PreparedStatement,
  java.sql.ResultSet
" %><%

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

String SELECT_TYPES_SQL = "SELECT newsletterTypeId, newsletterTypeName FROM newsletterTypes ORDER BY newsletterTypeName";

boolean reloadMenu = BooleanUtils.parseBoolean( request.getParameter( "reloadMenu" ) );

int count;
int newsletterTypeId;

String newsletterTypeName;
String errors             = StringUtils.nullString( request.getParameter( "errors" ) ).trim();
String message            = StringUtils.nullString( request.getParameter( "message" ) ).trim();

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

%><html>
<head>
  <title>Newsletter Type Admin</title>
  <link rel="stylesheet" href="/style/admin.css" type="text/css">
</head>
<body class="adminPane">
<table border="0" cellpadding="0" cellspacing="0">
<tr>
  <td colspan="4" class="title">Newsletter Type Admin</td>
</tr>
<%

if( !errors.equals( "" ) )
{

%><tr>
  <td colspan="4" class="error"><%= errors %></td>
</tr>
<%

}

if( !message.equals( "" ) )
{

%><tr>
  <td colspan="4" class="message"><%= message %></td>
</tr>
<%

}

count = 0;

ps = conn.prepareStatement( SELECT_TYPES_SQL );
rs = ps.executeQuery();

while( rs.next() )
{
  if( count == 0 )
  {

%><tr>
  <td class="listHead">Newsletter Type Name</td>
  <td colspan="3" class="listHead"></td>
</tr>
<%

  }

  newsletterTypeId   = rs.getInt(    "newsletterTypeId" );
  newsletterTypeName = rs.getString( "newsletterTypeName" );

%><tr>
  <td class="listLine<%= ( count % 2 ) %>"><%= newsletterTypeName %></td>
  <td class="listLine<%= ( count % 2 ) %>"><a href="typeEdit.jsp?newsletterTypeId=<%= newsletterTypeId %>">Edit</a></td>
  <td class="listLine<%= ( count % 2 ) %>"><a href="typeDatabase.jsp?mode=delete&newsletterTypeId=<%= newsletterTypeId %>&newsletterTypeName=<%= URLEncoder.encode( newsletterTypeName ) %>" onclick="return confirm( 'Are you sure you wish to delete the <%= newsletterTypeName %> Type' )">Delete</a></td>
</tr>
<%

  count++;
}

rs.close();
ps.close();

if( count == 0 )
{

%><tr>
  <td colspan="4" class="listSubHead">No Newsletter Types Found</td>
</tr>
<%

}

%>
<tr>
  <td colspan="4" class="formButtons"><a href="typeEdit.jsp">Add a Newsletter Type</a></td>
</tr>
</table>
</body>
</html><%

conn.close();

%>