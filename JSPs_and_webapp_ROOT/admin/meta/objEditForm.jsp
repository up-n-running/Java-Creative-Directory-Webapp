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

String getTypeInfoSql = "SELECT typeName, typePlural, typeHandle, typeNameLabel FROM objTypes WHERE objTypeId=?";

int typeId = NumberUtils.parseInt( request.getParameter( "typeId" ), -1 );

String typeName      = "";
String typePlural    = "";
String typeHandle    = "";
String typeNameLabel = "";
String function      = "Edit";

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

if( typeId == -1 )
{
  function = "Add";
}
else
{
  ps = conn.prepareStatement( getTypeInfoSql );
  ps.setInt( 1, typeId );
  rs = ps.executeQuery();

  if( rs.next() )
  {
    typeName      = rs.getString( "typeName" );
    typePlural    = rs.getString( "typePlural" );
    typeHandle    = rs.getString( "typeHandle" );
    typeNameLabel = rs.getString( "typeNameLabel" );
  }

  rs.close();
  ps.close();
}

%><html>
<head>
  <title>extSell: Administration: Site Object Types: <%= function %></title>
  <link rel="stylesheet" type="text/css" href="/style/admin.css">
</head>
<body onload="document.forms[0].typeName.focus()">
<form action="objDatabase.jsp" method="get">
<input type="hidden" name="typeId" value="<%= typeId %>" />
<input type="hidden" name="function" value="<%= function.toLowerCase() %>" />
<table border="0" cellpadding="0" cellspacing="0">
<tr>
  <td colspan="2" class="title"><%= function %> Site Object Type</td>
</tr>

<tr>
  <td class="formLabel">Type Name</td>
  <td><input type="text" name="typeName" value="<%= typeName %>" /></td>
</tr>

<tr>
  <td class="formLabel">Type Plural</td>
  <td><input type="text" name="typePlural" value="<%= typePlural %>" /></td>
</tr>

<tr>
  <td class="formLabel">Type Name Label</td>
  <td><input type="text" name="typeNameLabel" value="<%= typeNameLabel %>" /></td>
</tr>

<tr>
  <td class="formLabel">Handle</td>
  <td><input type="text" name="typeHandle" value="<%= typeHandle %>" /></td>
</tr>

<tr>
  <td colspan="2" class="formButtons"><input type="button" value="Cancel" onClick="document.location.href='index.jsp'" /> <input type="submit" value="<%= function %>" /></td>
</tr>
</table>
</form>
</body>
</html>