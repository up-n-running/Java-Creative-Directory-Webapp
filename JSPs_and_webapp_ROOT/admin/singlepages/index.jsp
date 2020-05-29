<%@ page language="java"
  import="com.extware.utils.BooleanUtils,
          com.extware.utils.DatabaseUtils,
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

String SELECT_PAGES_SQL = "SELECT p.textPageId, p.pageName, COUNT(DISTINCT x.groupId) groupCount FROM textPages p LEFT JOIN textPageGroupXref x ON x.textPageId=p.textPageId GROUP BY p.textPageId, p.pageName ORDER BY p.pageName";

boolean reloadMenu = BooleanUtils.parseBoolean( request.getParameter( "reloadMenu" ) );

int count;
int groupCount;
int textPageId;

String pageName;
String errors   = StringUtils.nullString( request.getParameter( "errors" ) ).trim();
String message  = StringUtils.nullString( request.getParameter( "message" ) ).trim();

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

%><html>
<head>
  <title>List Admin</title>
  <link rel="stylesheet" href="/style/admin.css" type="text/css">
</head>
<body class="adminPane">
<table border="0" cellpadding="0" cellspacing="0">
<tr>
  <td colspan="5" class="title">Single Page Admin</td>
</tr>
<%

if( !errors.equals( "" ) )
{

%><tr>
  <td colspan="5" class="error"><%= errors %></td>
</tr>
<%

}

if( !message.equals( "" ) )
{

%><tr>
  <td colspan="5" class="message"><%= message %></td>
</tr>
<%

}

count = 0;

ps = conn.prepareStatement( SELECT_PAGES_SQL );
rs = ps.executeQuery();

while( rs.next() )
{
  if( count == 0 )
  {

%><tr>
  <td class="listHead"></td>
  <td class="listHead">Single Page Name</td>
  <td colspan="3" class="listHead"></td>
</tr>
<%

  }

  textPageId = rs.getInt(    "textPageId" );
  pageName   = rs.getString( "pageName" );
  groupCount = rs.getInt(    "groupCount" );

%><tr>
  <td class="listLine<%= ( count % 2 ) %>"><img src="/art/<%= ( ( groupCount > 0 ) ? "admin/secure" : "blank" ) %>.gif" style="padding:1px"<%= ( ( groupCount > 0 ) ? " title=\"Access Limited\"" : "" ) %>/></td>
  <td class="listLine<%= ( count % 2 ) %>"><%= pageName %></td>
  <td class="listLine<%= ( count % 2 ) %>"><a href="edit.jsp?textPageId=<%= textPageId %>">Edit</a></td>
  <td class="listLine<%= ( count % 2 ) %>"><a href="pageDatabase.jsp?mode=delete&textPageId=<%= textPageId %>&pageName=<%= URLEncoder.encode( pageName ) %>" onclick="return confirm( 'Are you sure you wish to delete the <%= pageName %> Type' )">Delete</a></td>
</tr>
<%

  count++;
}

rs.close();
ps.close();

if( count == 0 )
{

%><tr>
  <td colspan="5" class="listSubHead">No Static Pages Found</td>
</tr>
<%

}

if( user.isUltra() )
{

%>
<tr>
  <td colspan="5" class="formButtons"><a href="edit.jsp">Add a Static Page</a></td>
</tr>
<%

}

%>
</table>
</body>
</html><%

conn.close();

%>