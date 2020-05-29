<%@ page language="java"
  import="com.extware.common.DataDictionary,
          com.extware.utils.DatabaseUtils,
          com.extware.utils.NumberUtils,
          com.extware.utils.StringUtils,
          com.extware.user.UserDetails,
          java.sql.Connection,
          java.sql.ResultSet,
          java.sql.Statement"
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

String listObjectTypesSql = "SELECT t.objTypeId, t.typeName, COUNT(p.objTypeId) pageCount FROM objTypes t LEFT JOIN objMetaPages p ON p.objTypeId=t.objTypeId GROUP BY t.objTypeId, t.typeName ORDER BY typeName";

Connection conn = DatabaseUtils.getDatabaseConnection();
Statement st = conn.createStatement();
ResultSet rs ;

%><html>
<head>
  <title>extSell: Administration: Site Objects: List</title>
  <link rel="stylesheet" type="text/css" href="/style/admin.css">
</head>
<body>
<table border="0" cellpadding="0" cellspacing="0">
<tr>
  <td colspan="5" class="title">Site Object Types</td>
</tr>
<%

rs = st.executeQuery( listObjectTypesSql );
int rowNum = 0;

while( rs.next() )
{
  if( rowNum == 0 )
  {

%>
<tr>
  <td colspan="5" class="listHead">Site Object Type</td>
</tr>
<%

  }

  int    typeId    = rs.getInt( "objTypeId" );
  String typeName  = rs.getString( "typeName" );
  int    pageCount = rs.getInt( "pageCount" );

%>
<tr>
  <td class="listLine<%= ( rowNum % 2 ) %>"><%= typeName %></td>
  <td class="listLine<%= ( rowNum % 2 ) %>"><a href="objEditForm.jsp?typeId=<%= typeId %>">Edit</a></td>
  <td class="listLine<%= ( rowNum % 2 ) %>"><% if( pageCount > 0 ) { %><a href="pageList.jsp?typeId=<%= typeId %>&typeName=<%= typeName %>">Pages</a><% } %></td>
  <td class="listLine<%= ( rowNum % 2 ) %>"><a href="metaList.jsp?typeId=<%= typeId %>&typeName=<%= typeName %>">Meta</a></td>
  <td class="listLine<%= ( rowNum % 2 ) %>"><a href="objDatabase.jsp?typeId=<%= typeId %>&function=delete" onClick="return confirm( 'Are you sure you want to delete the <%= typeName %> site object type?' )">Del</a></td>
</tr>
<%

  rowNum++;
}

rs.close();

if( rowNum == 0 )
{

%>
<tr>
  <td colspan="5" class="listHead">No Site Object Types Defined</td>
</tr>
<%

}

%>
<tr>
  <td colspan="5" class="formButtons"><a href="objEditForm.jsp">Add a site object type</a></td>
</tr>
</table>
</body>
</html><%

st.close();
conn.close();

%>