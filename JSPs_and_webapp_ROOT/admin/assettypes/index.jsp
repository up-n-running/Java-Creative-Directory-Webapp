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

String SELECT_TYPES_SQL = "SELECT assetTypeId, assetTypeName FROM assetTypes ORDER BY assetTypeName";

int count;
int assetTypeId;

String assetTypeName;
String errors        = StringUtils.nullString( request.getParameter( "errors" ) ).trim();
String message       = StringUtils.nullString( request.getParameter( "message" ) ).trim();

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

%><html>
<head>
  <title>Asset Types Admin</title>
  <link rel="stylesheet" href="/style/admin.css" type="text/css">
</head>
<body class="adminPane">
<table border="0" cellpadding="0" cellspacing="0">
<tr>
  <td colspan="3" class="title">Asset Types Admin</td>
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

ps = conn.prepareStatement( SELECT_TYPES_SQL );
rs = ps.executeQuery();

while( rs.next() )
{
  if( count == 0 )
  {

%><tr>
  <td class="listHead">Asset Type Name</td>
  <td colspan="2" class="listHead"></td>
</tr>
<%

  }

  assetTypeId   = rs.getInt(    "assetTypeId" );
  assetTypeName = rs.getString( "assetTypeName" );

%><tr>
  <td class="listLine<%= ( count % 2 ) %>"><%= assetTypeName %></td>
  <td class="listLine<%= ( count % 2 ) %>"><a href="edit.jsp?assetTypeId=<%= assetTypeId %>">Edit</a></td>
  <td class="listLine<%= ( count % 2 ) %>"><a href="database.jsp?mode=delete&assetTypeId=<%= assetTypeId %>&assetTypeName=<%= URLEncoder.encode( assetTypeName ) %>" onclick="return confirm( 'Are you sure you wish to delete the Asset Type' )">Delete</a></td>
</tr>
<%

  count++;
}

rs.close();
ps.close();

if( count == 0 )
{

%><tr>
  <td colspan="3" class="listSubHead">No Asset Types Found</td>
</tr>
<%

}

%>
<tr>
  <td colspan="3" class="formButtons"><a href="edit.jsp">Add an Asset Type</a></td>
</tr>
</table>
</body>
</html><%

conn.close();

%>