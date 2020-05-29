<%@ page language="java"
  import="com.extware.common.DataDictionary,
          com.extware.utils.BooleanUtils,
          com.extware.utils.DatabaseUtils,
          com.extware.utils.NumberUtils,
          com.extware.utils.StringUtils,
          com.extware.user.UserDetails,
          java.sql.Connection,
          java.sql.PreparedStatement,
          java.sql.ResultSet,
          java.util.Hashtable"
%><%

int typeId      = NumberUtils.parseInt( request.getParameter( "typeId" ),         -1 );
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

String getMetaTypeInfoSql = "SELECT typeName, metaGroupId, groupType, objMetaPageId, hidden, required, minUserLevel FROM objMetaTypes WHERE objMetaTypeId=? ORDER BY formOrder";
String getMetaGroupsSql   = "SELECT objMetaChoiceGroupId, groupName FROM objMetaChoiceGroups WHERE objTypeId=? OR objTypeId IS NULL ORDER BY groupName";
String countMetaPagesSql  = "SELECT COUNT(objMetaPageId) pageCount FROM objMetaPages WHERE objTypeId=?";
String getMetaPagesSql    = "SELECT objMetaPageId, metaPageName FROM objMetaPages WHERE objTypeId=? ORDER BY formOrder";

boolean hidden   = BooleanUtils.parseBoolean( request.getParameter( "hidden" ) );
boolean required = BooleanUtils.parseBoolean( request.getParameter( "required" ) );

int pageCount     = 0;
int metaTypeId    = NumberUtils.parseInt( request.getParameter( "metaTypeId" ),    -1 );
int metaGroupId   = NumberUtils.parseInt( request.getParameter( "metaGroupId" ),   -1 );
int objMetaPageId = NumberUtils.parseInt( request.getParameter( "objMetaPageId" ), -1 );
int minUserLevel  = NumberUtils.parseInt( request.getParameter( "minUserLevel" ),   0 );

String function      = "Edit";
String errorDesc     = StringUtils.nullString( request.getParameter( "errorDesc" ) );
String metaTypeName  = StringUtils.nullString( request.getParameter( "metaTypeName" ) );
String metaGroupType = StringUtils.nullString( request.getParameter( "metaGroupType" ) );

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

ps = conn.prepareStatement( countMetaPagesSql );
ps.setInt( 1, typeId );
rs = ps.executeQuery();

if( rs.next() )
{
  pageCount = rs.getInt( "pageCount" );
}

rs.close();
ps.close();

Hashtable errors = new Hashtable();
errors.put( "alreadyexists", "That meta type name already exists." );

if( metaTypeId == -1 )
{
  function = "Add";
}
else
{
  ps = conn.prepareStatement( getMetaTypeInfoSql );
  ps.setInt( 1, metaTypeId );
  rs = ps.executeQuery();

  if( rs.next() )
  {
    metaTypeName  = rs.getString( "typeName" );
    metaGroupId   = NumberUtils.parseInt(      rs.getString( "metaGroupId" ),   -1 );
    metaGroupType = StringUtils.nullString(    rs.getString( "groupType" ) );
    objMetaPageId = NumberUtils.parseInt(      rs.getString( "objMetaPageId" ), -1 );
    minUserLevel  = NumberUtils.parseInt(      rs.getString( "minUserLevel" ),   0 );
    hidden        = BooleanUtils.parseBoolean( rs.getString( "hidden" ) );
    required      = BooleanUtils.parseBoolean( rs.getString( "required" ) );
  }

  rs.close();
  ps.close();
}

%><html>
<head>
  <title>extSell: Administration: Site Object Meta Data Types: <%= function %></title>
  <link rel="stylesheet" type="text/css" href="/style/admin.css">
