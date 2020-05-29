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

String getmaxFormOrderSql  = "SELECT objMetaPageId, MAX(formOrder) maxFormOrder FROM objMetaTypes WHERE objTypeId=? GROUP BY objMetaPageId";
String getObjTypeInfoSql   = "SELECT t.typeName, COUNT(p.objTypeId) pageCount FROM objTypes t LEFT JOIN objMetaPages p ON p.objTypeId=t.objTypeId AND t.objTypeId=? GROUP BY t.typeName";
String listObjMetaTypesSql = "SELECT t.objMetaTypeId, t.typeName, g.groupName, t.groupType, p.objMetaPageId, p.metaPageName, p.formOrder pageOrder, t.formOrder typeOrder FROM objMetaTypes t LEFT JOIN objMetaChoiceGroups g ON t.metaGroupId=g.objMetaChoiceGroupId LEFT JOIN objMetaPages p ON t.objMetaPageId=p.objMetaPageId WHERE t.objTypeId=? ORDER BY p.formOrder, t.formOrder, t.typeName";
String getPageListSql      = "SELECT objMetaPageId, metaPageName FROM objMetaPages WHERE objTypeId=? ORDER BY formOrder";

int maxFormOrder = 0;
int pageCount    = 0;

String typeName = StringUtils.nullString( request.getParameter( "typeName" ) );

Hashtable maxFormOrders = new Hashtable();

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

ps = conn.prepareStatement( getmaxFormOrderSql );
ps.setInt( 1, typeId );
rs = ps.executeQuery();

while( rs.next() )
{
  int objMetaPageId = NumberUtils.parseInt( rs.getString( "objMetaPageId" ), -1 );
  maxFormOrders.put( String.valueOf( objMetaPageId ), rs.getString( "maxFormOrder" ) );
}

rs.close();
ps.close();

ps = conn.prepareStatement( getObjTypeInfoSql );
ps.setInt( 1, typeId );
rs = ps.executeQuery();

if( rs.next() )
{
  typeName  = StringUtils.nullString( rs.getString( "typeName" ) );
  pageCount = rs.getInt( "pageCount" );
}

rs.close();
ps.close();

%><html>
<head>
  <title>extSell: Administration: Site Object Meta Data Types: List</title>
  <link rel="stylesheet" type="text/css" href="/style/admin.css">
<script type="text/javascript" src="/js/layer.js"></script>
<script type="text/javascript">
var metaTypeId    = -1;
var oldMetaPageId = -1;
var oldFormOrder  = -1;
function showPages( typeId, pageId, formOrder, ev )
{
  metaTypeId    = typeId;
  oldMetaPageId = pageId;
  oldFormOrder  = formOrder;

  if( typeof( ev.clientX ) != "undefined" )
  {
    movelayer( "pageList", ev.clientX, ev.clientY );
  }
  else
  {
    movelayer( "pageList", ev.pageX, ev.pageY );
  }

  showlayer( "pageList" );
}
function setPage( pageId )
{
  if( pageId != 0 )
  {
    window.location.href="metaDatabase.jsp?typeId=<%= typeId %>&function=setPage&metaTypeId=" + metaTypeId + "&oldMetaPageId=" + oldMetaPageId + "&formOrder=" + oldFormOrder + "&objMetaPageId=" + pageId;
  }

  hidelayer( "pageList" );
  return false;
}
</script>
</head>
<body>
<table border="0" cellpadding="0" cellspacing="0">
<tr>
  <td colspan="5" class="title">Site Object Meta Data Types for <%= typeName %></td>
</tr>
<%

ps = conn.prepareStatement( listObjMetaTypesSql );
ps.setInt( 1, typeId );
rs = ps.executeQuery();

int rowNum = 0;
String oldMetaPageName = "";

