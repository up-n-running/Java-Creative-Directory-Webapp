<%@ page language="java"
  import="com.extware.common.DataDictionary,
          com.extware.utils.DatabaseUtils,
          com.extware.utils.NumberUtils,
          com.extware.utils.PropertyFile,
          com.extware.utils.StringUtils,
          com.extware.user.UserDetails,
          java.sql.Connection,
          java.sql.PreparedStatement,
          java.sql.ResultSet"
%><%

int groupId = NumberUtils.parseInt( request.getParameter( "groupId" ), -1 );

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

String getmaxFormOrderSql = "SELECT MAX(formOrder) maxFormOrder FROM objMetaChoices WHERE groupId=?";
String getGroupNameSql    = "SELECT groupName FROM objMetaChoiceGroups WHERE objMetaChoiceGroupId=?";
String getChoiceInfoSql   = "SELECT objMetaChoiceId, choiceValue, choiceImage, formOrder FROM objMetaChoices WHERE groupId=? ORDER BY formOrder";

PropertyFile dataDictionary = PropertyFile.getDataDictionary();

int maxFormOrder = 0;
int typeId       = NumberUtils.parseInt( request.getParameter( "typeId" ), -1 );

String groupName = "";

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

ps = conn.prepareStatement( getmaxFormOrderSql );
ps.setInt( 1, groupId );
rs = ps.executeQuery();

if( rs.next() )
{
  maxFormOrder = rs.getInt( "maxFormOrder" );
}

rs.close();
ps.close();

ps = conn.prepareStatement( getGroupNameSql );
ps.setInt( 1, groupId );
rs = ps.executeQuery();

if( rs.next() )
{
  groupName = rs.getString( "groupName" );
}

rs.close();
ps.close();

%><html>
<head>
  <title></title>
  <link rel="stylesheet" type="text/css" href="/style/admin.css">
</head>
<body>
<table border="0" cellpadding="0" cellspacing="0">
<tr>
  <td colspan="5" class="title">Meta Data Choices for <%= groupName %> Group</td>
</tr>
<%

ps = conn.prepareStatement( getChoiceInfoSql );
ps.setInt( 1, groupId );

rs = ps.executeQuery();

int rowNum = 0;

while( rs.next() )
{
  if( rowNum == 0 )
  {

%>
<tr>
  <td class="listHead"></td>
  <td class="listHead">Choice Value</td>
  <td class="listHead" colspan="3"></td>
</tr>
<%

  }

  int    choiceId    = rs.getInt( "objMetaChoiceId" );
  String choiceValue = rs.getString( "choiceValue" );
  String choiceImage = StringUtils.nullString( rs.getString( "choiceImage" ) );
  int    formOrder     = rs.getInt( "formOrder" );

%>
<tr>
  <td class="listLine<%= ( rowNum % 2 ) %>"><%

  if( formOrder > 2 )
  {

%><a href="choiceDatabase.jsp?typeId=<%= typeId %>&groupId=<%= groupId %>&choiceId=<%= choiceId%>&function=top&formOrder=<%= formOrder %>"><img src="/art/admin/arrowTop.gif" width="16" height="16" border="0" title="Move Choice to Top" /></a><%

  }
  else
  {

%><img src="/art/blank.gif" width="16" height="16" /><%

  }

  if( formOrder > 1 )
  {

%><a href="choiceDatabase.jsp?typeId=<%= typeId %>&groupId=<%= groupId %>&choiceId=<%= choiceId%>&function=dec&formOrder=<%= formOrder %>"><img src="/art/admin/arrowUp.gif" width="16" height="16" border="0" title="Move Choice Up" /></a><%

  }
  else
  {

%><img src="/art/blank.gif" width="16" height="16" /><%

  }

  if( formOrder < maxFormOrder )
  {

%><a href="choiceDatabase.jsp?typeId=<%= typeId %>&groupId=<%= groupId %>&choiceId=<%= choiceId %>&function=inc&formOrder=<%= formOrder %>"><img src="/art/admin/arrowDown.gif" width="16" height="16" border="0" title="Move Choice Down" /></a><%

  }

  if( formOrder < maxFormOrder - 1 )
  {

%><a href="choiceDatabase.jsp?typeId=<%= typeId %>&groupId=<%= groupId %>&choiceId=<%= choiceId %>&function=bot&formOrder=<%= formOrder %>"><img src="/art/admin/arrowBottom.gif" width="16" height="16" border="0" title="Move Choice to Bottom" /></a><%

  }

%></td>
  <td class="listLine<%= ( rowNum % 2 ) %>"><%= choiceValue %></td>
  <td class="listLine<%= ( rowNum % 2 ) %>"><% if( !choiceImage.equals( "" ) ) { %><img src="/<%= dataDictionary.getString( "meta.choice.dir.img" ) %>/<%= choiceImage %>" /><br /><a href="choiceDatabase.jsp?typeId=<%= typeId %>&groupId=<%= groupId %>&choiceId=<%= choiceId %>&function=delimg" onClick="return confirm( 'Are you sure you want to delete the <%= choiceValue %> image?' )">Del Img</a> <% } %></td>
  <td class="listLine<%= ( rowNum % 2 ) %>"><a href="choiceEditForm.jsp?typeId=<%= typeId %>&groupId=<%= groupId %>&choiceId=<%= choiceId %>">Edit</a></td>
  <td class="listLine<%= ( rowNum % 2 ) %>"><a href="choiceDatabase.jsp?typeId=<%= typeId %>&groupId=<%= groupId %>&choiceId=<%= choiceId %>&function=delete" onClick="return confirm( 'Are you sure you want to delete the <%= choiceValue %> meta data choice?' )">Del</a></td>
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
  <td colspan="5" class="listHead">No Meta Data Choices Defined</td>
</tr>
<%

}
else
{

%>
<tr>
  <td><a href="choiceDatabase.jsp?groupId=<%= groupId %>&function=sort">Sort</a></td>
</tr>
<%

}

%>
<tr>
  <td colspan="5" class="formButtons"><a href="index.jsp?typeId=<%= typeId %>">Back</a> | <a href="choiceEditForm.jsp?typeId=<%= typeId %>&groupId=<%= groupId %>">Add meta data choices</a></td>
</tr>
</table>
</body>
</html><%

conn.close();

%>
