<%@ page language="java"
  import="com.extware.utils.DatabaseUtils,
          com.extware.utils.NumberUtils,
          com.extware.utils.StringUtils,
          com.extware.utils.PropertyFile,
          com.extware.user.UserDetails,
	  com.extware.extsite.lists.sql.ListSql,
          java.sql.Connection,
          java.sql.PreparedStatement,
          java.sql.ResultSet,
          java.util.Date,
	  java.util.ArrayList,
          java.util.GregorianCalendar"
%><%!

GregorianCalendar getCalendar( HttpServletRequest request, String baseName )
{
  int day   = NumberUtils.parseInt( request.getParameter( baseName + "Day" ),   -1 );
  int month = NumberUtils.parseInt( request.getParameter( baseName + "Month" ), -1 );
  int year  = NumberUtils.parseInt( request.getParameter( baseName + "Year" ),  -1 );

  if( day != -1 && month != -1 && year != -1 )
  {
    return new GregorianCalendar( year, month - 1, day );
  }

  return null;
}

GregorianCalendar setCalendar( Date dateRep )
{
  if( dateRep == null )
  {
    return null;
  }

  GregorianCalendar cal = new GregorianCalendar();
  cal.setTime( dateRep );

  return cal;
}

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

String SELECT_TYPE_SQL = "SELECT listName, titleLabel, standfirstLabel, bodyLabel, dateLabel FROM listTypes WHERE listTypeId=?";
String SELECT_ITEM_SQL = "SELECT title, standfirst, body, fromDate, toDate, liveDate, removeDate FROM listItems WHERE listItemId=?";

String continentSQL;
String regions_sql;

//creation of the arraylist that are going to have the label and content if extrra fields needed
ArrayList extraFieldsLabel  = new ArrayList();
ArrayList extraFieldsType = new ArrayList();
ArrayList extraFieldsContent  = new ArrayList();

int listTypeId = NumberUtils.parseInt( request.getParameter( "listTypeId" ), -1 );
int listItemId = NumberUtils.parseInt( request.getParameter( "listItemId" ), -1 );
int i = 0;

String listName        = "";
String bodyLabel       = "";
String dateLabel       = "";
String titleLabel      = "";
String standfirstLabel = "";
String mode            = "Edit";
String errors          = StringUtils.nullString( request.getParameter( "errors" ) ).trim();
String message         = StringUtils.nullString( request.getParameter( "message" ) ).trim();
String title           = StringUtils.nullString( request.getParameter( "title" ) ).trim();
String standfirst      = StringUtils.nullString( request.getParameter( "standfirst" ) ).trim();
String body            = StringUtils.nullString( request.getParameter( "body" ) ).trim();

GregorianCalendar fromDate   = getCalendar( request, "fromDate" );
GregorianCalendar toDate     = getCalendar( request, "toDate" );
GregorianCalendar liveDate   = getCalendar( request, "liveDate" );
GregorianCalendar removeDate = getCalendar( request, "removeDate" );

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

ps = conn.prepareStatement( SELECT_TYPE_SQL );
ps.setInt( 1, listTypeId );
rs = ps.executeQuery();

if( rs.next() )
{
  listName        = StringUtils.nullString( rs.getString( "listName" ) );
  titleLabel      = StringUtils.nullString( rs.getString( "titleLabel" ) );
  standfirstLabel = StringUtils.nullString( rs.getString( "standfirstLabel" ) );
  bodyLabel       = StringUtils.nullString( rs.getString( "bodyLabel" ) );
  dateLabel       = StringUtils.nullString( rs.getString( "dateLabel" ) );
}

rs.close();
ps.close();

PropertyFile extraFieldsProps = new PropertyFile( "com.extware.properties.ExtraFields" );
String extraFieldsHandle = extraFieldsProps.getString( "extrafieldshandle.listTypeId." + listTypeId );
String columnName="";

if( extraFieldsHandle != null )
{
  int noOfFields = extraFieldsProps.getInt( "extrafields." + extraFieldsHandle+  ".noOfExtraFields" );

  for( i = 0 ; i < noOfFields ; i++ )
  {
    String label1 = extraFieldsProps.getString( "extrafields." + extraFieldsHandle + "." + ( i + 1 ) + ".label" );
    extraFieldsLabel.add( label1 );

    String label2 = extraFieldsProps.getString( "extrafields." + extraFieldsHandle + "." + ( i + 1 ) + ".type" );
    extraFieldsType.add( label2 );
  }

  extraFieldsContent = ListSql.getExtraFieldValues(listItemId, listTypeId);
}

