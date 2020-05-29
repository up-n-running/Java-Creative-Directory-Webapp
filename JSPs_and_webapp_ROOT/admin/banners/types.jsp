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

String SELECT_TYPES_SQL = "SELECT bannerTypeId, bannerTypeName, displayWidth, displayHeight FROM bannerTypes ORDER BY bannerTypeName";

int count;
int bannerTypeId;
int displayWidth;
int displayHeight;

String bannerTypeName;
String errors         = StringUtils.nullString( request.getParameter( "errors" ) ).trim();
String message        = StringUtils.nullString( request.getParameter( "message" ) ).trim();

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

%><html>
<head>
  <title>Banner Type Admin</title>
  <link rel="stylesheet" href="/style/admin.css" type="text/css">
</head>
<body class="adminPane">
<table border="0" cellpadding="0" cellspacing="0">
<tr>
  <td colspan="3" class="title">Banner Type Admin</td>
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
  <td class="listHead">Banner Type Name</td>
  <td colspan="2" class="listHead"></td>
</tr>
<%

  }

  bannerTypeId   = rs.getInt(    "bannerTypeId" );
  bannerTypeName = rs.getString( "bannerTypeName" );
  displayWidth   = rs.getInt(    "displayWidth" );
  displayHeight  = rs.getInt(    "displayHeight" );

%><tr>
  <td class="listLine<%= ( count % 2 ) %>"><%= bannerTypeName %> (<%= displayWidth %>x<%= displayHeight %>)</td>
  <td class="listLine<%= ( count % 2 ) %>"><a href="typeEdit.jsp?bannerTypeId=<%= bannerTypeId %>">Edit</a></td>
  <td class="listLine<%= ( count % 2 ) %>"><a href="typeDatabase.jsp?mode=delete&bannerTypeId=<%= bannerTypeId %>&bannerTypeName=<%= URLEncoder.encode( bannerTypeName ) %>" onclick="return confirm( 'Are you sure you wish to delete the <%= bannerTypeName %> Type?' )">Delete</a></td>
</tr>
<%

  count++;
}

rs.close();
ps.close();

if( count == 0 )
{

%><tr>
  <td colspan="3" class="listSubHead">No Banner Types Found</td>
</tr>
<%

}

%>
<tr>
  <td colspan="3" class="formButtons"><a href="typeEdit.jsp">Add a Banner Type</a></td>
</tr>
</table>
</body>
</html><%

conn.close();

%>