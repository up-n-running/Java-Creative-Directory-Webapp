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

if( !user.isAdmin() )
{
  response.sendRedirect( "/admin/blank.html" );
  return;
}

String SELECT_NEWSLETTER_SQL  = "SELECT n.newsletterName, n.fromAddress, t.fromAddressPerSend, n.htmlHeader, n.textHeader, n.htmlFooter, n.textFooter FROM newsletters n INNER JOIN newsletterTypes t ON t.newsletterTypeId=n.newsletterTypeId WHERE n.newsletterId=?";

boolean usingType;
boolean fromAddressPerSend = BooleanUtils.parseBoolean( request.getParameter( "fromAddressPerSend" ) );

int listTypeId;
int groupCount;
int newsletterId     = NumberUtils.parseInt( request.getParameter( "newsletterId" ),     -1 );
int newsletterTypeId = NumberUtils.parseInt( request.getParameter( "newsletterTypeId" ), -1 );

String listName;
String mode             = "Edit";
String errors           = StringUtils.nullString( request.getParameter( "errors" ) ).trim();
String message          = StringUtils.nullString( request.getParameter( "message" ) ).trim();
String newsletterName   = StringUtils.nullString( request.getParameter( "newsletterTypeName" ) ).trim();
String fromAddress      = StringUtils.nullString( request.getParameter( "fromAddress" ) ).trim();
String htmlHeader       = StringUtils.nullString( request.getParameter( "htmlHeader" ) ).trim();
String textHeader       = StringUtils.nullString( request.getParameter( "textHeader" ) ).trim();
String htmlFooter       = StringUtils.nullString( request.getParameter( "htmlFooter" ) ).trim();
String textFooter       = StringUtils.nullString( request.getParameter( "textFooter" ) ).trim();

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

if( newsletterId != -1 )
{
  ps = conn.prepareStatement( SELECT_NEWSLETTER_SQL );
  ps.setInt( 1, newsletterId );
  rs = ps.executeQuery();

  if( rs.next() )
  {
    newsletterName     = StringUtils.nullString( rs.getString( "newsletterName" ) ).trim();
    fromAddress        = StringUtils.nullString( rs.getString( "fromAddress" ) ).trim();
    fromAddressPerSend = BooleanUtils.parseBoolean( rs.getString( "fromAddressPerSend" ) );
    htmlHeader         = StringUtils.nullString( rs.getString( "htmlHeader" ) ).trim();
    textHeader         = StringUtils.nullString( rs.getString( "textHeader" ) ).trim();
    htmlFooter         = StringUtils.nullString( rs.getString( "htmlFooter" ) ).trim();
    textFooter         = StringUtils.nullString( rs.getString( "textFooter" ) ).trim();
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
  <title>Newsletter Admin</title>
  <link rel="stylesheet" href="/style/admin.css" type="text/css">
</head>
<body class="adminPane">
<form action="saveNewsletter.jsp" method="post">
<input type="hidden" name="newsletterId" value="<%= newsletterId %>" />
<input type="hidden" name="newsletterTypeId" value="<%= newsletterTypeId %>" />
<input type="hidden" name="mode" value="<%= mode.toLowerCase() %>" />
<table border="0" cellpadding="0" cellpadding="0">
<tr>
  <td colspan="2" class="title"><%= mode %> a Newsletter</td>
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
  <td><input type="text" class="formElement" name="newsletterName" size="40" maxsize="64" value="<%= newsletterName %>" /></td>
</tr>
<%

if( fromAddressPerSend )
{

%>
<tr>
  <td class="formLabel">From Address</td>
  <td><input type="text" class="formElement" name="fromAddress" size="40" maxsize="250" value="<%= fromAddress %>" /></td>
</tr>
<%

}
else
{

%><input type="hidden" name="fromAddress" value="<%= fromAddress %>" />
<%

}

%>
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
  <td colspan="2" class="formButtons"><input type="submit" value="Save" class="formButton" /></td>
</tr>
</table>
</form>
</body>
</html><%

conn.close();

%>