<%@ page language="java" import="
  com.extware.user.UserDetails,
  com.extware.utils.BooleanUtils,
  com.extware.utils.DatabaseUtils,
  com.extware.utils.NumberUtils,
  com.extware.utils.StringUtils,
  java.sql.Connection,
  java.sql.PreparedStatement,
  java.sql.ResultSet,
  java.util.Hashtable
" %><%

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

String SELECT_STORIES_SQL   = "SELECT s.newsletterStoryId, i.title, s.storyPresentation, s.itemOrder FROM newsletterStories s INNER JOIN listItems i ON i.listItemId=s.listItemId WHERE s.newsletterId=? ORDER BY s.itemOrder";
String SELECT_MAX_ORDER_SQL = "SELECT MAX(itemOrder) maxItemOrder FROM newsletterStories WHERE newsletterId=?";

int itemOrder;
int newsletterStoryId;
int count             = 0;
int maxItemOrder      = 0;
int newsletterId      = NumberUtils.parseInt( request.getParameter( "newsletterId" ),     -1 );
int newsletterTypeId  = NumberUtils.parseInt( request.getParameter( "newsletterTypeId" ), -1 );

String title;
String storyPresentation;
String errors            = StringUtils.nullString( request.getParameter( "errors" ) ).trim();
String message           = StringUtils.nullString( request.getParameter( "message" ) ).trim();

Hashtable presentations = new Hashtable();
presentations.put( "F", "Full Story" );
presentations.put( "S", "Small Story" );
presentations.put( "H", "Headline" );

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

ps = conn.prepareStatement( SELECT_MAX_ORDER_SQL );
ps.setInt( 1, newsletterId );
rs = ps.executeQuery();

if( rs.next() )
{
  maxItemOrder = rs.getInt( "maxItemOrder" );
}

rs.close();
ps.close();

%><html>
<head>
  <title>Send a Newsletter</title>
  <link rel="stylesheet" href="/style/admin.css" type="text/css">
</head>
<body class="adminPane">
<form action="buildNewsletter.jsp" method="post">
<input type="hidden" name="newsletterId" value="<%= newsletterId %>" />
<input type="hidden" name="newsletterTypeId" value="<%= newsletterTypeId %>" />
<table border="0" cellpadding="0" cellspacing="0">
<tr>
  <td colspan="3" class="title">Order Newsletter Content</td>
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
  <td colspan="3" class="note">Choose the order for the stories to go into the newsletter.</td>
</tr>
<%

ps = conn.prepareStatement( SELECT_STORIES_SQL );
ps.setInt( 1, newsletterId );
rs = ps.executeQuery();

while( rs.next() )
{
  if( count == 0 )
  {

%><tr>
  <td class="listHead">&nbsp;</td>
  <td class="listHead">Story</td>
  <td class="listHead">Presentation</td>
</tr>
<%

  }

  newsletterStoryId = rs.getInt(    "newsletterStoryId" );
  title             = rs.getString( "title" );
  storyPresentation = rs.getString( "storyPresentation" );
  itemOrder         = rs.getInt(    "itemOrder" );

%><tr>
  <td class="listLine<%= ( count % 2 ) %>"><%

  if( itemOrder > 2 )
  {

%><a href="saveStories.jsp?newsletterId=<%= newsletterId %>&newsletterTypeId=<%= newsletterTypeId %>&newsletterStoryId=<%= newsletterStoryId %>&mode=top&itemOrder=<%= itemOrder %>"><img src="/art/admin/arrowTop.gif" width="16" height="16" border="0" title="Move Item to Top" /></a><%

  }
  else
  {

%><img src="/art/blank.gif" width="16" height="16" /><%

  }

  if( itemOrder > 1 )
  {

%><a href="saveStories.jsp?newsletterId=<%= newsletterId %>&newsletterTypeId=<%= newsletterTypeId %>&newsletterStoryId=<%= newsletterStoryId %>&mode=dec&itemOrder=<%= itemOrder %>"><img src="/art/admin/arrowUp.gif" width="16" height="16" border="0" title="Move Item Up" /></a><%

  }
  else
  {

%><img src="/art/blank.gif" width="16" height="16" /><%

  }

  if( itemOrder < maxItemOrder )
  {

%><a href="saveStories.jsp?newsletterId=<%= newsletterId %>&newsletterTypeId=<%= newsletterTypeId %>&newsletterStoryId=<%= newsletterStoryId %>&mode=inc&itemOrder=<%= itemOrder %>"><img src="/art/admin/arrowDown.gif" width="16" height="16" border="0" title="Move Item Down" /></a><%

  }

  if( itemOrder < maxItemOrder - 1 )
  {

%><a href="saveStories.jsp?newsletterId=<%= newsletterId %>&newsletterTypeId=<%= newsletterTypeId %>&newsletterStoryId=<%= newsletterStoryId %>&mode=bot&itemOrder=<%= itemOrder %>"><img src="/art/admin/arrowBottom.gif" width="16" height="16" border="0" title="Move Item to Bottom" /></a><%

  }

%></td>
  <td class="listLine<%= ( count % 2 ) %>"><%= title %></td>
  <td class="listLine<%= ( count % 2 ) %>"><%= presentations.get( storyPresentation ) %></td>
</tr>
<%

  count++;
}

rs.close();
ps.close();

%>
<tr>
  <td colspan="3" class="formButtons"><input type="submit" onclick="this.form.target='_blank'" class="formButton" name="mode" value="Text Preview" /> <input type="submit" onclick="this.form.target='_blank'" class="formButton" name="mode" value="HTML Preview" /> <input type="submit" onclick="this.form.target='_self'" class="formButton" name="mode" value="Send Newsletter" /></td>
</tr>
</table>
</form>
</body>
</html><%

conn.close();

%>