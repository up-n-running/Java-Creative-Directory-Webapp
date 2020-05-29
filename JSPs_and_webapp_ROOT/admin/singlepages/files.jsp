<%@ page language="java"
  import="com.extware.asset.Asset,
          com.extware.asset.image.PostProcess,
          com.extware.utils.DatabaseUtils,
          com.extware.utils.NumberUtils,
          com.extware.utils.PropertyFile,
          com.extware.utils.StringUtils,
          com.extware.user.UserDetails,
          com.extware.asset.Asset,
          java.util.ArrayList,
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

int textPageId  = NumberUtils.parseInt( request.getParameter( "textPageId" ), -1 );

/////////////////////////////

String SELECT_ITEM_INFO_SQL = "SELECT title FROM listItems WHERE listItemId=?";
String SELECT_FILE_INFO_SQL = "SELECT f.title, l.listTypeAssetTypeId, a.assetId FROM listItemFiles f INNER JOIN assets a ON f.assetId=a.assetId INNER JOIN assetTypes t ON a.assetTypeId=t.assetTypeId INNER JOIN listTypeAssetTypes l ON l.assetTypeId=t.assetTypeId WHERE f.listItemFileId=?";
String SELECT_TYPE_INFO_SQL = "SELECT listTypeAssetTypeId, assetTypeName FROM listTypeAssetTypes WHERE listTypeId=?";

String SELECT_FILES_SQL     = "SELECT tpf.assetId FROM textPageFiles tpf WHERE tpf.textPageId=? ORDER BY tpf.assetId";
String SELECT_POSTPROCESSES_SQL = "SELECT ipp.postProcessId, ipp.processName FROM imagePostProcesses ipp INNER JOIN assetTypePostProcesses atpp ON (ipp.postProcessId = atpp.postProcessId ) WHERE atpp.assetTypeId = ? ORDER BY ipp.square ASC";

PropertyFile dataDictionary = PropertyFile.getDataDictionary();
PropertyFile richTextProps = new PropertyFile( "com.extware.properties.RichText" );

int assetTypeId         = richTextProps.getInt( "richTextAssetTypeId" );
String errors        = StringUtils.nullString( request.getParameter( "errors" ) ).trim();
String message       = StringUtils.nullString( request.getParameter( "message" ) ).trim();
String pageName      = StringUtils.nullString( request.getParameter( "pageName" ) ).trim();
String title = null;

//Asset asset = null;

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

//ps = conn.prepareStatement( SELECT_ITEM_INFO_SQL );
//ps.setInt( 1, listItemId );
//rs = ps.executeQuery();
//
//if( rs.next() )
//{
//  itemTitle = rs.getString( "title" );
//}
//
//rs.close();
//ps.close();
//
//if( listItemFileId != -1 )
//{
//  ps = conn.prepareStatement( SELECT_FILE_INFO_SQL );
//  ps.setInt( 1, listItemFileId );
//  rs = ps.executeQuery();
//
//  if( rs.next() )
//  {
//    title               = rs.getString( "title" );
//    listTypeAssetTypeId = rs.getInt(    "listTypeAssetTypeId" );
//    assetId             = rs.getInt(    "assetId" );
//  }
//
//  rs.close();
//  ps.close();
//
//  if( assetId != -1 )
//  {
//    asset = new Asset( assetId, conn );
//  }
//}

%><html>
<head>
  <title>List Admin</title>
  <link rel="stylesheet" href="/style/admin.css" type="text/css">
</head>
<body class="adminPane">
<form action="fileDatabase.jsp" method="post" enctype="multipart/form-data">
<input type="hidden" name="textPageId" value="<%= textPageId %>" />
<input type="hidden" name="mode" value="add" />
<input type="hidden" name="pageName" value="<%= pageName %>" />


<table border="0" cellpadding="0" cellpadding="0">
<tr>
  <td colspan="1" class="title" style="padding-bottom: 4px">Image Bank</td>
</tr>
<%

if( !errors.equals( "" ) )
{

%><tr>
  <td colspan="1" class="error"><%= errors %></td>
</tr>
<%

}

if( !message.equals( "" ) )
{

%><tr>
  <td colspan="1" class="message"><%= message %></td>
</tr>
<%

}

%>
<!--
<tr>
  <td class="formLabel">File Title</td>
  <td colspan="2"><input type="text" name="title" value="<%= title %>" class="formElement" size="64" maxlength="64" /></td>
</tr>
-->

<tr>
  <td class="formLabel" style="text-align: left">Upload an image into bank...<br /><input type="file" name="file" class="formElement" size="10" /></td>
</tr>
<tr>
  <td class="formButtons" style="text-align: right"><input type="submit" value="Upload" class="formButton" /></td>
</tr>
</table>
</form>

<table border="0" cellpadding="0" cellpadding="0">
<tr>
  <td colspan="2" class="title" style="padding-bottom: 4px">Images in bank</td>
</tr>
<%

//fetch postprocess information
ps = conn.prepareStatement( SELECT_POSTPROCESSES_SQL );
ps.setInt( 1, assetTypeId );
rs = ps.executeQuery();
ArrayList postProcessNames = new ArrayList();

while( rs.next() )
{
  postProcessNames.add( rs.getString( "processName" ) );
}


//fetch asset information
ps = conn.prepareStatement( SELECT_FILES_SQL );
ps.setInt( 1, textPageId );
rs = ps.executeQuery();
int assetId = -1;
Asset asset = null;

while( rs.next() )
{
  assetId = rs.getInt( "assetId" );
  asset = new Asset( assetId );
%>
<tr>
  <td style="vertical-align: middle"><img ondrag="return false;" style="margin: auto" src="<%= "/" + dataDictionary.getString( "asset.dir.proccessed." + asset.assetTypeId ) + "/" + asset.getImagePath( "Thumbnail" ) %>" border="0" /></td>
  <td height="100%">
    <table border="0" height="100%" cellpadding="0" cellpadding="0">
<%
  for( int i=0; i<postProcessNames.size(); i++ )
  {
    String ppName = (String)postProcessNames.get( i );
    String imageUrl  = "/" + dataDictionary.getString( "asset.dir.proccessed." + asset.assetTypeId ) + "/" + asset.getImagePath( ppName ) ;
%>    <tr><td valign="top" class="formLabel" style="text-align: left"><%= ppName %>&nbsp;&nbsp;<a class="error" href="#" onclick="parent.AddImage( 'pageContent', '<%= imageUrl %>', 'left' ); return false" >L</a>/<a href="#" class="error" onclick="parent.AddImage( 'pageContent', '<%= imageUrl %>', 'right' ); return false" >R</a></td></tr>
<%
  }
%>
    <tr><td height="100%" class="error" style="vertical-align: bottom;" ><a href="fileDatabase.jsp?textPageId=<%= textPageId %>&mode=delete&pageName=<%= pageName %>&assetId=<%= asset.assetId %>" onclick="return confirm( 'You should not delete this image if it is being used in this content area.\nAre you sure you want to delete?' );" class="error">DELETE</a></td></tr>
    </table>
  </td>
</tr>

<%

}

rs.close();
ps.close();

%>





</body>
</html><%

conn.close();

%>