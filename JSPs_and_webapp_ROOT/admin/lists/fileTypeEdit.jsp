<%@ page language="java"
  import="com.extware.utils.DatabaseUtils,
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

String SELECT_FILE_TYPE_SQL   = "SELECT assetTypeName, assetTypeId FROM listTypeAssetTypes WHERE listTypeAssetTypeId=?";
String SELECT_ASSET_TYPES_SQL = "SELECT assetTypeId, assetTypeName FROM assetTypes ORDER BY assetTypeName";

int thisAssetTypeId;
int listTypeId          = NumberUtils.parseInt( request.getParameter( "listTypeId" ),          -1 );
int assetTypeId         = NumberUtils.parseInt( request.getParameter( "assetTypeId" ),         -1 );
int listTypeAssetTypeId = NumberUtils.parseInt( request.getParameter( "listTypeAssetTypeId" ), -1 );

String thisAssetTypeName;
String mode              = "Edit";
String errors            = StringUtils.nullString( request.getParameter( "errors" ) ).trim();
String message           = StringUtils.nullString( request.getParameter( "message" ) ).trim();
String listName          = StringUtils.nullString( request.getParameter( "listName" ) ).trim();
String assetTypeName     = StringUtils.nullString( request.getParameter( "assetTypeName" ) ).trim();

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

if( listTypeAssetTypeId != -1 )
{
  ps = conn.prepareStatement( SELECT_FILE_TYPE_SQL );
  ps.setInt( 1, listTypeAssetTypeId );
  rs = ps.executeQuery();

  if( rs.next() )
  {
    assetTypeName = rs.getString( "assetTypeName" );
    assetTypeId   = rs.getInt(    "assetTypeId" );
  }

  rs.close();
  ps.close();
}
else
{
  mode = "Add";
}

%><html>
<head>
  <title>List Admin</title>
  <link rel="stylesheet" href="/style/admin.css" type="text/css">
</head>
<body class="adminPane">
<form action="fileTypeDatabase.jsp" method="post">
<input type="hidden" name="listTypeId" value="<%= listTypeId %>" />
<input type="hidden" name="listName" value="<%= listName %>" />
<input type="hidden" name="listTypeAssetTypeId" value="<%= listTypeAssetTypeId %>" />
<input type="hidden" name="mode" value="<%= mode.toLowerCase() %>" />
<table border="0" cellpadding="0" cellpadding="0">
<tr>
  <td colspan="2" class="title"><%= mode %> a File Type for <%= listName %></td>
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

%>
<tr>
  <td class="formLabel">File Type Name</td>
  <td><input type="text" class="formElement" name="assetTypeName" value="<%= assetTypeName %>" /></td>
</tr>
<tr>
  <td class="formLabel">Asset Type</td>
  <td><select name="assetTypeId" class="formElement">
<%

ps = conn.prepareStatement( SELECT_ASSET_TYPES_SQL );
rs = ps.executeQuery();

while( rs.next() )
{
  thisAssetTypeId   = rs.getInt(    "assetTypeId" );
  thisAssetTypeName = rs.getString( "assetTypeName" );

%>      <option value="<%= thisAssetTypeId %>"<%= ( ( thisAssetTypeId == assetTypeId ) ? " selected=\"selected\"" : "" ) %>><%= thisAssetTypeName %></option>
<%

}

%>
    </select></td>
</tr>
<tr>
  <td colspan="2" class="formButtons"><input type="button" onclick="document.location.href='fileTypes.jsp?listTypeId=<%= listTypeId %>&listName=<%= URLEncoder.encode( listName ) %>'" value="Cancel" class="formButton" /> <input type="submit" value="<%= mode %>" class="formButton" /></td>
</tr>

</table>
</form>
</body>
</html><%

conn.close();

%>