<%@ page language="java"
  import="com.extware.common.DataDictionary,
          com.extware.utils.NumberUtils,
          com.extware.utils.StringUtils,
          com.extware.user.UserDetails"
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

%><html>
<head>
  <title>Add new Meta Data Group</title>
  <link rel="stylesheet" type="text/css" href="/style/admin.css">
</head>
<body onload="document.forms[0].groupName.focus()">
<form action="groupDatabase.jsp" method="get">
<input type="hidden" name="function" value="quickadd" />
<input type="hidden" name="objTypeId" value="<%= typeId %>" />
<input type="hidden" name="passBack" value="opener.addGroup" />
<table border="0" cellpadding="0" cellspacing="0">
<tr>
  <td colspan="2" class="title">Add Meta Data Group</td>
</tr>
<tr>
  <td class="formLabel">Group Name</td>
  <td><input type="text" name="groupName" /></td>
</tr>
<tr>
  <td class="formLabel">Group Values<br />
    <span class="smallLabel">(one value per line)</span></td>
  <td><textarea name="groupValues" cols="30" rows="10"></textarea></td>
</tr>
<tr>
  <td colspan="2" class="formButtons"><input type="button" value="Cancel" onClick="self.close()" /> <input type="submit" value="Add" /></td>
</tr>
</table>
</form>
</body>
</html>