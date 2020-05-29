<%@ page language="java"
  import="com.extware.extsite.lists.ListItemFile,
          com.extware.utils.BooleanUtils,
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

if( !user.isUltra() )
{
  response.sendRedirect( "/admin/blank.html" );
  return;
}

String SELECT_FILE_TYPES_SQL = "SELECT listTypeAssetTypeId, assetTypeName, fileType, defaultType FROM listTypeAssetTypes WHERE listTypeId=? ORDER BY fileType, assetTypeName";

boolean defaultType = false;

int count;
int fileType;
int listTypeAssetTypeId;
int oldFileType         = 0;
int listTypeId          = NumberUtils.parseInt( request.getParameter( "listTypeId" ), -1 );

String assetTypeName;
String listName      = StringUtils.nullString( request.getParameter( "listName" ) ).trim();
String errors        = StringUtils.nullString( request.getParameter( "errors" ) ).trim();
String message       = StringUtils.nullString( request.getParameter( "message" ) ).trim();

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

%><html>
<head>
  <title>File Types Admin</title>
  <link rel="stylesheet" href="/style/admin.css" type="text/css">
</head>
<body class="adminPane">
<table border="0" cellpadding="0" cellspacing="0">
<tr>
  <td colspan="4" class="title">File Types for <%= listName %></td>
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

ps = conn.prepareStatement( SELECT_FILE_TYPES_SQL );
ps.setInt( 1, listTypeId );
rs = ps.executeQuery();

while( rs.next() )
{
  if( count == 0 )
  {

%>
<tr>
  <td class="listHead">Default</td>
  <td class="listHead">List Type Name</td>
  <td colspan="2" class="listHead"></td>
</tr>
<%

  }

  listTypeAssetTypeId = rs.getInt(    "listTypeAssetTypeId" );
  assetTypeName       = rs.getString( "assetTypeName" );
  fileType            = rs.getInt(    "fileType" );
  defaultType         = BooleanUtils.parseBoolean( rs.getString( "defaultType" ) );

  if( fileType != oldFileType )
  {

%>
<tr>
  <td colspan="4" class="listSubHead"><%= ListItemFile.getFileTypeName( fileType ) %></td>
</tr>
<%

    oldFileType = fileType;
  }

%><tr>
  <td class="listLine<%= ( count % 2 ) %>"><%

  if( fileType == ListItemFile.FILE_TYPE_INLINE )
  {

%><a href="fileTypeDatabase.jsp?mode=default&listTypeId=<%= listTypeId %>&listName=<%= URLEncoder.encode( listName ) %>&listTypeAssetTypeId=<%= listTypeAssetTypeId %>" title="Set as Default File Type"><img src="/art/admin/<%= ( ( defaultType ) ? "" : "no" ) %>tick.gif"/></a><%

  }

%></td>
  <td class="listLine<%= ( count % 2 ) %>"><%= assetTypeName %></td>
  <td class="listLine<%= ( count % 2 ) %>"><a href="fileTypeEdit.jsp?listTypeId=<%= listTypeId %>&listName=<%= URLEncoder.encode( listName ) %>&listTypeAssetTypeId=<%= listTypeAssetTypeId %>">Edit</a></td>
  <td class="listLine<%= ( count % 2 ) %>"><a href="fileTypeDatabase.jsp?mode=delete&listTypeId=<%= listTypeId %>&listName=<%= URLEncoder.encode( listName ) %>&listTypeAssetTypeId=<%= listTypeAssetTypeId %>&assetTypeName=<%= URLEncoder.encode( assetTypeName ) %>" onclick="return confirm( 'Are you sure you wish to delete the <%= assetTypeName %> File Type' )">Delete</a></td>
</tr>
<%

  count++;
}

rs.close();
ps.close();

if( count == 0 )
{

%><tr>
  <td colspan="4" class="listSubHead">No File Types Found</td>
</tr>
<%

}

%>
<tr>
  <td colspan="4" class="formButtons"><a href="index.jsp">Back</a> | <a href="fileTypeEdit.jsp?listTypeId=<%= listTypeId %>&listName=<%= URLEncoder.encode( listName ) %>">Add a File Type</a></td>
</tr>
</table>
</body>
</html><%

conn.close();

%>