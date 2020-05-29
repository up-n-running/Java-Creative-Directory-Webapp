<%@ page language="java"
  import="com.extware.utils.BooleanUtils,
          com.extware.utils.DatabaseUtils,
          com.extware.utils.StringUtils,
          com.extware.user.UserDetails,
          java.net.URLEncoder,
          java.sql.Connection,
          java.sql.PreparedStatement,
          java.sql.ResultSet,
          java.sql.Timestamp"
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

String SELECT_BANNERS_SQL = "SELECT b.bannerId, b.bannerName, b.dateLive, b.dateRemove, b.displayed, b.clicked, b.assetId, t.bannerTypeName, t.displayWidth, t.displayHeight FROM banners b INNER JOIN bannerTypes t ON b.bannerTypeId=t.bannerTypeId ORDER BY b.dateLive DESC, b.dateRemove DESC";

int count;
int assetId;
int clicked;
int bannerId;
int displayed;
int bannerTypeId;
int displayWidth;
int displayHeight;

String bannerName;
String bannerTypeName;
String errors         = StringUtils.nullString( request.getParameter( "errors" ) ).trim();
String message        = StringUtils.nullString( request.getParameter( "message" ) ).trim();

Timestamp dateLive;
Timestamp dateRemove;

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

%><html>
<head>
  <title>Banner Admin</title>
  <link rel="stylesheet" href="/style/admin.css" type="text/css">
</head>
<body class="adminPane">
<table border="0" cellpadding="0" cellspacing="0">
<tr>
  <td colspan="6" class="title">Banner Admin</td>
</tr>
<%

if( !errors.equals( "" ) )
{

%><tr>
  <td colspan="6" class="error"><%= errors %></td>
</tr>
<%

}

if( !message.equals( "" ) )
{

%><tr>
  <td colspan="6" class="message"><%= message %></td>
</tr>
<%

}

count = 0;

ps = conn.prepareStatement( SELECT_BANNERS_SQL );
rs = ps.executeQuery();

while( rs.next() )
{
  if( count == 0 )
  {

%><tr>
  <td class="listHead">Banner Name</td>
  <td class="listHead">Banner Type</td>
  <td class="listHead">Displayed</td>
  <td class="listHead">Clicked</td>
  <td colspan="3" class="listHead"></td>
</tr>
<%

  }

  bannerId       = rs.getInt(       "bannerId" );
  bannerName     = rs.getString(    "bannerName" );
  dateLive       = rs.getTimestamp( "dateLive" );
  dateRemove     = rs.getTimestamp( "dateRemove" );
  displayed      = rs.getInt(       "displayed" );
  clicked        = rs.getInt(       "clicked" );
  assetId        = rs.getInt(       "assetId" );
  bannerTypeName = rs.getString(    "bannerTypeName" );
  displayWidth   = rs.getInt(       "displayWidth" );
  displayHeight  = rs.getInt(       "displayHeight" );

%><tr>
  <td class="listLine<%= ( count % 2 ) %>"><%= bannerName %></td>
  <td class="listLine<%= ( count % 2 ) %>"><%= bannerTypeName %> (<%= displayWidth %>x<%= displayHeight %>)</td>
  <td class="listLine<%= ( count % 2 ) %>"><%= displayed %></td>
  <td class="listLine<%= ( count % 2 ) %>"><%= clicked %></td>
  <td class="listLine<%= ( count % 2 ) %>"><a href="edit.jsp?bannerId=<%= bannerId %>">Edit</a></td>
  <td class="listLine<%= ( count % 2 ) %>"><a href="database.jsp?mode=delete&bannerId=<%= bannerId %>&bannerName=<%= URLEncoder.encode( bannerName ) %>&assetId=<%= assetId %>" onclick="return confirm( 'Are you sure you wish to delete the <%= bannerName %> Banner?' )">Delete</a></td>
</tr>
<%

  count++;
}

rs.close();
ps.close();

if( count == 0 )
{

%><tr>
  <td colspan="6" class="listSubHead">No Banners Found</td>
</tr>
<%

}

%>
<tr>
  <td colspan="6" class="formButtons"><a href="edit.jsp">Add a Banner</a></td>
</tr>
</table>
</body>
</html><%

conn.close();

%>