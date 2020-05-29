<%@ page language="java"
  import="com.extware.utils.DatabaseUtils,
          com.extware.utils.NumberUtils,
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

if( !user.isAdmin() )
{
  response.sendRedirect( "/admin/blank.html" );
  return;
}

String SELECT_TYPE_INFO_SQL = "SELECT listName, orderColumn, titleLabel FROM listTypes WHERE listTypeId=?";
String SELECT_ITEMS_SQL     = "SELECT listItemId, title, formOrder FROM listItems WHERE listTypeId=? ORDER BY ";
String SELECT_MAX_ORDER_SQL = "SELECT MAX(formOrder) maxFormOrder FROM listItems WHERE listTypeId=?";

int count;
int formOrder;
int listItemId;
int maxFormOrder = 0;
int listTypeId   = NumberUtils.parseInt( request.getParameter( "listTypeId" ), -1 );

String title;
String listName    = "";
String orderColumn = "";
String titleLabel  = "";
String errors      = StringUtils.nullString( request.getParameter( "errors" ) ).trim();
String message     = StringUtils.nullString( request.getParameter( "message" ) ).trim();

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

ps = conn.prepareStatement( SELECT_TYPE_INFO_SQL );
ps.setInt( 1, listTypeId );
rs = ps.executeQuery();

if( rs.next() )
{
  listName    = rs.getString( "listName" );
  orderColumn = StringUtils.nullString( rs.getString( "orderColumn" ) ).trim();
  titleLabel  = StringUtils.nullString( rs.getString( "titleLabel" ) ).trim();
}

rs.close();
ps.close();

if( orderColumn.equals( "" ) )
{
  orderColumn = "title";
}

if( titleLabel.equals( "" ) )
{
  titleLabel = "Title";
}

ps = conn.prepareStatement( SELECT_MAX_ORDER_SQL );
ps.setInt( 1, listTypeId );
rs = ps.executeQuery();

if( rs.next() )
{
  maxFormOrder = rs.getInt( "maxFormOrder" );
}

rs.close();
ps.close();

%><html>
<head>
  <title>List Admin</title>
  <link rel="stylesheet" href="/style/admin.css" type="text/css">
</head>
<body class="adminPane">
<table border="0" cellpadding="0" cellspacing="0">
<tr>
  <td colspan="5" class="title"><%= listName %></td>
</tr>
<%

if( !errors.equals( "" ) )
{

%><tr>
  <td colspan="5" class="error"><%= errors %></td>
</tr>
<%

}

if( !message.equals( "" ) )
{

%><tr>
  <td colspan="5" class="message"><%= message %></td>
</tr>
<%

}

count = 0;

ps = conn.prepareStatement( SELECT_ITEMS_SQL + orderColumn );
ps.setInt( 1, listTypeId );
rs = ps.executeQuery();

while( rs.next() )
{
  if( count == 0 )
  {

%><tr>
<%

    if( orderColumn.equals( "formOrder" ) )
    {

%><td class="listHead">&nbsp;</td>
<%
    }

%>
  <td class="listHead"><%= titleLabel %></td>
  <td colspan="4" class="listHead"></td>
</tr>
<%

  }

  listItemId = rs.getInt(    "listItemId" );
  title      = rs.getString( "title" );
  formOrder  = rs.getInt(    "formOrder" );

%><tr>
<%

    if( orderColumn.equals( "formOrder" ) )
    {

%><td class="listLine<%= ( count % 2 ) %>"><%

  if( formOrder > 2 )
  {

%><a href="itemDatabase.jsp?listTypeId=<%= listTypeId %>&listItemId=<%= listItemId%>&mode=top&formOrder=<%= formOrder %>"><img src="/art/admin/arrowTop.gif" width="16" height="16" border="0" title="Move Item to Top" /></a><%

  }
  else
  {

%><img src="/art/blank.gif" width="16" height="16" /><%

  }

  if( formOrder > 1 )
  {

%><a href="itemDatabase.jsp?listTypeId=<%= listTypeId %>&listItemId=<%= listItemId%>&mode=dec&formOrder=<%= formOrder %>"><img src="/art/admin/arrowUp.gif" width="16" height="16" border="0" title="Move Item Up" /></a><%

  }
  else
  {

%><img src="/art/blank.gif" width="16" height="16" /><%

  }

  if( formOrder < maxFormOrder )
  {

%><a href="itemDatabase.jsp?listTypeId=<%= listTypeId %>&listItemId=<%= listItemId %>&mode=inc&formOrder=<%= formOrder %>"><img src="/art/admin/arrowDown.gif" width="16" height="16" border="0" title="Move Item Down" /></a><%

  }

  if( formOrder < maxFormOrder - 1 )
  {

%><a href="itemDatabase.jsp?listTypeId=<%= listTypeId %>&listItemId=<%= listItemId %>&mode=bot&formOrder=<%= formOrder %>"><img src="/art/admin/arrowBottom.gif" width="16" height="16" border="0" title="Move Item to Bottom" /></a><%

  }

%></td>
<%
    }

%>
  <td class="listLine<%= ( count % 2 ) %>"><%= title %></td>
  <td class="listLine<%= ( count % 2 ) %>"><a href="editItem.jsp?listItemId=<%= listItemId %>&listTypeId=<%= listTypeId %>">Edit</a></td>
  <td class="listLine<%= ( count % 2 ) %>"><a href="files.jsp?listItemId=<%= listItemId %>&listTypeId=<%= listTypeId %>">Files</a></td>
  <td class="listLine<%= ( count % 2 ) %>"><a href="itemDatabase.jsp?mode=delete&listItemId=<%= listItemId %>&listTypeId=<%= listTypeId %>&title=<%= URLEncoder.encode( title ) %>&formOrder=<%= formOrder %>" onclick="return confirm( 'Are you sure you wish to delete this Item' )">Delete</a></td>
</tr>
<%

  count++;
}

rs.close();
ps.close();

if( count == 0 )
{

%><tr>
  <td colspan="5" class="listSubHead">No Items Found</td>
</tr>
<%

}

%>
<tr>
  <td colspan="5" class="formButtons"><a href="editItem.jsp?listTypeId=<%= listTypeId %>">Add an Item</a></td>
</tr>
</table>
</body>
</html><%

conn.close();

%>