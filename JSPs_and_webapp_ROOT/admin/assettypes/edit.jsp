<%@ page language="java"
  import="com.extware.utils.DatabaseUtils,
          com.extware.utils.FileUtils,
          com.extware.utils.NumberUtils,
          com.extware.utils.PropertyFile,
          com.extware.utils.SiteUtils,
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

String SELECT_TYPE_SQL             = "SELECT assetTypeName, assetTypeHandle FROM assetTypes WHERE assetTypeId=?";
String SELECT_LINKED_PROCESSES_SQL = "SELECT p.postProcessId, p.processName FROM imagePostProcesses p INNER JOIN assetTypePostProcesses t ON t.postProcessId=p.postProcessId WHERE t.assetTypeId=? ORDER BY p.processName";
String SELECT_OTHER_PROCESSES_SQL  = "SELECT p.postProcessId, p.processName FROM imagePostProcesses p WHERE p.postProcessId NOT IN( SELECT t.postProcessId FROM assetTypePostProcesses t WHERE t.assetTypeId=? ) ORDER BY p.processName";

int count;
int postProcessId;
int assetTypeId   = NumberUtils.parseInt( request.getParameter( "assetTypeId" ), -1 );

String processName;
String mode            = "Edit";
String errors          = StringUtils.nullString( request.getParameter( "errors" ) ).trim();
String message         = StringUtils.nullString( request.getParameter( "message" ) ).trim();
String assetTypeName   = StringUtils.nullString( request.getParameter( "assetTypeName" ) ).trim();
String assetTypeHandle = StringUtils.nullString( request.getParameter( "assetTypeHandle" ) ).trim();

PropertyFile imageProcProps = new PropertyFile( "com.extware.properties.ImageProcessor" );

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

