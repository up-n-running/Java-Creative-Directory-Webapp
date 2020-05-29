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

String getMetaPageInfoSql = "SELECT metaPageName, shortPageName, metaPageHandle, canStartChain, mustStartChain, canBeInChain FROM objMetaPages WHERE objMetaPageId=?";

boolean canStartChain  = StringUtils.nullString( request.getParameter( "canStartChain"  ) ).equals( DataDictionary.DB_TRUE_CHAR );
boolean mustStartChain = StringUtils.nullString( request.getParameter( "mustStartChain" ) ).equals( DataDictionary.DB_TRUE_CHAR );
boolean canBeInChain   = StringUtils.nullString( request.getParameter( "canBeInChain"   ) ).equals( DataDictionary.DB_TRUE_CHAR );

int objMetaPageId = NumberUtils.parseInt( request.getParameter( "objMetaPageId" ), -1 );

String function       = "Edit";
String errorDesc      = StringUtils.nullString( request.getParameter( "errorDesc" ) );
String metaPageName   = StringUtils.nullString( request.getParameter( "metaPageName" ) );
String shortPageName  = StringUtils.nullString( request.getParameter( "shortPageName" ) );
String metaPageHandle = StringUtils.nullString( request.getParameter( "metaPageHandle" ) );
String backTo         = StringUtils.nullReplace( request.getParameter( "backTo" ), "pageList" );

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

Hashtable errors = new Hashtable();
errors.put( "alreadyexists", "That meta page name already exists." );

if( objMetaPageId == -1 )
{
  function = "Add";
}
else
{
  ps = conn.prepareStatement( getMetaPageInfoSql );
  ps.setInt( 1, objMetaPageId );
  rs = ps.executeQuery();

  if( rs.next() )
  {
    metaPageName   = rs.getString( "metaPageName" );
    shortPageName  = StringUtils.nullString( rs.getString( "shortPageName" ) );
    metaPageHandle = rs.getString( "metaPageHandle" );
    canStartChain  = StringUtils.nullString( rs.getString( "canStartChain"  ) ).equals( DataDictionary.DB_TRUE_CHAR );
    mustStartChain = StringUtils.nullString( rs.getString( "mustStartChain" ) ).equals( DataDictionary.DB_TRUE_CHAR );
    canBeInChain   = StringUtils.nullString( rs.getString( "canBeInChain"   ) ).equals( DataDictionary.DB_TRUE_CHAR );
  }

  rs.close();
  ps.close();
}

%><html>
<head>
  <title>extSell: Administration: Site Object Meta Data Types: <%= function %></title>
  <link rel="stylesheet" type="text/css" href="/style/admin.css">
</head>
<body onload="document.forms[0].metaPageName.focus()">
<form action="pageDatabase.jsp" method="get">
<input type="hidden" name="typeId" value="<%= typeId %>" />
<input type="hidden" name="objMetaPageId" value="<%= objMetaPageId %>" />
<input type="hidden" name="backTo" value="<%= backTo %>" />
<input type="hidden" name="function" value="<%= function.toLowerCase() %>" />
<table border="0" cellpadding="0" cellspacing="0">
<tr>
  <td colspan="2" class="title"><%= function %> Meta Data Page</td>
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
  <td class="formLabel">Page Name</td>
  <td><input type="text" name="metaPageName" value="<%= metaPageName %>" /></td>
</tr>

<tr>
  <td class="formLabel">Short Page Name</td>
  <td><input type="text" name="shortPageName" value="<%= shortPageName %>" /></td>
</tr>

<tr>
  <td class="formLabel">Page Handle</td>
  <td><input type="text" name="metaPageHandle" value="<%= metaPageHandle %>" /></td>
</tr>

<tr>
  <td class="formLabel">Can Be In Chain</td>
  <td><input type="checkbox" name="canBeInChain" value="<%= DataDictionary.DB_TRUE_CHAR %>"<%= ( ( canBeInChain ) ? " checked=\"checked\"" : "" ) %> /></td>
</tr>

<tr>
  <td class="formLabel">Can Start Chain</td>
  <td><input type="checkbox" name="canStartChain" value="<%= DataDictionary.DB_TRUE_CHAR %>"<%= ( ( canStartChain ) ? " checked=\"checked\"" : "" ) %> /></td>
</tr>

<tr>
  <td class="formLabel">Must Start Chain</td>
  <td><input type="checkbox" name="mustStartChain" value="<%= DataDictionary.DB_TRUE_CHAR %>"<%= ( ( mustStartChain ) ? " checked=\"checked\"" : "" ) %> /></td>
</tr>

<tr>
  <td colspan="2" class="formButtons"><input type="button" value="Cancel" onClick="document.location.href='<%= backTo %>.jsp?typeId=<%= typeId %>'" /> <input type="submit" value="<%= function %>" /></td>
</tr>
</table>
</body>
</html><%

conn.close();

%>