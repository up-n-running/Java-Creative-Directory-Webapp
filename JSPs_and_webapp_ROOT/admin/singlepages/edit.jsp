<%@ page language="java"
  import="com.extware.utils.BooleanUtils,
          com.extware.utils.DatabaseUtils,
          com.extware.utils.NumberUtils,
          com.extware.utils.PropertyFile,
          com.extware.utils.StringUtils,
          com.extware.user.UserDetails,
          com.extware.user.UserGroup,
          java.sql.Connection,
          java.sql.PreparedStatement,
          java.sql.ResultSet,
          java.util.ArrayList"
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

String SELECT_PAGE_SQL   = "SELECT pageName, pageHandle, pageContent FROM textPages WHERE textPageId=?";
String SELECT_GROUPS_SQL = "SELECT g.userGroupId, g.name, g.handle, x.textPageId FROM userGroups g LEFT JOIN textPageGroupXref x ON x.groupId=g.userGroupId AND x.textPageId=? ORDER BY g.name";

PropertyFile dataDictionary = PropertyFile.getDataDictionary();

//*String[] columnList = new String[] { "title", "standfirst", "body", "fromDate", "toDate", "liveDate", "removeDate", "formOrder" };

boolean visibleToGroup;
//*boolean visibleOnSite  = BooleanUtils.parseBoolean( request.getParameter( "visibleOnSite" ) );

int userGroupId;
int textPageId  = NumberUtils.parseInt( request.getParameter( "textPageId" ), -1 );

String groupName;
String groupHandle;
String mode            = "Edit";
String errors          = StringUtils.nullString( request.getParameter( "errors" ) ).trim();
String message         = StringUtils.nullString( request.getParameter( "message" ) ).trim();
String pageName        = StringUtils.nullString( request.getParameter( "pageName" ) );
String pageHandle      = StringUtils.nullString( request.getParameter( "pageHandle" ) );
String pageContent     = StringUtils.nullString( request.getParameter( "pageContent" ) );

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

if( textPageId != -1 )
{
  ps = conn.prepareStatement( SELECT_PAGE_SQL );
  ps.setInt( 1, textPageId );
  rs = ps.executeQuery();

  if( rs.next() )
  {
    pageName        = StringUtils.nullString( rs.getString( "pageName" ) );
    pageHandle      = StringUtils.nullString( rs.getString( "pageHandle" ) );
    pageContent     = StringUtils.nullString( rs.getString( "pageContent" ) );
  }

  rs.close();
  ps.close();
}
else
{
  mode = "Add";

//  if( request.getParameter( "visibleOnSite" ) == null )						// New Types default to visible
//  {
//    visibleOnSite = true;
//  }
}

%><html>
<head>
  <title>Single Page Admin</title>
  <link rel="stylesheet" href="/style/admin.css" type="text/css">
  <script language="JavaScript" type="text/javascript" src="/js/richtextReadProps.jsp"></script>
  <script language="JavaScript" type="text/javascript" src="/js/richtext.js"></script>
</head>
<body class="adminPane">
<form name="textPage" action="pageDatabase.jsp" onsubmit="return submitForm();" method="post">
<input type="hidden" name="textPageId" value="<%= textPageId %>" />
<input type="hidden" name="mode" value="<%= mode.toLowerCase() %>" />
<table border="0" cellpadding="0" cellpadding="0">
<tr>
  <td colspan="2" class="title"><%= mode %> a Single Page</td>
  <td rowspan="100">
    <iframe src ="files.jsp?textPageId=<%= textPageId %>&pageName=<%= pageName %>" width="230" height="525"></iframe>
  </td>
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

if( user.isUltra() )
{

%><tr>
  <td class="formLabel">Page Name</td>
  <td><input type="text" class="formElement" name="pageName" value="<%= pageName %>" /></td>
</tr>
<tr>
  <td class="formLabel">Page Handle</td>
  <td><input type="text" class="formElement" name="pageHandle" value="<%= pageHandle %>" /></td>
</tr>
<%

}

%>
<!--
<tr>
  <td class="formLabel">Page Content</td>
  <td><textarea name="pageContent" rows="15" cols="60"><%= pageContent %></textarea></td>
</tr>
-->

<tr>
<td colspan="2">
<script language="JavaScript" type="text/javascript">
<!--
function submitForm() {
	//make sure hidden and iframe values are in sync before submitting form
	//to sync only 1 rte, use updateRTE( 'rtename' );
	//to sync all rtes, use updateRTEs();
	updateRTE('pageContent');

	//allow form submission (this method is called on submit)
	return true;
}

//Usage: initRTE( imagesPath, includesPath, cssFile, showViewSourceCheckbox )
initRTE("/art/admin/richTextEditorButtons/", "", "/style/general.css", <%= user.isUltra() %> );

//Usage: writeRichText(fieldname, html, width, height, buttons)
writeRichText('pageContent', '<%= StringUtils.replace( StringUtils.replace( pageContent, "'", "&#39;", true, false ), "\r\n", "\\n", true, false ) %>', 480, 200, true, false);
//-->
</script>
<noscript><p><b>Javascript must be enabled to use this form.</b></p></noscript>
</td>
</tr>

<tr>
  <td colspan="2" class="subHead">Restrict Visibility</td>
</tr>
<tr>
  <td colspan="2" class="note">Uncheck all groups to make list type public.</td>
</tr>
<%

ps = conn.prepareStatement( SELECT_GROUPS_SQL );
ps.setInt( 1, textPageId );
rs = ps.executeQuery();

while( rs.next() )
{
  userGroupId    = rs.getInt( "userGroupId" );
  groupName      = rs.getString( "name" );
  groupHandle    = rs.getString( "handle" );
  visibleToGroup = ( rs.getString( "textPageId" ) != null );

  if( user.isUltra() || ( !groupHandle.equals( dataDictionary.getString( "groups.handle.ultra" ) ) ) )
  {

%>
<tr>
  <td class="formLabel"><%= groupName %></td>
  <td><input type="checkbox" name="groupIds" value="<%= userGroupId %>"<%= ( ( visibleToGroup ) ? " checked=\"checked\"" : "" ) %>/></td>
</tr>
<%

  }
}

rs.close();
ps.close();

%>
<tr>
  <td colspan="2" class="formButtons"><input type="button" onclick="document.location.href='index.jsp'" value="Cancel" class="formButton" /> <input type="submit" value="<%= mode %>" class="formButton" /></td>
</tr>
</table>
</form>
</body>
</html><%

conn.close();

%>