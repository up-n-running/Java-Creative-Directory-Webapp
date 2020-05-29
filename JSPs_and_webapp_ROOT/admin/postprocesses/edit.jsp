<%@ page language="java"
  import="com.extware.asset.image.PostProcess,
          com.extware.utils.DatabaseUtils,
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

String SELECT_TYPE_SQL             = "SELECT assetTypeName FROM assetTypes WHERE assetTypeId=?";
String SELECT_LINKED_PROCESSES_SQL = "SELECT p.postProcessId, p.processName FROM imagePostProcesses p INNER JOIN assetTypePostProcesses t ON t.postProcessId=p.postProcessId WHERE t.assetTypeId=? ORDER BY p.processName";
String SELECT_OTHER_PROCESSES_SQL  = "SELECT p.postProcessId, p.processName FROM imagePostProcesses p WHERE p.postProcessId NOT IN( SELECT t.postProcessId FROM assetTypePostProcesses t WHERE t.assetTypeId=? ) ORDER BY p.processName";

double squareAspectTolerance = NumberUtils.parseDouble( request.getParameter( "squareAspectTolerance" ), 0.1D );

int postProcessId = NumberUtils.parseInt( request.getParameter( "postProcessId" ), -1 );
int landscapeX    = NumberUtils.parseInt( request.getParameter( "landscapeX" ),    -1 );
int landscapeY    = NumberUtils.parseInt( request.getParameter( "landscapeY" ),    -1 );
int square        = NumberUtils.parseInt( request.getParameter( "square" ),        -1 );
int portraitX     = NumberUtils.parseInt( request.getParameter( "portraitX" ),     -1 );
int portraitY     = NumberUtils.parseInt( request.getParameter( "portraitY" ),     -1 );

String mode          = "Edit";
String errors        = StringUtils.nullString( request.getParameter( "errors" ) ).trim();
String message       = StringUtils.nullString( request.getParameter( "message" ) ).trim();
String processName   = StringUtils.nullString( request.getParameter( "processName" ) ).trim();
String fileExtension = StringUtils.nullString( request.getParameter( "fileExtension" ) ).trim();
String backFill      = StringUtils.nullString( request.getParameter( "backFill" ) ).trim();

int quality = NumberUtils.parseInt( StringUtils.nullReplace( request.getParameter( "quality" + fileExtension ), request.getParameter( "quality" ) ), -1 );

PropertyFile imageProcProps = new PropertyFile( "com.extware.properties.ImageProcessor" );
PostProcess postProcess;

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

if( postProcessId != -1 )
{
  postProcess = new PostProcess( postProcessId, conn );
  postProcess.getRow();
}
else
{
  mode = "Add";
  postProcess = new PostProcess( processName, landscapeX, landscapeY, square, squareAspectTolerance, portraitX, portraitY, fileExtension, quality, backFill );
}

postProcess.processName   = StringUtils.nullString( postProcess.processName );
postProcess.fileExtension = StringUtils.nullString( postProcess.fileExtension );
postProcess.backFill      = StringUtils.nullString( postProcess.backFill );

%><html>
<head>
  <title>Image Size Rules Admin</title>
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
    getElt( divId ).style.backgroundImage = "url('<%= "/" + imageProcProps.getString( "backfill.dir" ) + "/" %>" + imgName + "')";
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
<input type="hidden" name="postProcessId" value="<%= postProcessId %>"/>
<table border="0" cellpadding="0" cellspacing="0">
<tr>
  <td colspan="2" class="title"><%= mode %> an Image Size Rule</td>
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
  <td class="formLabel">Rule Name</td>
  <td colspan="2"><input type="text" name="processName" value="<%= postProcess.processName %>" class="formElement"/></td>
</tr>

<tr>
  <td class="formLabel">Landscape Extents</td>
  <td>Max X<br /><input type="text" name="landscapeX" value="<%= postProcess.landscapeX %>" size="4" class="formElement"/></td>
  <td>Max Y<br /><input type="text" name="landscapeY" value="<%= postProcess.landscapeY %>" size="4" class="formElement"/></td>
  <td class="note">Leave blank or -1 to indicate no restriction in that direction.</td>
</tr>

<tr>
  <td class="formLabel">Portrait Extents</td>
  <td>Max X<br /><input type="text" name="portraitX" value="<%= postProcess.portraitX %>" size="4" class="formElement"/></td>
  <td>Max Y<br /><input type="text" name="portraitY" value="<%= postProcess.portraitY %>" size="4" class="formElement"/></td>
  <td class="note">Leave blank or -1 to indicate no restriction in that direction.</td>
</tr>

<tr>
  <td class="formLabel">Square Extents</td>
  <td>Max Dimension<br /><input type="text" name="square" value="<%= postProcess.square %>" size="4" class="formElement"/></td>
  <td>Tolerance<br /><input type="text" name="squareAspectTolerance" value="<%= postProcess.squareAspectTolerance %>" size="4" class="formElement"/></td>
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

%>      <option<%= ( ( fileExtensions[i].equals( postProcess.fileExtension ) ) ? " selected=\"selected\"" : "" ) %>><%= fileExtensions[i] %></option>
<%

  }

%>
    </select></td>
  <td>
<%

  for( int i = 0 ; i < fileExtensions.length ; i++ )
  {

%>    <div id="qual<%= i %>" style="display: <%= ( ( fileExtensions[i].equals( postProcess.fileExtension ) || ( postProcess.fileExtension.equals( "" ) && i == 0 ) ) ? "block" : "none" ) %>"><%= imageProcProps.getString( "process.quality." + fileExtensions[i] + ".title" ) %><br />
      <select name="quality<%= fileExtensions[i] %>" class="formElement">
<%

    qualities      = StringUtils.split( imageProcProps.getString( "process.quality." + fileExtensions[i] + ".values" ), "\\s*,\\s*" );
    defaultQuality = StringUtils.nullString( imageProcProps.getString( "process.quality." + fileExtensions[i] + ".default" ) );

    if( postProcess.quality > 0 )
    {
      defaultQuality = String.valueOf( postProcess.quality );
    }

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
  <td>Format<br /><input type="text" name="fileExtension" value="<%= postProcess.fileExtension %>" size="4" class="formElement"/></td>
  <td>Quality<br /><input type="text" name="quality" value="<%= postProcess.quality %>" size="4" class="formElement"/></td>
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

%>      <option<%= ( ( backfills[i].equals( postProcess.backFill ) ) ? " selected=\"selected\"" : "" ) %>><%= backfills[i] %></option>
<%

  }

%>
    </select></td>
  <td>View<br />
    <div id="bfTest" style="width:100px;height:100px;border:1px solid black<%= ( ( !postProcess.backFill.equals( "" ) ) ? ";background-image:url('/" + imageProcProps.getString( "backfill.dir" ) + "/" + postProcess.backFill + "')" : "" ) %>"></div></td>
</tr>
<%

}

%>
<tr>
  <td colspan="3" class="formButtons"><input type="button" onclick="document.location.href='index.jsp'" value="Cancel" class="formButton" /> <input type="submit" name="mode" value="<%= mode %>" class="formButton" /></td>
</tr>
</table>
</form>
</body>
</html><%

conn.close();

%>