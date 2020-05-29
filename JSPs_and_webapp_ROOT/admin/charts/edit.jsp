<%@ page language="java"
  import="com.extware.utils.BooleanUtils,
          com.extware.utils.DatabaseUtils,
          com.extware.utils.NumberUtils,
          com.extware.utils.PropertyFile,
          com.extware.utils.StringUtils,
          com.extware.user.UserDetails,
          com.extware.user.UserGroup,
          java.sql.Connection,
          java.sql.PreparedStatement,
          java.sql.ResultSet,
          java.util.ArrayList"
%><%

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

String SELECT_CHARTTYPE_SQL   = "SELECT chartTypeName, chartTypeHandle, weekStartId, chartLength, col1Name, col2Name, col3Name, col4Name FROM chartType WHERE chartTypeId=?";

PropertyFile dataDictionary = PropertyFile.getDataDictionary();

//*String[] columnList = new String[] { "title", "standfirst", "body", "fromDate", "toDate", "liveDate", "removeDate", "formOrder" };

boolean visibleToGroup;
//*boolean visibleOnSite  = BooleanUtils.parseBoolean( request.getParameter( "visibleOnSite" ) );

int chartTypeId  = NumberUtils.parseInt( request.getParameter( "chartTypeId" ), -1 );
String chartTypeName   = StringUtils.nullString( request.getParameter( "chartTypeName" ) );
String chartTypeHandle = StringUtils.nullString( request.getParameter( "chartTypeHandle" ) ).trim();
int    weekStartId = NumberUtils.parseInt( request.getParameter( "weekStartId" ), -1 );
int    chartLength = NumberUtils.parseInt( request.getParameter( "chartLength" ), -1 );
String col1Name = StringUtils.nullString( request.getParameter( "col1Name" ) );
String col2Name = StringUtils.nullString( request.getParameter( "col2Name" ) );
String col3Name = StringUtils.nullString( request.getParameter( "col3Name" ) );
String col4Name = StringUtils.nullString( request.getParameter( "col4Name" ) );
if( col1Name.equals( "" ) ) { col1Name = null; }
if( col2Name.equals( "" ) ) { col2Name = null; }
if( col3Name.equals( "" ) ) { col3Name = null; }
if( col4Name.equals( "" ) ) { col4Name = null; }

String mode            = "Edit";
String errors          = StringUtils.nullString( request.getParameter( "errors" ) ).trim();
String message         = StringUtils.nullString( request.getParameter( "message" ) ).trim();



Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

if( chartTypeId != -1 )
{
  ps = conn.prepareStatement( SELECT_CHARTTYPE_SQL );
  ps.setInt( 1, chartTypeId );
  rs = ps.executeQuery();

  if( rs.next() )
  {
    chartTypeName   = StringUtils.nullString( rs.getString( "chartTypeName"   ) );
    chartTypeHandle = StringUtils.nullString( rs.getString( "chartTypeHandle" ) );
    weekStartId     = rs.getInt(                            "weekStartId"       );
    chartLength     = rs.getInt(                            "chartLength"       );
    col1Name        = StringUtils.nullString( rs.getString( "col1Name"        ) );
    col2Name        = StringUtils.nullString( rs.getString( "col2Name"        ) );
    col3Name        = StringUtils.nullString( rs.getString( "col3Name"        ) );
    col4Name        = StringUtils.nullString( rs.getString( "col4Name"        ) );
  }

  rs.close();
  ps.close();
}
else
{
  mode = "Add";

//  if( request.getParameter( "visibleOnSite" ) == null )						// New Types default to visible
//  {
//    visibleOnSite = true;
//  }
}

%><html>
<head>
  <title>Single Page Admin</title>
  <link rel="stylesheet" href="/style/admin.css" type="text/css">
  <script language="JavaScript" type="text/javascript" src="/js/richtextReadProps.jsp"></script>
  <script language="JavaScript" type="text/javascript" src="/js/richtext.js"></script>
</head>
<body class="adminPane">
<form name="textPage" action="pageDatabase.jsp" onsubmit="return submitForm();" method="post">
<input type="hidden" name="chartTypeId" value="<%= chartTypeId %>" />
<input type="hidden" name="mode" value="<%= mode.toLowerCase() %>" />
<table border="0" cellpadding="0" cellpadding="0">
<tr>
  <td colspan="2" class="title"><%= mode %> a Chart Type</td>
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
  <td class="formLabel">Chart Type Name</td>
  <td><input type="text" class="formElement" name="chartTypeName" value="<%= chartTypeName %>" /></td>
</tr>
<tr>
  <td class="formLabel">Chart Type Handle</td>
  <td><input type="text" class="formElement" name="chartTypeHandle" value="<%= chartTypeHandle %>" /></td>
</tr>
<tr>
  <td class="formLabel">Week Start Day Number</td>
  <td><input type="text" class="formElement" name="weekStartId" value="<%= weekStartId %>" /></td>
</tr>
<tr>
  <td class="formLabel">Max Number of Rows in Chart.</td>
  <td><input type="text" class="formElement" name="chartLength" value="<%= chartLength %>" /></td>
</tr>
<tr>
  <td class="formLabel">Column 1 name (leave blank for none)</td>
  <td><input type="text" class="formElement" name="col1Name" value="<%= StringUtils.nullString( col1Name ) %>" /></td>
</tr>
<tr>
  <td class="formLabel">Column 2 name (leave blank for none)</td>
  <td><input type="text" class="formElement" name="col2Name" value="<%= StringUtils.nullString( col2Name ) %>" /></td>
</tr>
<tr>
  <td class="formLabel">Column 3 name (leave blank for none)</td>
  <td><input type="text" class="formElement" name="col3Name" value="<%= StringUtils.nullString( col3Name ) %>" /></td>
</tr>
<tr>
  <td class="formLabel">Column 4 name (leave blank for none)</td>
  <td><input type="text" class="formElement" name="col4Name" value="<%= StringUtils.nullString( col4Name ) %>" /></td>
</tr>
<tr>
  <td colspan="2" class="formButtons"><input type="button" onclick="document.location.href='index.jsp'" value="Cancel" class="formButton" /> <input type="submit" value="<%= mode %>" class="formButton" /></td>
</tr>
</table>
</form>
</body>
</html><%

conn.close();

%>