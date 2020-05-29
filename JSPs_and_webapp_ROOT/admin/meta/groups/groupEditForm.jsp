<%@ page language="java"
  import="com.extware.common.DataDictionary,
          com.extware.utils.DatabaseUtils,
          com.extware.utils.NumberUtils,
          com.extware.utils.StringUtils,
          com.extware.user.UserDetails,
          java.sql.Connection,
          java.sql.PreparedStatement,
          java.sql.ResultSet,
          java.util.Hashtable"
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

String getGroupInfoSql    = "SELECT groupName, objTypeId FROM objMetaChoiceGroups WHERE objMetaChoiceGroupId=?";
String getObjTypeListSql = "SELECT objTypeId, typeName FROM objTypes ORDER BY typeName";
String getObjTypeSql     = "SELECT objTypeId, typeName FROM objTypes WHERE objTypeId=?";

int typeId    = NumberUtils.parseInt( request.getParameter( "typeId" ), -1 );
int groupId   = NumberUtils.parseInt( request.getParameter( "groupId" ),    -1 );
int objTypeId = NumberUtils.parseInt( request.getParameter( "objTypeId" ), -1 );

String function    = "Add";
String groupName   = StringUtils.nullString( request.getParameter( "groupName" ) );
String errorDesc   = StringUtils.nullString( request.getParameter( "errorDesc" ) );

Hashtable errors = new Hashtable();
errors.put( "alreadyexists", "That group name already exists." );

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

if( groupId != -1 )
{
  function = "Edit";
  ps = conn.prepareStatement( getGroupInfoSql );
  ps.setInt( 1, groupId );
  rs = ps.executeQuery();

  if( rs.next() )
  {
    groupName  = StringUtils.nullString( rs.getString( "groupName" ) );
    objTypeId = NumberUtils.parseInt(   rs.getString( "objTypeId" ), -1 );
  }

  rs.close();
  ps.close();
}

%><html>
<head>
  <title></title>
  <link rel="stylesheet" type="text/css" href="/style/admin.css">
</head>
<body>
<form action="groupDatabase.jsp" method="post">
<input type="hidden" name="function" value="<%= function.toLowerCase() %>" />
<input type="hidden" name="typeId" value="<%= typeId %>" />
<input type="hidden" name="groupId" value="<%= groupId %>" />
<table border="0" cellpadding="0" cellspacing="0">
<tr>
  <td colspan="2" class="title"><%= function %> Meta Data Group</td>
</tr>
<%

if( !errorDesc.equals( "" ) )
{

%>
<tr>
  <td colspan="2" class="warning"><%= errors.get( errorDesc ) %></td>
</tr>
<%

}

%>
<tr>
  <td class="formLabel">Group Name</td>
  <td><input type="text" name="groupName" value="<%= groupName %>" /></td>
</tr>
<tr>
  <td class="formLabel">Site Object Type</td>
  <td><select name="objTypeId">
      <option value="">Global</option>
<%

if( typeId == -1 )
{
  ps = conn.prepareStatement( getObjTypeListSql );
}
else
{
  ps = conn.prepareStatement( getObjTypeSql );
  ps.setInt( 1, typeId );
}

rs = ps.executeQuery();

while( rs.next() )
{
  int objId      = rs.getInt(    "objTypeId" );
  String typeName = rs.getString( "typeName" );

%>      <option value="<%= objId %>"<%= ( ( objId == objTypeId ) ? " selected=\"selected\"" : "" ) %>><%= typeName %></option>
<%

}

%>    </select></td>
</tr>
<tr>
  <td colspan="2" class="formButtons"><input type="button" value="Cancel" onClick="document.location.href='index.jsp?typeId=<%= typeId %>'" /> <input type="submit" value="<%= function %>" /></td>
</tr>
</table>
</form>
</body>
</html><%

conn.close();

%>