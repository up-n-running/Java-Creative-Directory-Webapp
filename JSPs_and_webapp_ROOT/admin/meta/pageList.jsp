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

int typeId = NumberUtils.parseInt( request.getParameter( "typeId" ), -1 );

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

String getmaxFormOrderSql  = "SELECT MAX(formOrder) maxFormOrder FROM objMetaPages WHERE objTypeId=?";
String getObjTypeInfoSql   = "SELECT typeName FROM objTypes WHERE objTypeId=?";
String listObjMetaPagesSql = "SELECT objMetaPageId, metaPageName, formOrder FROM objMetaPages WHERE objTypeId=? ORDER BY formOrder";

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

int maxFormOrder = 0;

String typeName = StringUtils.nullString( request.getParameter( "typeName" ) );

ps = conn.prepareStatement( getmaxFormOrderSql );
ps.setInt( 1, typeId );
rs = ps.executeQuery();

if( rs.next() )
{
  maxFormOrder = rs.getInt( "maxFormOrder" );
}

rs.close();
ps.close();

if( typeName.equals( "" ) )
{
  ps = conn.prepareStatement( getObjTypeInfoSql );
  ps.setInt( 1, typeId );
  rs = ps.executeQuery();

  if( rs.next() )
  {
    typeName  = StringUtils.nullString( rs.getString( "typeName" ) );
  }

  rs.close();
  ps.close();
}

%><html>
<head>
  <title>extSell: Administration: Site Object Meta Data Types: List</title>
  <link rel="stylesheet" type="text/css" href="/style/admin.css">
</head>
<body>
<table border="0" cellpadding="0" cellspacing="0">
<tr>
  <td colspan="4" class="title">Site Object Meta Data Types for <%= typeName %></td>
</tr>
<%

ps = conn.prepareStatement( listObjMetaPagesSql );
ps.setInt( 1, typeId );
rs = ps.executeQuery();

int rowNum = 0;

while( rs.next() )
{
  if( rowNum == 0 )
  {

%>
<tr>
  <td class="listHead"></td>
  <td class="listHead">Meta Page Name</td>
  <td class="listHead" colspan="2">&nbsp;</td>
</tr>
<%

  }

  int    objMetaPageId = rs.getInt(    "objMetaPageId" );
  String metaPageName  = rs.getString( "metaPageName" );
  int    formOrder     = rs.getInt(    "formOrder" );

%>
<tr>
  <td class="listLine<%= ( rowNum % 2 ) %>"><%

  if( formOrder > 1 )
  {

%><a href="pageDatabase.jsp?typeId=<%= typeId %>&metaPageId=<%= objMetaPageId %>&function=dec&formOrder=<%= formOrder %>"><img src="/art/admin/arrowUp.gif" width="16" height="16" border="0" /></a><%

  }
  else
  {

%><img src="/art/blank.gif" width="16" height="16" /><%

  }

  if( formOrder < maxFormOrder )
  {

%><a href="pageDatabase.jsp?typeId=<%= typeId %>&metaPageId=<%= objMetaPageId %>&function=inc&formOrder=<%= formOrder %>"><img src="/art/admin/arrowDown.gif" width="16" height="16" border="0" /></a><%

  }

%></td>
  <td class="listLine<%= ( rowNum % 2 ) %>"><%= metaPageName %></td>
  <td class="listLine<%= ( rowNum % 2 ) %>"><a href="pageEditForm.jsp?typeId=<%= typeId %>&objMetaPageId=<%= objMetaPageId %>">Edit</a></td>
  <td class="listLine<%= ( rowNum % 2 ) %>"><a href="pageDatabase.jsp?typeId=<%= typeId %>&objMetaPageId=<%= objMetaPageId %>&formOrder=<%= formOrder %>&function=delete" onClick="return confirm( 'Are you sure you want to delete the <%= metaPageName %> meta data page?' )">Del</a></td>
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
  <td colspan="4" class="listHead">No Meta Data Pages Defined</td>
</tr>
<%

}

%>
<tr>
  <td colspan="4" class="formButtons"><a href="index.jsp">Back</a> | <a href="pageEditForm.jsp?typeId=<%= typeId %>&backTo=metaList">Add a meta data page</a></td>
</tr>
</table>
</body>
</html><%

conn.close();

%>