if( assetTypeId != -1 )
{
  ps = conn.prepareStatement( SELECT_TYPE_SQL );
  ps.setInt( 1, assetTypeId );
  rs = ps.executeQuery();

  if( rs.next() )
  {
    assetTypeName   = rs.getString( "assetTypeName" );
    assetTypeHandle = rs.getString( "assetTypeHandle" );
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
  <title>Asset Types Admin</title>
  <link rel="stylesheet" href="/style/admin.css" type="text/css">
<script type="text/javascript" src="/js/layer.js"></script>
<script type="text/javascript">
function showQual( elem )
{
  for( var i = 0 ; i < elem.options.length ; i++ )
  {
    getElt( "qual" + i ).style.display = "none";
  }

  getElt( "qual" + elem.selectedIndex ).style.display = "block";
}

function showimg( elem, divId )
{
  var imgName = elem.options[elem.selectedIndex].text;

  if( imgName != "None" )
  {
    getElt( divId ).style.backgroundImage = "URL('<%= "/" + imageProcProps.getString( "backfill.dir" ) + "/" %>" + imgName + "')";
  }
  else
  {
    getElt( divId ).style.backgroundImage = "none";
  }
}
</script>
</head>
<body class="adminPane">
<form action="database.jsp" method="post">
<input type="hidden" name="mode" value="<%= mode.toLowerCase() %>"/>
<input type="hidden" name="assetTypeId" value="<%= assetTypeId %>"/>
<table border="0" cellpadding="0" cellspacing="0">
<tr>
  <td colspan="2" class="title"><%= mode %> an Asset Type</td>
</tr>
<%

if( !errors.equals( "" ) )
{

%><tr>
  <td colspan="2" class="error"><%= errors %></td>
</tr>
<%

}

if( !message.equals( "" ) )
{

%><tr>
  <td colspan="2" class="message"><%= message %></td>
</tr>
<%

}

%>
<tr>
  <td class="formLabel">Asset Type Name</td>
  <td><input type="text" name="assetTypeName" value="<%= assetTypeName %>" class="formElement"/></td>
</tr>

<tr>
  <td class="formLabel">Asset Type Handle<br /><span class="note">Will be used as the directory to save assets under</span></td>
  <td><input type="text" name="assetTypeHandle" value="<%= assetTypeHandle %>" class="formElement"/></td>
</tr>

<tr>
  <td colspan="2" class="formButtons"><input type="button" onclick="document.location.href='index.jsp'" value="Cancel" class="formButton" /> <input type="submit" value="<%= mode %>" class="formButton" /></td>
</tr>
</table>
</form>
<%

if( mode.equals( "Edit" ) )
{

%>
<table border="0" cellpadding="0" cellspacing="0">
<tr>
  <td colspan="2" class="title">Image Size Rules</td>
</tr>
<%

  count = 0;

  ps = conn.prepareStatement( SELECT_LINKED_PROCESSES_SQL );
  ps.setInt( 1, assetTypeId );
  rs = ps.executeQuery();

  while( rs.next() )
  {
    if( count == 0 )
    {

%><tr>
  <td class="listHead">Rule Name</td>
  <td class="listHead"></td>
</tr>
<%

    }

    postProcessId = rs.getInt(    "postProcessId" );
    processName   = rs.getString( "processName" );

%><tr>
  <td class="listLine<%= ( count % 2 ) %>"><%= processName %></td>
  <td class="listLine<%= ( count % 2 ) %>"><a href="processDatabase.jsp?mode=deleteLink&assetTypeId=<%= assetTypeId %>&postProcessId=<%= postProcessId %>&processName=<%= URLEncoder.encode( processName ) %>" onclick="return confirm( 'Are you sure you wish to remove this Rule from this Asset Type' )">Remove</a></td>
</tr>
<%

    count++;
  }

  rs.close();
  ps.close();

  if( count == 0 )
  {

%><tr>
  <td colspan="2" class="listSubHead">No Rules for this Asset Type</td>
</tr>
<%

  }

%>
</table>

<form action="processDatabase.jsp" method="post">
<input type="hidden" name="assetTypeId" value="<%= assetTypeId %>"/>
<table border="0" cellpadding="0" cellspacing="0">
<tr>
  <td colspan="3" class="subHead">Add an existing Image Size Rule</td>
</tr>
<tr>
  <td colspan="3"><select name="postProcessId" class="formElement">
<%

  count = 0;

  ps = conn.prepareStatement( SELECT_OTHER_PROCESSES_SQL );
  ps.setInt( 1, assetTypeId );
  rs = ps.executeQuery();

  while( rs.next() )
  {
    postProcessId = rs.getInt(    "postProcessId" );
    processName   = rs.getString( "processName" );

%>      <option value="<%= postProcessId %>"><%= processName %></option>
<%

    count++;
  }

  if( count == 0 )
  {

%>      <option value="-1">No Avaialble Rules</option>
<%

  }

%>
    </select></td>
</tr>
<%

  if( count != 0 )
  {

%>
<tr>
  <td colspan="3" class="formButtons"><input type="submit" name="mode" value="Add Existing" class="formButton"/></td>
</tr>
<%

  }

%><tr>
  <td colspan="3" class="subHead">Add a new Image Size Rule</td>
</tr>

<tr>
  <td class="formLabel">Rule Name</td>
  <td colspan="2"><input type="text" name="processName" value="" class="formElement"/></td>
</tr>

<tr>
  <td class="formLabel">Landscape Extents</td>
  <td>Max X<br /><input type="text" name="landscapeX" value="" size="4" class="formElement"/></td>
  <td>Max Y<br /><input type="text" name="landscapeY" value="" size="4" class="formElement"/></td>
  <td class="note">Leave blank or -1 to indicate no restriction in that direction.</td>
</tr>

<tr>
  <td class="formLabel">Portrait Extents</td>
  <td>Max X<br /><input type="text" name="portraitX" value="" size="4" class="formElement"/></td>
  <td>Max Y<br /><input type="text" name="portraitY" value="" size="4" class="formElement"/></td>
  <td class="note">Leave blank or -1 to indicate no restriction in that direction.</td>
</tr>

<tr>
  <td class="formLabel">Square Extents</td>
  <td>Max Dimension<br /><input type="text" name="square" value="" size="4" class="formElement"/></td>
  <td>Tolerance<br /><input type="text" name="squareAspectTolerance" value="0.1" size="4" class="formElement"/></td>
</tr>
<tr>
  <td class="formLabel">Image Format</td>
<%

if( imageProcProps.getString( "process.types" ) != null )
{

String   defaultQuality;
String[] fileExtensions = StringUtils.split( imageProcProps.getString( "process.types" ), "\\s*,\\s*" );
String[] qualities;

%>
  <td>Format<br /><select name="fileExtension" onchange="showQual(this)" class="formElement">
<%

  for( int i = 0 ; i < fileExtensions.length ; i++ )
  {

%>      <option><%= fileExtensions[i] %></option>
<%

  }

%>
    </select></td>
  <td>
<%

  for( int i = 0 ; i < fileExtensions.length ; i++ )
  {

%>    <div id="qual<%= i %>" style="display: <%= ( ( i == 0 ) ? "block" : "none" ) %>"><%= imageProcProps.getString( "process.quality." + fileExtensions[i] + ".title" ) %><br />
      <select name="quality<%= fileExtensions[i] %>" class="formElement">
<%

    qualities      = StringUtils.split( imageProcProps.getString( "process.quality." + fileExtensions[i] + ".values" ), "\\s*,\\s*" );
    defaultQuality = StringUtils.nullString( imageProcProps.getString( "process.quality." + fileExtensions[i] + ".default" ) );

    for( int j = 0 ; j < qualities.length ; j++ )
    {

%>      <option<%= ( ( qualities[j].equals( defaultQuality ) ) ? " selected=\"selected\"" : "" ) %>><%= qualities[j] %></option>
<%

    }

%>
      </select></div>
<%

  }

%>
  </td>
<%

}
else
{

%>
  <td>Format<br /><input type="text" name="fileExtension" value="jpg" size="4" class="formElement"/></td>
  <td>Quality<br /><input type="text" name="quality" value="76" size="4" class="formElement"/></td>
<%

}

%>
</tr>
<%

String[] backfills = FileUtils.getDirectoryListing( SiteUtils.getWebappRoot() + "/" + imageProcProps.getString( "backfill.dir" ) );

if( backfills != null && backfills.length > 0 )
{

%>
<tr>
  <td class="formLabel">Backfill Image</td>
  <td>Image<br />
    <select name="backFill" onchange="showimg(this,'bfTest')" class="formElement">
      <option value="">None</option>
<%

  for( int i = 0 ; i < backfills.length ; i++ )
  {

%>      <option><%= backfills[i] %></option>
<%

  }

%>
    </select></td>
  <td>View<br />
    <div id="bfTest" style="width:100px;height:100px;border:1px solid black"></div></td>
</tr>
<%

}

%>
<tr>
  <td colspan="3" class="formButtons"><input type="submit" name="mode" value="Add New" class="formButton" /></td>
</tr>
</table>
</form>
<%

}

%>
</body>
</html><%

conn.close();

%>