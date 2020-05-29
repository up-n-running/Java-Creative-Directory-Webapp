<%@ page language="java" import="
  com.extware.user.UserDetails,
  com.extware.utils.BooleanUtils,
  com.extware.utils.DatabaseUtils,
  com.extware.utils.NumberUtils,
  com.extware.utils.StringUtils,
  java.sql.Connection,
  java.sql.PreparedStatement,
  java.sql.ResultSet
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

String SELECT_ITEMS_TO_SEND_SQL = "SELECT i.listItemId, i.title, t.listName, s.storyPresentation FROM newsletterTypeListTypes n LEFT JOIN listTypes t ON n.listTypeId=t.listTypeId LEFT JOIN listItems i ON i.listTypeId=t.listTypeId LEFT JOIN newsletterStories s ON s.listItemId=i.listItemId AND s.newsletterId=? WHERE n.newsletterTypeId=? AND i.title IS NOT NULL AND i.liveDate<=CURRENT_TIMESTAMP AND ( i.removeDate>=CURRENT_TIMESTAMP OR i.removeDate IS NULL ) ORDER BY t.listName, i.title";

int listItemId;
int newsletterId     = NumberUtils.parseInt( request.getParameter( "newsletterId" ),     -1 );
int newsletterTypeId = NumberUtils.parseInt( request.getParameter( "newsletterTypeId" ), -1 );
int reciptsAdded     = NumberUtils.parseInt( request.getParameter( "reciptsAdded" ),     -1 );

String title;
String listName;
String storyPresentation;
String oldListName       = "";
String errors            = StringUtils.nullString( request.getParameter( "errors" ) ).trim();
String message           = StringUtils.nullString( request.getParameter( "message" ) ).trim();

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

%><html>
<head>
  <title>Send a Newsletter</title>
  <link rel="stylesheet" href="/style/admin.css" type="text/css">
</head>
<body class="adminPane">
<form action="saveStories.jsp" method="post">
<input type="hidden" name="newsletterId" value="<%= newsletterId %>" />
<input type="hidden" name="newsletterTypeId" value="<%= newsletterTypeId %>" />
<input type="hidden" name="mode" value="save" />
<table border="0" cellpadding="0" cellspacing="0">
<tr>
  <td colspan="2" class="title">Choose Newsletter Content</td>
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

if( reciptsAdded != -1 )
{

%><tr>
  <td colspan="2" class="message"><%= reciptsAdded %> recipients added</td>
</tr>
<%

}

%><tr>
  <td colspan="2" class="note">Choose the stories to go into the newsletter and their presentation.</td>
</tr>
<%

ps = conn.prepareStatement( SELECT_ITEMS_TO_SEND_SQL );
ps.setInt( 1, newsletterId );
ps.setInt( 2, newsletterTypeId );
rs = ps.executeQuery();

while( rs.next() )
{
  listItemId        = rs.getInt(    "listItemId" );
  title             = rs.getString( "title" );
  listName          = rs.getString( "listName" );
  storyPresentation = StringUtils.nullString( rs.getString( "storyPresentation" ) );

  if( !listName.equals( oldListName ) )
  {

%><tr>
  <td colspan="2" class="subhead"><%= listName %></td>
</tr>
<%

    oldListName = listName;
  }

%><tr>
  <td><%= title %></td>
  <td><select name="item_<%= listItemId %>">
      <option value="">Not in Newsletter</option>
      <option value="F"<%= ( ( storyPresentation.equals( "F" ) ) ? " selected=\"selected\"" : "" ) %>>Full Story</option>
      <option value="S"<%= ( ( storyPresentation.equals( "S" ) ) ? " selected=\"selected\"" : "" ) %>>Small Story</option>
      <option value="H"<%= ( ( storyPresentation.equals( "H" ) ) ? " selected=\"selected\"" : "" ) %>>Headline</option>
    </select></td>
</tr>
<%

}

rs.close();
ps.close();

%>
<tr>
  <td colspan="2" class="formButtons"><input type="submit" class="formButton" value="Add Content" /></td>
</tr>
</table>
</form>
</body>
</html><%

conn.close();

%>