<%@ page language="java"
  import="com.extware.utils.DatabaseUtils,
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

String SELECT_PROCESSES_SQL = "SELECT postProcessId, processName FROM imagePostProcesses ORDER BY processName";

int count;
int postProcessId;

String processName;
String errors      = StringUtils.nullString( request.getParameter( "errors" ) ).trim();
String message     = StringUtils.nullString( request.getParameter( "message" ) ).trim();

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

%><html>
<head>
  <title>Image Size Rules Admin</title>
  <link rel="stylesheet" href="/style/admin.css" type="text/css">
</head>
<body class="adminPane">
<table border="0" cellpadding="0" cellspacing="0">
<tr>
  <td colspan="3" class="title">Image Size Rules Admin</td>
</tr>
<%

if( !errors.equals( "" ) )
{

%><tr>
  <td colspan="3" class="error"><%= errors %></td>
</tr>
<%

}

if( !message.equals( "" ) )
{

%><tr>
  <td colspan="3" class="message"><%= message %></td>
</tr>
<%

}

count = 0;

ps = conn.prepareStatement( SELECT_PROCESSES_SQL );
rs = ps.executeQuery();

while( rs.next() )
{
  if( count == 0 )
  {

%><tr>
  <td class="listHead">Rule Name</td>
  <td colspan="2" class="listHead"></td>
</tr>
<%

  }

  postProcessId = rs.getInt(    "postProcessId" );
  processName   = rs.getString( "processName" );

%><tr>
  <td class="listLine<%= ( count % 2 ) %>"><%= processName %></td>
  <td class="listLine<%= ( count % 2 ) %>"><a href="edit.jsp?postProcessId=<%= postProcessId %>">Edit</a></td>
  <td class="listLine<%= ( count % 2 ) %>"><a href="database.jsp?mode=delete&postProcessId=<%= postProcessId %>&processName=<%= URLEncoder.encode( processName ) %>" onclick="return confirm( 'Are you sure you wish to delete this Rule' )">Delete</a></td>
</tr>
<%

  count++;
}

rs.close();
ps.close();

if( count == 0 )
{

%><tr>
  <td colspan="3" class="listSubHead">No Rules Found</td>
</tr>
<%

}

%>
<tr>
  <td colspan="3" class="formButtons"><a href="edit.jsp">Add a Rule</a></td>
</tr>
</table>
</body>
</html><%

conn.close();

%>