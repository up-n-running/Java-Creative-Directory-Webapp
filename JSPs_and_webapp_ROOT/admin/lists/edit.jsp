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

if( !user.isUltra() )
{
  response.sendRedirect( "/admin/blank.html" );
  return;
}

String SELECT_TYPE_SQL   = "SELECT listName, listHandle, orderColumn, titleLabel, standfirstLabel, bodyLabel, dateLabel, visibleOnSite FROM listTypes WHERE listTypeId=?";
String SELECT_GROUPS_SQL = "SELECT g.userGroupId, g.name, g.handle, x.listTypeId FROM userGroups g LEFT JOIN listTypeGroupXref x ON x.groupId=g.userGroupId AND x.listTypeId=? ORDER BY g.name";

PropertyFile dataDictionary = PropertyFile.getDataDictionary();

String[] columnList = new String[] { "title", "standfirst", "body", "fromDate", "toDate", "liveDate", "removeDate", "formOrder" };

boolean visibleToGroup;
boolean visibleOnSite  = BooleanUtils.parseBoolean( request.getParameter( "visibleOnSite" ) );

int userGroupId;
int listTypeId  = NumberUtils.parseInt( request.getParameter( "listTypeId" ), -1 );

String groupName;
String groupHandle;
String mode            = "Edit";
String errors          = StringUtils.nullString( request.getParameter( "errors" ) ).trim();
String message         = StringUtils.nullString( request.getParameter( "message" ) ).trim();
String listName        = StringUtils.nullString( request.getParameter( "listName" ) );
String listHandle      = StringUtils.nullString( request.getParameter( "listHandle" ) );
String orderColumn     = StringUtils.nullString( request.getParameter( "orderColumn" ) );
String titleLabel      = StringUtils.nullString( request.getParameter( "titleLabel" ) );
String standfirstLabel = StringUtils.nullString( request.getParameter( "standfirstLabel" ) );
String bodyLabel       = StringUtils.nullString( request.getParameter( "bodyLabel" ) );
String dateLabel       = StringUtils.nullString( request.getParameter( "dateLabel" ) );

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

if( listTypeId != -1 )
{
  ps = conn.prepareStatement( SELECT_TYPE_SQL );
  ps.setInt( 1, listTypeId );
  rs = ps.executeQuery();

  if( rs.next() )
  {
    listName        = StringUtils.nullString( rs.getString( "listName" ) );
    listHandle      = StringUtils.nullString( rs.getString( "listHandle" ) );
    orderColumn     = StringUtils.nullString( rs.getString( "orderColumn" ) );
    titleLabel      = StringUtils.nullString( rs.getString( "titleLabel" ) );
    standfirstLabel = StringUtils.nullString( rs.getString( "standfirstLabel" ) );
    bodyLabel       = StringUtils.nullString( rs.getString( "bodyLabel" ) );
    dateLabel       = StringUtils.nullString( rs.getString( "dateLabel" ) );
    visibleOnSite   = BooleanUtils.parseBoolean( rs.getString( "visibleOnSite" ) );
  }

  rs.close();
  ps.close();
}
else
{
  mode = "Add";

  if( request.getParameter( "visibleOnSite" ) == null )						// New Types default to visible
  {
    visibleOnSite = true;
  }
}

%><html>
<head>
  <title>List Admin</title>
  <link rel="stylesheet" href="/style/admin.css" type="text/css">
</head>
<body class="adminPane">
<form action="typeDatabase.jsp" method="post">
<input type="hidden" name="listTypeId" value="<%= listTypeId %>" />
<input type="hidden" name="mode" value="<%= mode.toLowerCase() %>" />
<table border="0" cellpadding="0" cellpadding="0">
<tr>
  <td colspan="2" class="title"><%= mode %> a List Type</td>
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

%><tr>
  <td class="formLabel">List Name</td>
  <td><input type="text" class="formElement" name="listName" value="<%= listName %>" /></td>
</tr>
<tr>
  <td class="formLabel">List Handle</td>
  <td><input type="text" class="formElement" name="listHandle" value="<%= listHandle %>" /></td>
</tr>
<tr>
  <td class="formLabel">Order Column</td>
  <td><select name="orderColumn" class="formElement">
      <option value=""></option>
<%

for( int i = 0 ; i < columnList.length ; i++ )
{

%>      <option value="<%= columnList[i] %>"<%= ( ( orderColumn.equals( columnList[i] ) ) ? " selected=\"selected\"" : "" ) %>><%= columnList[i] %></option>
<%

}

%>    </select></td>
</tr>
<tr>
  <td class="formLabel">Title Label</td>
  <td><input type="text" class="formElement" name="titleLabel" value="<%= titleLabel %>" /></td>
  <td class="note">Leave blank to use 'Title', use '&lt;none&gt;' to remove</td>
</tr>
<tr>
  <td class="formLabel">Standfirst Label</td>
  <td><input type="text" class="formElement" name="standfirstLabel" value="<%= standfirstLabel %>" /></td>
  <td class="note">Leave blank to use 'Standfirst', use '&lt;none&gt;' to remove</td>
</tr>
<tr>
  <td class="formLabel">Body Label</td>
  <td><input type="text" class="formElement" name="bodyLabel" value="<%= bodyLabel %>" /></td>
  <td class="note">Leave blank to use 'Body, use '&lt;none&gt;' to remove'</td>
</tr>
<tr>
  <td class="formLabel">Date Label</td>
  <td><input type="text" class="formElement" name="dateLabel" value="<%= dateLabel %>" /></td>
  <td class="note">Leave blank to use 'Date', use '&lt;none&gt;' to remove</td>
</tr>
<tr>
  <td class="formLabel">Visible on Site</td>
  <td><input type="checkbox" class="formElement" name="visibleOnSite" value="t"<%= ( ( visibleOnSite ) ? " checked=\"checked\"" : "" ) %> /></td>
</tr>
<tr>
  <td colspan="2" class="subHead">Restrict Visibility</td>
</tr>
<tr>
  <td colspan="2" class="note">Uncheck all groups to make list type public.</td>
</tr>
<%

ps = conn.prepareStatement( SELECT_GROUPS_SQL );
ps.setInt( 1, listTypeId );
rs = ps.executeQuery();

while( rs.next() )
{
  userGroupId    = rs.getInt( "userGroupId" );
  groupName      = rs.getString( "name" );
  groupHandle    = rs.getString( "handle" );
  visibleToGroup = ( rs.getString( "listTypeId" ) != null );

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