<script type="text/javascript">
function openPop( href )
{
  window.open( href, "extSellPopup", "width=400,height=350" );
  return false;
}
function addGroup( groupId, groupName )
{
  o = new Option( groupName, groupId );
  theSelect = document.forms[0].metaGroupId;
  l = theSelect.options.length;
  theSelect.options[l] = o;
  theSelect.selectedIndex = l;
}
function setPresTypes( theForm )
{
  var selectedType = theForm.metaGroupId.selectedIndex;

  if( selectedType == 0 )
  {
    emptySelect( theForm.metaGroupType );
    theForm.metaGroupType.options[theForm.metaGroupType.options.length] = new Option( "Small Text", "T" );
    theForm.metaGroupType.options[theForm.metaGroupType.options.length] = new Option( "Large Text", "L" );
  }
  else
  {
    emptySelect( theForm.metaGroupType );
    theForm.metaGroupType.options[theForm.metaGroupType.options.length] = new Option( "Single Select", "S" );
    theForm.metaGroupType.options[theForm.metaGroupType.options.length] = new Option( "Checkboxes",    "C" );
    theForm.metaGroupType.options[theForm.metaGroupType.options.length] = new Option( "Multi-Select",  "M" );
    theForm.metaGroupType.options[theForm.metaGroupType.options.length] = new Option( "Radio Buttons", "R" );
  }
}
function emptySelect( sel )
{
  for( var i = sel.options.length ; i > 0 ; i-- )
  {
    sel.options[i - 1] = null;
  }
}
</script>
</head>
<body onload="setPresTypes( document.forms[0] );document.forms[0].metaTypeName.focus()">
<form action="metaDatabase.jsp" method="get">
<input type="hidden" name="typeId" value="<%= typeId %>" />
<input type="hidden" name="metaTypeId" value="<%= metaTypeId %>" />
<input type="hidden" name="function" value="<%= function.toLowerCase() %>" />
<table border="0" cellpadding="0" cellspacing="0">
<tr>
  <td colspan="2" class="title"><%= function %> Meta Data Type</td>
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
  <td class="formLabel">Meta Data Type Name</td>
  <td><input type="text" name="metaTypeName" value="<%= metaTypeName %>" /></td>
</tr>
<%

if( pageCount > 0 )
{

%>
<tr>
  <td class="formLabel">Page</td>
  <td><select name="objMetaPageId">
      <option value="-1">Default</option>
<%

  ps = conn.prepareStatement( getMetaPagesSql );
  ps.setInt( 1, typeId );
  rs = ps.executeQuery();

  while( rs.next() )
  {
    int    pageId   = rs.getInt(    "objMetaPageId" );
    String pageName = rs.getString( "metaPageName" );

%>      <option value="<%= pageId %>"<%= ( ( pageId == objMetaPageId ) ? " selected=\"selected\"" : "" ) %>><%= pageName %></option>
<%

  }

  rs.close();
  ps.close();

%>
    </select></td>
</tr>
<%

}

%>
<tr>
  <td class="formLabel">DataType</td>
  <td><select name="metaGroupId" onChange="setPresTypes(this.form)">
      <option value="-1">Free Text</option>
<%

ps = conn.prepareStatement( getMetaGroupsSql );
ps.setInt( 1, typeId );
rs = ps.executeQuery();

while( rs.next() )
{
  int groupId = rs.getInt( "objMetaChoiceGroupId" );

%>      <option value="<%= groupId %>"<%= ( ( groupId == metaGroupId ) ? " selected=\"selected\"" : "" ) %>><%= rs.getString( "groupName" ) %></option>
<%

}

rs.close();
ps.close();

%>    </select> <a href="groupQuickAdd.jsp?typeId=<%= typeId %>" onClick="return openPop(this)">Quick Add Meta Data Group</a></td>
</tr>
<tr>
  <td class="formLabel">Presentation</td>
  <td><select name="metaGroupType">
      <option value="T"<%= ( ( metaGroupType.equals( "T" ) ) ? " selected=\"selected\"" : "" ) %>>Small Text</option>
      <option value="L"<%= ( ( metaGroupType.equals( "L" ) ) ? " selected=\"selected\"" : "" ) %>>Large Text</option>
      <option value="S"<%= ( ( metaGroupType.equals( "S" ) ) ? " selected=\"selected\"" : "" ) %>>Single Select</option>
      <option value="C"<%= ( ( metaGroupType.equals( "C" ) ) ? " selected=\"selected\"" : "" ) %>>Checkboxes</option>
      <option value="M"<%= ( ( metaGroupType.equals( "M" ) ) ? " selected=\"selected\"" : "" ) %>>Multi-Select</option>
      <option value="R"<%= ( ( metaGroupType.equals( "R" ) ) ? " selected=\"selected\"" : "" ) %>>Radio Buttons</option>
    </select></td>
</tr>
<tr>
  <td class="formLabel">Required</td>
  <td><input type="checkbox" name="required" value="<%= DataDictionary.DB_TRUE_CHAR %>"<%= ( ( required ) ? " checked=\"checked\"" : "" ) %>"></td>
</tr>
<tr>
  <td class="formLabel">Hidden</td>
  <td><input type="checkbox" name="hidden" value="<%= DataDictionary.DB_TRUE_CHAR %>"<%= ( ( hidden ) ? " checked=\"checked\"" : "" ) %>"></td>
</tr>
<tr>
  <td colspan="2" class="formButtons"><input type="button" value="Cancel" onClick="document.location.href='metaList.jsp?typeId=<%= typeId %>'" /> <input type="submit" value="<%= function %>" /></td>
</tr>
</table>
</body>
</html><%

conn.close();

%>