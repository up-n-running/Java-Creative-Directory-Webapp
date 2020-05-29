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

String SELECT_CHARTTYPES_SQL = "SELECT ct.chartTypeId, (ct.chartTypeHandle||', '||ct.chartTypeName) chartTypeName FROM chartType ct ORDER BY chartTypeHandle";

boolean reloadMenu = BooleanUtils.parseBoolean( request.getParameter( "reloadMenu" ) );

int count;
int groupCount;
int chartTypeId;

String chartTypeName;
String errors     = StringUtils.nullString( request.getParameter( "errors" ) ).trim();
String message    = StringUtils.nullString( request.getParameter( "message" ) ).trim();

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

%><html>
<head>
  <title>Chart Admin</title>
  <link rel="stylesheet" href="/style/admin.css" type="text/css">
</head>
<body class="adminPane"<%= ( ( reloadMenu ) ? " onload=\"if( typeof( parent.menu ) ) { parent.menu.document.location.reload(); }\"" : "" ) %>>
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

ps = conn.prepareStatement( SELECT_CHARTTYPES_SQL );
rs = ps.executeQuery();

while( rs.next() )
{
  if( count == 0 )
  {

%><tr>
  <td class="listHead"></td>
  <td class="listHead">Chart Type Name</td>
  <td colspan="3" class="listHead"></td>
</tr>
<%

  }

  chartTypeId = rs.getInt(    "chartTypeId" );
  chartTypeName   = rs.getString( "chartTypeName" );
  groupCount = 0;

%><tr>
  <td class="listLine<%= ( count % 2 ) %>"><img src="/art/<%= ( ( groupCount > 0 ) ? "admin/secure" : "blank" ) %>.gif" style="padding:1px"<%= ( ( groupCount > 0 ) ? " title=\"Access Limited\"" : "" ) %>/></td>
  <td class="listLine<%= ( count % 2 ) %>"><%= chartTypeName %></td>
  <td class="listLine<%= ( count % 2 ) %>"><a href="edit.jsp?chartTypeId=<%= chartTypeId %>">Edit</a></td>
  <td class="listLine<%= ( count % 2 ) %>"><a href="pageDatabase.jsp?mode=delete&chartTypeId=<%= chartTypeId %>&chartTypeName=<%= URLEncoder.encode( chartTypeName ) %>" onclick="return confirm( 'Are you sure you wish to delete the <%= chartTypeName %> Type' )">Delete</a></td>
</tr>
<%

  count++;
}

rs.close();
ps.close();

if( count == 0 )
{

%><tr>
  <td colspan="5" class="listSubHead">No Chart Types Found</td>
</tr>
<%

}

if( user.isUltra() )
{

%>
<tr>
  <td colspan="5" class="formButtons"><a href="edit.jsp">Add a Chart Type</a></td>
</tr>
<%

}

%>
</table>
</body>
</html><%

conn.close();

%>