titleLabel      = ( ( titleLabel.equals( "" )      ) ? "Title"      : titleLabel      );
standfirstLabel = ( ( standfirstLabel.equals( "" ) ) ? "Standfirst" : standfirstLabel );
bodyLabel       = ( ( bodyLabel.equals( "" )       ) ? "Body"       : bodyLabel       );
dateLabel       = ( ( dateLabel.equals( "" )       ) ? "Date"       : dateLabel       );

if( listItemId != -1 )
{
  ps = conn.prepareStatement( SELECT_ITEM_SQL );
  ps.setInt( 1, listItemId );
  rs = ps.executeQuery();

  if( rs.next() )
  {
    title      = StringUtils.nullString( rs.getString( "title" ) ).trim();
    standfirst = StringUtils.nullString( rs.getString( "standfirst" ) ).trim();
    body       = StringUtils.nullString( rs.getString( "body" ) ).trim();
    fromDate   = setCalendar( rs.getTimestamp( "fromDate" ) );
    toDate     = setCalendar( rs.getTimestamp( "toDate" ) );
    liveDate   = setCalendar( rs.getTimestamp( "liveDate" ) );
    removeDate = setCalendar( rs.getTimestamp( "removeDate" ) );
  }

  rs.close();
  ps.close();
}
else
{
  mode = "Add";
}

%>

<html>
<head>
  <title>List Admin</title>
  <link rel="stylesheet" href="/style/admin.css" type="text/css">
<script type="text/javascript" src="/js/dateForm.js"></script>
<script type="text/javascript">
dateElementRoots = new Array( "fromDate", "toDate", "liveDate", "removeDate" );
dateListToSetTo  = new Array();
dateListToSetTo[0] = <%= ( ( fromDate   != null || mode.equals( "Add" ) ) ? "new Date(" + ( ( fromDate   != null ) ? " " + fromDate.get( fromDate.YEAR )     + ", " + fromDate.get( fromDate.MONTH )     + ", " + fromDate.get( fromDate.DAY_OF_MONTH )     : "" ) + ")" : "null" ) %>;
dateListToSetTo[1] = <%= ( ( toDate     != null || mode.equals( "Add" ) ) ? "new Date(" + ( ( toDate     != null ) ? " " + toDate.get( toDate.YEAR )         + ", " + toDate.get( toDate.MONTH )         + ", " + toDate.get( toDate.DAY_OF_MONTH )         : "" ) + ")" : "null" ) %>;
dateListToSetTo[2] = <%= ( ( liveDate   != null || mode.equals( "Add" ) ) ? "new Date(" + ( ( liveDate   != null ) ? " " + liveDate.get( liveDate.YEAR )     + ", " + liveDate.get( liveDate.MONTH )     + ", " + liveDate.get( liveDate.DAY_OF_MONTH )     : "" ) + ")" : "null" ) %>;
dateListToSetTo[3] = <%= ( ( removeDate != null || mode.equals( "Add" ) ) ? "new Date(" + ( ( removeDate != null ) ? " " + removeDate.get( removeDate.YEAR ) + ", " + removeDate.get( removeDate.MONTH ) + ", " + removeDate.get( removeDate.DAY_OF_MONTH ) : "" ) + ")" : "null" ) %>;
</script>
  <script type="text/javascript" src="/js/ipsum.js"></script>
</head>
<body class="adminPane">
<form action="itemDatabase.jsp" method="post">
<input type="hidden" name="listTypeId" value="<%= listTypeId %>" />
<input type="hidden" name="listItemId" value="<%= listItemId %>" />
<input type="hidden" name="mode" value="<%= mode.toLowerCase() %>" />
<table border="0" cellpadding="0" cellpadding="0">
<tr>
  <td colspan="2" class="title"><%= listName %>: <%= mode %> an Item</td>
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

if( !titleLabel.equals( "<none>" ) )
{

%>
<tr>
  <td class="formLabel"><%= titleLabel %></td>
  <td><input type="text" class="formElement" name="title" value="<%= title %>" size="40" /></td>
</tr>
<%

}

if( !dateLabel.equals( "<none>" ) )
{

%>
<tr>
  <td class="formLabel"><%= dateLabel %> From</td>
  <td><jsp:include page="/inc/dateSelect.jsp" flush="true" >
      <jsp:param name="nameRoot" value="fromDate"/>
      <jsp:param name="includeBlanks" value="t"/>
    </jsp:include> <a href="#" onclick="return blankDate('fromDate')">No Date</a></td>
</tr>

<tr>
  <td class="formLabel">To</td>
  <td><jsp:include page="/inc/dateSelect.jsp" flush="true" >
      <jsp:param name="nameRoot" value="toDate"/>
      <jsp:param name="includeBlanks" value="t"/>
    </jsp:include> <a href="#" onclick="return blankDate('toDate')">No Date</a></td>
</tr>
<%

}

