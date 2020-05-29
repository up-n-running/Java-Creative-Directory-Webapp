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

if( !user.isUltra() )
{
  response.sendRedirect( "/admin/blank.html" );
  return;
}

String SELECT_TYPES_SQL = "SELECT t.listTypeId, t.listName, COUNT(DISTINCT x.groupId) groupCount FROM listTypes t LEFT JOIN listTypeGroupXref x ON x.listTypeId=t.listTypeId GROUP BY t.listTypeId, t.listName ORDER BY t.listName";

boolean reloadMenu = BooleanUtils.parseBoolean( request.getParameter( "reloadMenu" ) );

int count;
int groupCount;
int listTypeId;

String listName;
String errors     = StringUtils.nullString( request.getParameter( "errors" ) ).trim();
String message    = StringUtils.nullString( request.getParameter( "message" ) ).trim();

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

%><html>
<head>
  <title>List Admin</title>
  <link rel="stylesheet" href="/style/admin.css" type="text/css">
</head>
<body class="adminPane"<%= ( ( reloadMenu ) ? " onload=\"if( typeof( parent.menu ) ) { parent.menu.document.location.reload(); }\"" : "" ) %>>
<table border="0" cellpadding="0" cellspacing="0">
<tr>
  <td colspan="5" class="title">List Admin</td>
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

ps = conn.prepareStatement( SELECT_TYPES_SQL );
rs = ps.executeQuery();

while( rs.next() )
{
  if( count == 0 )
  {

%><tr>
  <td class="listHead"></td>
  <td class="listHead">List Type Name</td>
  <td colspan="3" class="listHead"></td>
</tr>
<%

  }

  listTypeId = rs.getInt(    "listTypeId" );
  listName   = rs.getString( "listName" );
  groupCount = rs.getInt(    "groupCount" );

%><tr>
  <td class="listLine<%= ( count % 2 ) %>"><img src="/art/<%= ( ( groupCount > 0 ) ? "admin/secure" : "blank" ) %>.gif" style="padding:1px"<%= ( ( groupCount > 0 ) ? " title=\"Access Limited\"" : "" ) %>/></td>
  <td class="listLine<%= ( count % 2 ) %>"><%= listName %></td>
  <td class="listLine<%= ( count % 2 ) %>"><a href="edit.jsp?listTypeId=<%= listTypeId %>">Edit</a></td>
  <td class="listLine<%= ( count % 2 ) %>"><a href="fileTypes.jsp?listTypeId=<%= listTypeId %>&listName=<%= URLEncoder.encode( listName ) %>">File Types</a></td>
  <td class="listLine<%= ( count % 2 ) %>"><a href="typeDatabase.jsp?mode=delete&listTypeId=<%= listTypeId %>&listName=<%= URLEncoder.encode( listName ) %>" onclick="return confirm( 'Are you sure you wish to delete the <%= listName %> Type' )">Delete</a></td>
</tr>
<%

  count++;
}

rs.close();
ps.close();

if( count == 0 )
{

%><tr>
  <td colspan="5" class="listSubHead">No List Types Found</td>
</tr>
<%

}

%>
<tr>
  <td colspan="5" class="formButtons"><a href="edit.jsp">Add a List Type</a></td>
</tr>
</table>
</body>
</html><%

conn.close();

%>