<%@ page language="java"
  import="com.extware.common.DataDictionary,
          com.extware.utils.DatabaseUtils,
          com.extware.utils.NumberUtils,
          com.extware.utils.PropertyFile,
          com.extware.utils.StringUtils,
          com.extware.user.UserDetails,
          java.sql.Connection,
          java.sql.PreparedStatement,
          java.sql.ResultSet,
          java.util.Hashtable"
%><%

int groupId     = NumberUtils.parseInt( request.getParameter( "groupId" ),        -1 );
int myUserLevel = NumberUtils.parseInt( session.getAttribute( "adminUserLevel" ), -1 );

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

String getChoiceInfoSql = "SELECT choiceValue, choiceImage, minUserLevel FROM objMetaChoices WHERE objMetaChoiceId=?";
String getGroupNameSql  = "SELECT groupName FROM objMetaChoiceGroups WHERE objMetaChoiceGroupId=?";
String listAliasesSql   = "SELECT objMetaChoiceAliasId, aliasValue FROM objMetaChoiceAliases WHERE choiceId=?";

PropertyFile dataDictionary = PropertyFile.getDataDictionary();

int typeId       = NumberUtils.parseInt( request.getParameter( "typeId" ),       -1 );
int choiceId     = NumberUtils.parseInt( request.getParameter( "choiceId" ),     -1 );
int minUserLevel = NumberUtils.parseInt( request.getParameter( "minUserLevel" ),  0 );

String groupName   = "";
String choiceValue = "";
String choiceImage = "";
String function    = "Add";
String errorDesc   = StringUtils.nullString( request.getParameter( "errorDesc" ) );

Hashtable errors = new Hashtable();
errors.put( "alreadyexists", "That choice value already exists." );

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

ps = conn.prepareStatement( getGroupNameSql );
ps.setInt( 1, groupId );
rs = ps.executeQuery();

if( rs.next() )
{
  groupName = rs.getString( "groupName" );
}

rs.close();
ps.close();

if( choiceId != -1 )
{
  function = "Edit";
  ps = conn.prepareStatement( getChoiceInfoSql );
  ps.setInt( 1, choiceId );
  rs = ps.executeQuery();

  if( rs.next() )
  {
    choiceValue  = StringUtils.nullString( rs.getString( "choiceValue" ) );
    choiceImage  = StringUtils.nullString( rs.getString( "choiceImage" ) );
    minUserLevel = NumberUtils.parseInt(   rs.getString( "minUserLevel" ),  0 );
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
<form action="choiceDatabase.jsp" method="post" enctype="multipart/form-data">
<input type="hidden" name="function" value="<%= function.toLowerCase() %>" />
<input type="hidden" name="choiceId" value="<%= choiceId %>" />
<input type="hidden" name="groupId" value="<%= groupId %>" />
<table border="0" cellpadding="0" cellspacing="0">
<tr>
  <td colspan="3" class="title"><%= function %> Meta Data Choice to <%= groupName %></td>
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
  <td class="formLabel">Choice Value</td>
  <td><input type="text" name="choiceValue" value="<%= choiceValue %>" /></td>
</tr>
<tr>
  <td class="formLabel">Choice Image</td>
  <td><input type="file" name="choiceImage" /></td>
  <td><%= ( ( choiceImage.equals( "" ) ) ? "" : "<img src=\"/" + dataDictionary.getString( "meta.choice.dir.img" ) + "/" + choiceImage + "\" />" ) %></td>
</tr>
<tr>
  <td colspan="3" class="formButtons"><input type="button" value="Cancel" onClick="document.location.href='choiceList.jsp?groupId=<%= groupId %>'" /> <input type="submit" value="<%= function %>" /></td>
</tr>
</table>
</form>
<%

if( function.equals( "Add" ) )
{

%>
<br /><br />
<form action="choiceDatabase.jsp" method="post" enctype="multipart/form-data">
<input type="hidden" name="function" value="quickadd" />
<input type="hidden" name="groupId" value="<%= groupId %>" />
<table border="0" cellpadding="0" cellspacing="0">
<tr>
  <td colspan="3" class="title">Quick Add Meta Data Choices to <%= groupName %></td>
</tr>
<tr>
  <td class="formLabel">Choice Values</td>
  <td><textarea name="choiceValues" cols="40" rows="10"></textarea></td>
</tr>
<tr>
  <td colspan="3" class="formButtons"><input type="button" value="Cancel" onClick="document.location.href='choiceList.jsp?groupId=<%= groupId %>'" /> <input type="submit" value="Add" /></td>
</tr>
</table>
</form>
<%

}
else if( function.equals( "Edit" ) )
{

%>
<br /><br />
<form action="choiceDatabase.jsp" method="post" enctype="multipart/form-data">
<input type="hidden" name="function" value="aliasadd" />
<input type="hidden" name="typeId" value="<%= typeId %>" />
<input type="hidden" name="choiceId" value="<%= choiceId %>" />
<input type="hidden" name="groupId" value="<%= groupId %>" />
<table border="0" cellpadding="0" cellspacing="0">
<tr>
  <td colspan="2" class="title">Aliases for <%= choiceValue %></td>
</tr>
<tr>
  <td colspan="2" class="note">These aliases will be used to match meta data values during an import.</td>
</tr>
<%

int rowNum = 0;

ps = conn.prepareStatement( listAliasesSql );
ps.setInt( 1, choiceId );
rs = ps.executeQuery();

while( rs.next() )
{
  int objMetaChoiceAliasId = rs.getInt( "objMetaChoiceAliasId" );

  String aliasValue = rs.getString( "aliasValue" );

  if( rowNum == 0 )
  {

%>
<tr>
  <td class="listHead">Alias</td>
  <td class="listHead">&nbsp;</td>
</tr>
<%

  }

%>
<tr>
  <td class="listLine<%= ( rowNum % 2 ) %>"><%= aliasValue %></td>
  <td class="listLine<%= ( rowNum % 2 ) %>"><a href="choiceDatabase.jsp?function=aliasdel&choiceId=<%= choiceId %>&groupId=<%= groupId %>&objMetaChoiceAliasId=<%= objMetaChoiceAliasId %>" onclick="return confirm( 'Are you sure you wish to delete this alias?' )">Delete</a></td>
</tr>
<%

  rowNum++;
}

rs.close();
ps.close();

%>
<tr>
  <td class="formLabel">New Alias</td>
  <td><input type="text" name="aliasValue" /></td>
</tr>
<tr>
  <td colspan="2" class="formButtons"><input type="button" value="Cancel" onClick="document.location.href='choiceList.jsp?groupId=<%= groupId %>'" /> <input type="submit" value="Add" /></td>
</tr>
</table>
</form>
<%

}

%>
</body>
</html><%

conn.close();

%>