if( !standfirstLabel.equals( "<none>" ) )
{

%>
<tr>
  <td class="formLabel"><%= standfirstLabel %></td>
  <td><textarea class="formElement" name="standfirst" cols="40" rows="2"><%= standfirst %></textarea></td>
  <td><script type="text/javascript">ipsum('standfirst',2)</script></td>
</tr>
<%

}

if( !bodyLabel.equals( "<none>" ) )
{

%>
<tr>
  <td class="formLabel"><%= bodyLabel %></td>
  <td><textarea class="formElement" name="body" cols="40" rows="5"><%= body %></textarea></td>
  <td><script type="text/javascript">ipsum('body',6)</script></td>
</tr>
<%

}

%>
<%
//until there are no more elements in the arrayLists ()
for(i=0;i<extraFieldsLabel.size(); i++)
// no more extra fields to display
{
	%>
	<tr>
	  <td class="formLabel"><%= extraFieldsLabel.get(i)%></td>
	  <td>
		<%
		//depending on the type,put input text or textarea
		String typeExtra = ((String) extraFieldsType.get(i));
		columnName = extraFieldsProps.getString("extrafields." + extraFieldsHandle + "." + (i+1) + ".columnName");

		if (typeExtra.equals("textBox"))
		{
			%><input type="text" class="formElement" name="<%=columnName%>" value="<%= extraFieldsContent.get(i) %>" size="53"/><%
		}
		else if (typeExtra.equals("textArea"))
		{
			%><textarea class="formElement" name="<%=columnName%>" cols="40" rows="2"><%= extraFieldsContent.get(i) %></textarea><%
		}
		//if it is a list
		else if (typeExtra.equals("select")) {

		  String dataLabel = extraFieldsProps.getString("extrafields." + extraFieldsHandle + "." + (i+1) + ".data");
		  String dataArray[] = StringUtils.split(dataLabel, "\\.");
		  //supposed to have at least 3 fields when it is select => 0 is table name, 1 is id, 2 is description
		  String dataTable = dataArray[0];
		  String dataSql = "select x." + dataArray[1] + " , x." + dataArray[2] + " from " + dataArray[0] + " x order by x." + dataArray[2];
//                      System.out.println( dataSql );

		  //prepare statement and declare recordset
		  PreparedStatement ps2;
		  ResultSet rs2;
		  ps2 = conn.prepareStatement( dataSql );
		  rs2 = ps2.executeQuery();

		  //declare select
		  //loop through the recordset
		  %>
		  <select name="<%=columnName%>" class="formElement">
		  <%
		  while (rs2.next())
		  {
		    if ( NumberUtils.parseInt( extraFieldsContent.get(i), 0 )== rs2.getInt(dataArray[1]))
		    {
		    %><option selected value="<%= rs2.getInt(dataArray[1])%>"><%= StringUtils.nullString( rs2.getString( dataArray[2] )).trim()%></option><%
		    }
		    else
		    {
		    %><option value="<%= rs2.getInt(dataArray[1])%>"><%=StringUtils.nullString( rs2.getString( dataArray[2] )).trim()%></option><%
		    }
		  }//end while

		  rs2.close();
		  ps2.close();
		  %>
		  </select>
		  <%
		}
		else
		{
		%><span>Field type not recognised</span><%
		}

		%>


	</td>
	</tr>

	<%

}//end for no more extra fields

%>


<tr>
  <td class="formLabel">On Site From</td>
  <td><jsp:include page="/inc/dateSelect.jsp" flush="true" >
      <jsp:param name="nameRoot" value="liveDate"/>
      <jsp:param name="includeBlanks" value="f"/>
    </jsp:include></td>
</tr>

<tr>
  <td class="formLabel">To</td>
  <td><jsp:include page="/inc/dateSelect.jsp" flush="true" >
      <jsp:param name="nameRoot" value="removeDate"/>
      <jsp:param name="includeBlanks" value="t"/>
    </jsp:include> <a href="#" onclick="return blankDate('removeDate')">No Date</a></td>
</tr>

<tr>
  <td colspan="2" class="formButtons"><input type="button" onclick="document.location.href='items.jsp?listTypeId=<%= listTypeId %>'" value="Cancel" class="formButton" /> <input type="submit" value="<%= mode %>" class="formButton" /></td>
</tr>
</table>
</form>
</body>
</html><%

conn.close();

%>