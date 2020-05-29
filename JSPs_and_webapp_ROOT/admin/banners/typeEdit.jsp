<%@ page language="java"
  import="com.extware.utils.DatabaseUtils,
          com.extware.utils.NumberUtils,
          com.extware.utils.StringUtils,
          com.extware.user.UserDetails,
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

String SELECT_BANNER_TYPE_SQL = "SELECT bannerTypeName, assetTypeId, displayWidth, displayHeight FROM bannerTypes WHERE bannerTypeId=?";
String SELECT_ASSET_TYPES_SQL = "SELECT assetTypeId, assetTypeName FROM assetTypes ORDER BY assetTypeName";

int thisAssetTypeId;
int bannerTypeId    = NumberUtils.parseInt( request.getParameter( "bannerTypeId" ),  -1 );
int assetTypeId     = NumberUtils.parseInt( request.getParameter( "assetTypeId" ),   -1 );
int displayWidth    = NumberUtils.parseInt( request.getParameter( "displayWidth" ),  468 );
int displayHeight   = NumberUtils.parseInt( request.getParameter( "displayHeight" ),  60 );

String assetTypeName;
String mode           = "Edit";
String bannerTypeName = StringUtils.nullString( request.getParameter( "bannerTypeName" ) ).trim();
String errors         = StringUtils.nullString( request.getParameter( "errors" ) ).trim();
String message        = StringUtils.nullString( request.getParameter( "message" ) ).trim();

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

if( bannerTypeId != -1 )
{
  ps = conn.prepareStatement( SELECT_BANNER_TYPE_SQL );
  ps.setInt( 1, bannerTypeId );
  rs = ps.executeQuery();

  if( rs.next() )
  {
    bannerTypeName = rs.getString( "bannerTypeName" );
    assetTypeId    = rs.getInt(    "assetTypeId" );
    displayWidth   = rs.getInt(    "displayWidth" );
    displayHeight  = rs.getInt(    "displayHeight" );
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
  <title>Banner Type Admin</title>
  <link rel="stylesheet" href="/style/admin.css" type="text/css">
</head>
<body class="adminPane">
<form action="typeDatabase.jsp" method="post">
<input type="hidden" name="bannerTypeId" value="<%= bannerTypeId %>" />
<input type="hidden" name="mode" value="<%= mode.toLowerCase() %>" />
<table border="0" cellpadding="0" cellpadding="0">
<tr>
  <td colspan="2" class="title"><%= mode %> a Banner Type</td>
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
  <td class="formLabel">Banner Type Name</td>
  <td><input type="text" class="formElement" name="bannerTypeName" value="<%= bannerTypeName %>" /></td>
</tr>
<tr>
  <td class="formLabel">Asset Type</td>
  <td><select class="formElement" name="assetTypeId">
<%

ps = conn.prepareStatement( SELECT_ASSET_TYPES_SQL );
rs = ps.executeQuery();

while( rs.next() )
{
  thisAssetTypeId = rs.getInt(    "assetTypeId" );
  assetTypeName   = rs.getString( "assetTypeName" );

%>      <option value="<%= thisAssetTypeId %>"<%= ( ( thisAssetTypeId == assetTypeId || ( assetTypeId == -1 && assetTypeName.toLowerCase().equals( "banner" ) ) ) ? " selected=\"selected\"" : "" ) %>><%= assetTypeName %></option>
<%

}

rs.close();
ps.close();

%>
    </select></td>
</tr>
<tr>
  <td class="formLabel">Display Width</td>
  <td><input type="text" class="formElement" name="displayWidth" value="<%= displayWidth %>" size="4" /></td>
</tr>
<tr>
  <td class="formLabel">Display Height</td>
  <td><input type="text" class="formElement" name="displayHeight" value="<%= displayHeight %>" size="4" /></td>
</tr>
<tr>
  <td colspan="2" class="formButtons"><input type="button" onclick="document.location.href='types.jsp'" value="Cancel" class="formButton" /> <input type="submit" value="<%= mode %>" class="formButton" /></td>
</tr>
</table>
</form>
</body>
</html><%

conn.close();

%>