<%@ page language="java"
  import="com.extware.common.DataDictionary,
          com.extware.utils.DatabaseUtils,
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

int typeId = NumberUtils.parseInt( request.getParameter( "typeId" ), -1 );

String getAllMetaGroupsSql  = "SELECT g.objMetaChoiceGroupId, g.groupName, t.typeName FROM objMetaChoiceGroups g LEFT JOIN objTypes t ON g.objTypeId=t.objTypeId ORDER BY groupName";
String getMetaGroupsByIdSql = "SELECT g.objMetaChoiceGroupId, g.groupName, t.typeName FROM objMetaChoiceGroups g LEFT JOIN objTypes t ON g.objTypeId=t.objTypeId WHERE ( g.objTypeId=? OR g.objTypeId IS NULL ) ORDER BY g.groupName";

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

%><html>
<head>
  <title></title>
  <link rel="stylesheet" type="text/css" href="/style/admin.css">
</head>
<body>
<table border="0" cellpadding="0" cellspacing="0">
<tr>
  <td colspan="5" class="title">Meta Data Groups</td>
</tr>
<%

if( typeId == -1 )
{
  ps = conn.prepareStatement( getAllMetaGroupsSql );
}
else
{
  ps = conn.prepareStatement( getMetaGroupsByIdSql );
  ps.setInt( 1, typeId );
}

rs = ps.executeQuery();

int rowNum = 0;

while( rs.next() )
{
  if( rowNum == 0 )
  {

%>
<tr>
  <td class="listHead">Meta Data Group</td>
  <td class="listHead">Site Object Type</td>
  <td class="listHead" colspan="3"></td>
</tr>
<%

  }

  int    groupId   = rs.getInt( "objMetaChoiceGroupId" );
  String groupName = rs.getString( "groupName" );
  String typeName  = StringUtils.nullString( rs.getString( "typeName" ) );

  if( typeName.equals( "" ) )
  {
    typeName = "Global";
  }

%>
<tr>
  <td class="listLine<%= ( rowNum % 2 ) %>"><%= groupName %></td>
  <td class="listLine<%= ( rowNum % 2 ) %>"><%= typeName %></td>
  <td class="listLine<%= ( rowNum % 2 ) %>"><a href="groupEditForm.jsp?typeId=<%= typeId %>&groupId=<%= groupId %>">Edit</a></td>
  <td class="listLine<%= ( rowNum % 2 ) %>"><a href="choiceList.jsp?typeId=<%= typeId %>&groupId=<%= groupId %>">Choices</a></td>
  <td class="listLine<%= ( rowNum % 2 ) %>"><a href="groupDatabase.jsp?typeId=<%= typeId %>&groupId=<%= groupId %>&function=delete" onClick="return confirm( 'Are you sure you want to delete the <%= groupName %> meta data group?' )">Del</a></td>
</tr>
<%

  rowNum++;
}

rs.close();
ps.close();

if( rowNum == 0 )
{

%>
<tr>
  <td colspan="5" class="listHead">No Meta Data Groups Defined</td>
</tr>
<%

}

%>
<tr>
  <td colspan="5" class="formButtons"><a href="groupEditForm.jsp?typeId=<%= typeId %>">Add a meta data group</a></td>
</tr>
</table>
</body>
</html><%

conn.close();

%>