while( rs.next() )
{
  if( rowNum == 0 )
  {

%>
<tr>
  <td class="listHead"></td>
  <td class="listHead">Meta Data Name</td>
  <td class="listHead">Meta Data Type</td>
  <td class="listHead" colspan="2">&nbsp;</td>
</tr>
<%

  }

  int    metaTypeId    = rs.getInt( "objMetaTypeId" );
  String metaTypeName  = rs.getString( "typeName" );
  String groupName     = StringUtils.nullString( rs.getString( "groupName" ) );
  String groupType     = StringUtils.nullString( rs.getString( "groupType" ) );
  int    objMetaPageId = NumberUtils.parseInt( rs.getString( "objMetaPageId" ), -1 );
  String metaPageName  = StringUtils.nullReplace( rs.getString( "metaPageName" ), "Default Page" );
  int    pageOrder     = rs.getInt( "pageOrder" );
  int    formOrder     = rs.getInt( "typeOrder" );

  maxFormOrder = NumberUtils.parseInt( maxFormOrders.get( String.valueOf( objMetaPageId ) ), 0 );

  String typeType = "Text";

  if( !groupName.equals( "" ) )
  {
    typeType = groupName + " (" + groupType + ")";
  }

  if( groupType.equals( "L" ) )
  {
    typeType = "Large Text";
  }

  if( !metaPageName.equals( oldMetaPageName ) && pageCount > 0 )
  {

%>
<tr>
  <td class="listSubHead" colspan="5"><%= metaPageName %></td>
</tr>
<%

    oldMetaPageName = metaPageName;
  }

%>
<tr>
  <td class="listLine<%= ( rowNum % 2 ) %>"><%

  if( formOrder > 1 )
  {

%><a href="metaDatabase.jsp?typeId=<%= typeId %>&metaTypeId=<%= metaTypeId%>&function=dec&formOrder=<%= formOrder %>&objMetaPageId=<%= objMetaPageId %>"><img src="/art/admin/arrowUp.gif" width="16" height="16" border="0" /></a><%

  }
  else
  {

%><img src="/art/blank.gif" width="16" height="16" /><%

  }

  if( formOrder < maxFormOrder )
  {

%><a href="metaDatabase.jsp?typeId=<%= typeId %>&metaTypeId=<%= metaTypeId %>&function=inc&formOrder=<%= formOrder %>&objMetaPageId=<%= objMetaPageId %>"><img src="/art/admin/arrowDown.gif" width="16" height="16" border="0" /></a><%

  }
  else
  {

%><img src="/art/blank.gif" width="16" height="16" /><%

  }

  if( pageCount > 0 )
  {

%><a href="#" onclick="showPages(<%= metaTypeId %>, <%= objMetaPageId %>, <%= formOrder %>, event )" title="Set Page for <%= metaTypeName %>"><img src="/art/setPage.gif" width="16" height="16" border="0" /></a><%

  }

%></td>
  <td class="listLine<%= ( rowNum % 2 ) %>"><%= metaTypeName %></td>
  <td class="listLine<%= ( rowNum % 2 ) %>"><%= typeType %></td>
  <td class="listLine<%= ( rowNum % 2 ) %>"><a href="metaEditForm.jsp?typeId=<%= typeId %>&metaTypeId=<%= metaTypeId %>">Edit</a></td>
  <td class="listLine<%= ( rowNum % 2 ) %>"><a href="metaDatabase.jsp?typeId=<%= typeId %>&metaTypeId=<%= metaTypeId %>&function=delete&formOrder=<%= formOrder %>" onClick="return confirm( 'Are you sure you want to delete the <%= metaTypeName %> meta data type?' )">Del</a></td>
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
  <td colspan="5" class="listHead">No Meta Data Types Defined</td>
</tr>
<%

}

%>
<tr>
  <td colspan="5" class="formButtons"><a href="index.jsp">Back</a> | <a href="pageEditForm.jsp?typeId=<%= typeId %>&backTo=metaList">Add a meta data page</a> | <a href="metaEditForm.jsp?typeId=<%= typeId %>">Add a meta data type</a></td>
</tr>
</table>
<%

if( pageCount > 0 )
{

%><div id="pageList" class="pageSelector">
<%

  ps = conn.prepareStatement( getPageListSql );
  ps.setInt( 1, typeId );
  rs = ps.executeQuery();

  while( rs.next() )
  {
    int    objMetaPageId = rs.getInt(    "objMetaPageId" );
    String metaPageName  = rs.getString( "metaPageName" );

%><a class="pageSelectLink" href="#" onclick="return setPage(<%= objMetaPageId %>)"><%= metaPageName %></a>
<%

  }

  rs.close();
  ps.close();

%><a class="pageSelectLink" href="#" onclick="return setPage(-1)">Default Page</a>
<a class="pageSelectLink" href="#" onclick="return setPage(0)">Cancel</a>
</div>
<%

}

%>
</body>
</html><%

conn.close();

%>