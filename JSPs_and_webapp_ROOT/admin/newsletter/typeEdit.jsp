<%@ page language="java" import="
  com.extware.utils.BooleanUtils,
  com.extware.utils.DatabaseUtils,
  com.extware.utils.NumberUtils,
  com.extware.utils.StringUtils,
  com.extware.user.UserDetails,
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

if( !user.isUltra() )
{
  response.sendRedirect( "/admin/blank.html" );
  return;
}

String SELECT_TYPE_SQL  = "SELECT newsletterTypeName, newsletterTypeHandle, description, fromAddress, fromAddressPerSend, htmlHeader, textHeader, htmlFooter, textFooter FROM newsletterTypes WHERE newsletterTypeId=?";
String SELECT_LISTS_SQL = "SELECT t.listTypeId, t.listName, n.newsletterTypeId, COUNT(x.groupId) groupCount FROM listTypes t LEFT JOIN listTypeGroupXref x ON x.listTypeId=t.listTypeId LEFT JOIN newsletterTypeListTypes n ON n.listTypeId=t.listTypeId AND n.newsletterTypeId=? GROUP BY t.listTypeId, t.listName, n.newsletterTypeId ORDER BY t.listName";

boolean usingType;
boolean fromAddressPerSend = BooleanUtils.parseBoolean( request.getParameter( "fromAddressPerSend" ) );

int listTypeId;
int groupCount;
int newsletterTypeId = NumberUtils.parseInt( request.getParameter( "newsletterTypeId" ), -1 );

String listName;
String mode                 = "Edit";
String errors               = StringUtils.nullString( request.getParameter( "errors" ) ).trim();
String message              = StringUtils.nullString( request.getParameter( "message" ) ).trim();
String newsletterTypeName   = StringUtils.nullString( request.getParameter( "newsletterTypeName" ) ).trim();
String newsletterTypeHandle = StringUtils.nullString( request.getParameter( "newsletterTypeHandle" ) ).trim();
String description          = StringUtils.nullString( request.getParameter( "description" ) ).trim();
String fromAddress          = StringUtils.nullString( request.getParameter( "fromAddress" ) ).trim();
String htmlHeader           = StringUtils.nullString( request.getParameter( "htmlHeader" ) ).trim();
String textHeader           = StringUtils.nullString( request.getParameter( "textHeader" ) ).trim();
String htmlFooter           = StringUtils.nullString( request.getParameter( "htmlFooter" ) ).trim();
String textFooter           = StringUtils.nullString( request.getParameter( "textFooter" ) ).trim();

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

if( newsletterTypeId != -1 )
{
  ps = conn.prepareStatement( SELECT_TYPE_SQL );
  ps.setInt( 1, newsletterTypeId );
  rs = ps.executeQuery();

  if( rs.next() )
  {
    newsletterTypeName   = StringUtils.nullString( rs.getString( "newsletterTypeName" ) ).trim();
    newsletterTypeHandle = StringUtils.nullString( rs.getString( "newsletterTypeHandle" ) ).trim();
    description          = StringUtils.nullString( rs.getString( "description" ) ).trim();
    fromAddress          = StringUtils.nullString( rs.getString( "fromAddress" ) ).trim();
    fromAddressPerSend   = BooleanUtils.parseBoolean( rs.getString( "fromAddressPerSend" ) );
    htmlHeader           = StringUtils.nullString( rs.getString( "htmlHeader" ) ).trim();
    textHeader           = StringUtils.nullString( rs.getString( "textHeader" ) ).trim();
    htmlFooter           = StringUtils.nullString( rs.getString( "htmlFooter" ) ).trim();
    textFooter           = StringUtils.nullString( rs.getString( "textFooter" ) ).trim();
  }

  rs.close();
  ps.close();
}
else
{
  mode = "Add";
}

%><html>
<head>
  <title>List Admin</title>
  <link rel="stylesheet" href="/style/admin.css" type="text/css">
</head>
<body class="adminPane">
<form action="typeDatabase.jsp" method="post">
<input type="hidden" name="newsletterTypeId" value="<%= newsletterTypeId %>" />
<input type="hidden" name="mode" value="<%= mode.toLowerCase() %>" />
<table border="0" cellpadding="0" cellpadding="0">
<tr>
  <td colspan="2" class="title"><%= mode %> a Newsletter Type</td>
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

%>
<tr>
  <td class="formLabel">Newsletter Name</td>
  <td><input type="text" class="formElement" name="newsletterTypeName" size="40" maxsize="64" value="<%= newsletterTypeName %>" /></td>
</tr>
<tr>
  <td class="formLabel">Newsletter Handle</td>
  <td><input type="text" class="formElement" name="newsletterTypeHandle" maxsize="32" value="<%= newsletterTypeHandle %>" /></td>
</tr>
<tr>
  <td class="formLabel">From Address</td>
  <td><input type="text" class="formElement" name="fromAddress" size="40" maxsize="250" value="<%= fromAddress %>" /></td>
</tr>
<tr>
  <td class="formLabel">From Address Can Change</td>
  <td><input type="checkbox" class="formElement" name="fromAddressPerSend" value="t"<%= ( ( fromAddressPerSend ) ? " checked=\"checked\"" : "" ) %>" /></td>
</tr>
<tr>
  <td class="formLabel">Description</td>
  <td><textarea class="formElement" name="description" cols="40" rows="5"><%= description %></textarea></td>
</tr>
<tr>
  <td class="formLabel">Standard HTML Header</td>
  <td><textarea class="formElement" name="htmlHeader" cols="40" rows="5"><%= htmlHeader %></textarea></td>
</tr>
<tr>
  <td class="formLabel">Standard HTML Footer</td>
  <td><textarea class="formElement" name="htmlFooter" cols="40" rows="5"><%= htmlFooter %></textarea></td>
</tr>
<tr>
  <td class="formLabel">Standard Text Header</td>
  <td><textarea class="formElement" name="textHeader" cols="40" rows="5"><%= textHeader %></textarea></td>
</tr>
<tr>
  <td class="formLabel">Standard Text Footer</td>
  <td><textarea class="formElement" name="textFooter" cols="40" rows="5"><%= textFooter %></textarea></td>
</tr>
<tr>
  <td colspan="2" class="subHead">Allowed Content</td>

</tr>
<tr>
  <td colspan="2" class="note">Check the content areas that can go into this type of newsletter.</td>
</tr>

<%

ps = conn.prepareStatement( SELECT_LISTS_SQL );
ps.setInt( 1, newsletterTypeId );
rs = ps.executeQuery();

while( rs.next() )
{
  listTypeId = rs.getInt(    "listTypeId" );
  listName   = rs.getString( "listName" );
  usingType  = ( rs.getString( "newsletterTypeId" ) != null );
  groupCount = rs.getInt(    "groupCount" );

%>
<tr>
  <td class="formLabel"><%= listName %><img src="/art/<%= ( ( groupCount > 0 ) ? "admin/secure" : "blank" ) %>.gif" width="10" style="padding:1px" /></td>
  <td><input type="checkbox" name="type_<%= listTypeId %>" value="t"<%= ( ( usingType ) ? " checked=\"checked\"" : "" ) %> /></td>
</tr>
<%

}

rs.close();
ps.close();

%>
<tr>
  <td colspan="2" class="formButtons"><input type="button" onclick="document.location.href='typeList.jsp'" value="Cancel" class="formButton" /> <input type="submit" value="<%= mode %>" class="formButton" /></td>
</tr>
</table>
</form>
</body>
</html><%

conn.close();

%>