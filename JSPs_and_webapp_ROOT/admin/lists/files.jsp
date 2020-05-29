<%@ page language="java"
  import="com.extware.utils.BooleanUtils,
          com.extware.utils.DatabaseUtils,
          com.extware.utils.NumberUtils,
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

String SELECT_ITEM_INFO_SQL = "SELECT title FROM listItems WHERE listItemId=?";
String SELECT_FILES_SQL     = "SELECT f.listItemFileId, f.title, f.fileType, l.assetTypeName, f.assetId, l.defaultType, f.defaultFile FROM listItemFiles f INNER JOIN listTypeAssetTypes l ON f.listTypeAssetTypeId=l.listTypeAssetTypeId WHERE f.listItemId=? ORDER BY f.fileType, l.assetTypeName, f.title";

boolean defaultType;
boolean defaultFile;

int count;
int assetId;
int fileType;
int listItemFileId;
int listTypeId     = NumberUtils.parseInt( request.getParameter( "listTypeId" ), -1 );
int listItemId     = NumberUtils.parseInt( request.getParameter( "listItemId" ), -1 );

String assetTypeName;
String fileTitle         = "";
String itemTitle         = "";
String lastAssetTypeName = "";
String errors            = StringUtils.nullString( request.getParameter( "errors" ) ).trim();
String message           = StringUtils.nullString( request.getParameter( "message" ) ).trim();

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

ps = conn.prepareStatement( SELECT_ITEM_INFO_SQL );
ps.setInt( 1, listItemId );
rs = ps.executeQuery();

if( rs.next() )
{
  itemTitle = rs.getString( "title" );
}

rs.close();
ps.close();

%><html>
<head>
  <title>List Admin</title>
  <link rel="stylesheet" href="/style/admin.css" type="text/css">
</head>
<body class="adminPane">
<table border="0" cellpadding="0" cellspacing="0">
<tr>
  <td colspan="4" class="title">Edit Files for <%= itemTitle %></td>
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

ps = conn.prepareStatement( SELECT_FILES_SQL );
ps.setInt( 1, listItemId );
rs = ps.executeQuery();

while( rs.next() )
{
  if( count == 0 )
  {

%><tr>
  <td class="listHead">Default</td>
  <td class="listHead">File Title</td>
  <td colspan="2" class="listHead"></td>
</tr>
<%

  }

  listItemFileId      = rs.getInt(    "listItemFileId" );
  fileTitle           = rs.getString( "title" );
  fileType            = rs.getInt(    "fileType" );
  assetTypeName       = rs.getString( "assetTypeName" );
  assetId             = rs.getInt(    "assetId" );
  defaultType         = BooleanUtils.parseBoolean( rs.getString( "defaultType" ) );
  defaultFile         = BooleanUtils.parseBoolean( rs.getString( "defaultFile" ) );

  if( !assetTypeName.equals( lastAssetTypeName ) )
  {

%><tr>
  <td colspan="4" class="listSubHead"><%= assetTypeName %></td>
</tr>
<%

    lastAssetTypeName = assetTypeName;
  }

%><tr>
  <td class="listLine<%= ( count % 2 ) %>"><%

  if( defaultType )
  {

%><a href="fileDatabase.jsp?mode=default&listItemFileId=<%= listItemFileId %>&listTypeId=<%= listTypeId %>&listItemId=<%= listItemId %>" title="Set as Default File"><img src="/art/admin/<%= ( ( defaultFile ) ? "" : "no" ) %>tick.gif"/></a><%

  }

%></td>
  <td class="listLine<%= ( count % 2 ) %>"><%= fileTitle %></td>
  <td class="listLine<%= ( count % 2 ) %>"><a href="editFile.jsp?listItemFileId=<%= listItemFileId %>&listTypeId=<%= listTypeId %>&listItemId=<%= listItemId %>">Edit</a></td>
  <td class="listLine<%= ( count % 2 ) %>"><a href="fileDatabase.jsp?mode=delete&assetId=<%= assetId %>&listItemFileId=<%= listItemFileId %>&listTypeId=<%= listTypeId %>&listItemId=<%= listItemId %>&title=<%= URLEncoder.encode( fileTitle ) %>" onclick="return confirm('Are you sure you wish to delete this file?')">Delete</a></td>
</tr>
<%

  count++;
}

rs.close();
ps.close();

if( count == 0 )
{

%><tr>
  <td colspan="4" class="listSubHead">No Files Found</td>
</tr>
<%

}

%>
<tr>
  <td colspan="4" class="formButtons"><a href="items.jsp?listTypeId=<%= listTypeId %>">Back</a> | <a href="editFile.jsp?listTypeId=<%= listTypeId %>&listItemId=<%= listItemId %>">Add a File</a></td>
</tr>
</table>
</body>
</html><%

conn.close();

%>