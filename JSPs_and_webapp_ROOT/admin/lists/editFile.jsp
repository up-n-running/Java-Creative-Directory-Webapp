<%@ page language="java"
  import="com.extware.asset.Asset,
          com.extware.asset.image.PostProcess,
          com.extware.utils.DatabaseUtils,
          com.extware.utils.NumberUtils,
          com.extware.utils.PropertyFile,
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
String SELECT_FILE_INFO_SQL = "SELECT f.title, l.listTypeAssetTypeId, a.assetId FROM listItemFiles f INNER JOIN assets a ON f.assetId=a.assetId INNER JOIN assetTypes t ON a.assetTypeId=t.assetTypeId INNER JOIN listTypeAssetTypes l ON l.assetTypeId=t.assetTypeId WHERE f.listItemFileId=?";
String SELECT_TYPE_INFO_SQL = "SELECT listTypeAssetTypeId, assetTypeName FROM listTypeAssetTypes WHERE listTypeId=?";

int dbAssetTypeId;
int assetId             = -1;
int listTypeId          = NumberUtils.parseInt( request.getParameter( "listTypeId" ),          -1 );
int listItemId          = NumberUtils.parseInt( request.getParameter( "listItemId" ),          -1 );
int listItemFileId      = NumberUtils.parseInt( request.getParameter( "listItemFileId" ),      -1 );
int listTypeAssetTypeId = NumberUtils.parseInt( request.getParameter( "listTypeAssetTypeId" ), -1 );

String assetTypeName;
String itemTitle     = "";
String mode          = "Edit";
String errors        = StringUtils.nullString( request.getParameter( "errors" ) ).trim();
String message       = StringUtils.nullString( request.getParameter( "message" ) ).trim();
String title         = StringUtils.nullString( request.getParameter( "title" ) ).trim();

PropertyFile dataDictionary = PropertyFile.getDataDictionary();

Asset asset = null;

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

if( listItemFileId != -1 )
{
  ps = conn.prepareStatement( SELECT_FILE_INFO_SQL );
  ps.setInt( 1, listItemFileId );
  rs = ps.executeQuery();

  if( rs.next() )
  {
    title               = rs.getString( "title" );
    listTypeAssetTypeId = rs.getInt(    "listTypeAssetTypeId" );
    assetId             = rs.getInt(    "assetId" );
  }

  rs.close();
  ps.close();

  if( assetId != -1 )
  {
    asset = new Asset( assetId, conn );
  }
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
<form action="fileDatabase.jsp" method="post" enctype="multipart/form-data">
<input type="hidden" name="listTypeId" value="<%= listTypeId %>" />
<input type="hidden" name="listItemId" value="<%= listItemId %>" />
<input type="hidden" name="listItemFileId" value="<%= listItemFileId %>" />
<input type="hidden" name="assetId" value="<%= assetId %>" />
<input type="hidden" name="mode" value="<%= mode.toLowerCase() %>" />
<table border="0" cellpadding="0" cellpadding="0">
<tr>
  <td colspan="3" class="title"><%= itemTitle %>: <%= mode %> a File</td>
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
  <td class="formLabel">File Type</td>
  <td><select name="listTypeAssetTypeId" class="formElement">
<%

ps = conn.prepareStatement( SELECT_TYPE_INFO_SQL );
ps.setInt( 1, listTypeId );
rs = ps.executeQuery();

while( rs.next() )
{
  dbAssetTypeId = rs.getInt(    "listTypeAssetTypeId" );
  assetTypeName = rs.getString( "assetTypeName" );

%>      <option value="<%= dbAssetTypeId %>"<%= ( ( dbAssetTypeId == listTypeAssetTypeId ) ? " selected=\"selected\"" : "" ) %>><%= assetTypeName %></option>
<%

}

rs.close();
ps.close();

%>
    </select></td>
</tr>

<tr>
  <td class="formLabel">File Title</td>
  <td colspan="2"><input type="text" name="title" value="<%= title %>" class="formElement" size="64" maxlength="64" /></td>
</tr>

<tr>
  <td class="formLabel">File</td>
  <td><input type="file" name="file" class="formElement" size="30" /></td>
  <td><%

if( asset != null )
{
  if( asset.postProcesses != null && asset.postProcesses.size() > 0 )
  {
    PostProcess assetTypePostProcess = asset.getPostProcess( "Thumbnail" );

    if( assetTypePostProcess != null )
    {

%><img src="/<%= dataDictionary.getString( "asset.dir.proccessed." + asset.assetTypeId ) + "/" + asset.getImagePath( assetTypePostProcess ) %>" /><%

    }
    else
    {
      out.print( "Null assetTypePostProcess" );
    }
  }
  else
  {
    out.print( "Null postProcesses" );
  }
}
else
{
  out.print( "Null Asset" );
}

%></td>

</tr>

<tr>
  <td colspan="3" class="formButtons"><input type="button" onclick="document.location.href='files.jsp?listItemId=<%= listItemId %>&listTypeId=<%= listTypeId %>'" value="Cancel" class="formButton" /> <input type="submit" value="<%= mode %>" class="formButton" /></td>
</tr>
</table>
</form>
</body>
</html><%

conn.close();

%>