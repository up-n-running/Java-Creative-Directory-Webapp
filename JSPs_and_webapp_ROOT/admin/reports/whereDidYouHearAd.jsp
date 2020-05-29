<%@ page language="java"
  import="com.extware.utils.NumberUtils,
          com.extware.utils.BooleanUtils,
          com.extware.utils.DatabaseUtils,
          com.extware.utils.StringUtils,
          com.extware.utils.PropertyFile,
          com.extware.user.UserDetails,
          java.net.URLEncoder,
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

GregorianCalendar fromDate   = getCalendar( request, "fromDate" );
GregorianCalendar toDate     = getCalendar( request, "toDate" );
String magName   = StringUtils.nullString( request.getParameter( "magName" ) ).toUpperCase();
String otherName = StringUtils.nullString( request.getParameter( "otherName" ) ).toUpperCase();

String REPORT_SQL = "SELECT whereDidYouHearRef ref, whereDidYouHearOther other, whereDidYouHearMagazine magazine, count(*) frequency " +
                    "FROM ADVERTS a " +
                    "WHERE   a.paymentDate IS NOT NULL " +
                    ( toDate   == null ? "" : "AND   a.creationDate <= ? " ) +
                    ( fromDate == null ? "" : "AND   a.creationDate >= ? " ) +
                    ( magName.length()   == 0 ? "" : "AND  ( UPPER( a.whereDidYouHearMagazine ) LIKE ? " ) +
                    ( otherName.length() == 0 ? "" : ( magName.length() == 0 ? "AND ( " : "OR" ) + "  UPPER( a.whereDidYouHearOther    ) LIKE ? " ) + ")" +
                    "GROUP BY whereDidYouHearRef, whereDidYouHearOther, whereDidYouHearMagazine " +
                    "ORDER BY 4 DESC ";

boolean reloadMenu = BooleanUtils.parseBoolean( request.getParameter( "reloadMenu" ) );
boolean firstTimeHere = !BooleanUtils.isTrue( request.getParameter( "fromForm" ) );

String errors     = StringUtils.nullString( request.getParameter( "errors" ) ).trim();
String message    = StringUtils.nullString( request.getParameter( "message" ) ).trim();

%><html>
<head>
  <title>Reports</title>
  <link rel="stylesheet" href="/style/admin.css" type="text/css">

<script type="text/javascript" src="/js/dateForm.js"></script>
<script type="text/javascript">
dateElementRoots = new Array( "fromDate", "toDate" );
dateListToSetTo  = new Array();
dateListToSetTo[0] = <%= ( fromDate   != null ) ? ( "new Date(" + ( ( fromDate   != null ) ? " " + fromDate.get( fromDate.YEAR )     + ", " + fromDate.get( fromDate.MONTH )     + ", " + fromDate.get( fromDate.DAY_OF_MONTH )     : "" ) + ")" ) : ( "null" ) %>;
dateListToSetTo[1] = <%= ( toDate     != null || firstTimeHere ) ? ( "new Date(" + ( ( toDate     != null ) ? " " + toDate.get( toDate.YEAR )         + ", " + toDate.get( toDate.MONTH )         + ", " + toDate.get( toDate.DAY_OF_MONTH )         : "" ) + ")" ) : ( "null" ) %>;
</script>

</head>
<body class="adminPane"<%= ( ( reloadMenu ) ? " onload=\"if( typeof( parent.menu ) ) { parent.menu.document.location.reload(); }\"" : "" ) %>>
<form action="whereDidYouHearAd.jsp" method="post">
<input type="hidden" name="fromForm" value="true" />
<table border="0" cellpadding="0" cellspacing="0">
<tr>
  <td colspan="5" class="title">Advertisers Where Did You hear About Us Report</td>
</tr>
<tr>
  <td class="formLabel">Advert Uploaded Between</td>
  <td><jsp:include page="/inc/dateSelect.jsp" flush="true" >
      <jsp:param name="nameRoot" value="fromDate"/>
      <jsp:param name="includeBlanks" value="t"/>
    </jsp:include> <a href="#" onclick="return blankDate('fromDate')">No Date</a></td>
</tr>

<tr>
  <td class="formLabel">And</td>
  <td><jsp:include page="/inc/dateSelect.jsp" flush="true" >
      <jsp:param name="nameRoot" value="toDate"/>
      <jsp:param name="includeBlanks" value="t"/>
    </jsp:include> <a href="#" onclick="return blankDate('toDate')">No Date</a></td>
</tr>
<tr>
  <td class="formLabel" style="padding-top: 5px">Magazine Filter</td>
  <td style="padding-top: 5px"><input type="text" class="formElement" name="magName" value="<%= magName %>" /></td>
</tr>
<tr>
  <td class="formLabel">Other Filter</td>
  <td><input type="text" class="formElement" name="otherName" value="<%= otherName %>" /></td>
</tr>
<tr>
<td colspan="2" align="right"><br /><input type="submit" value="Run Report" class="formButton" /></td>
</tr>
</table>
</form>

<%

if( !firstTimeHere )
{
%><table cellspacing="0" cellpadding="0">
<%
  Connection conn = DatabaseUtils.getDatabaseConnection();
  PreparedStatement ps;
  ResultSet rs;

  ps = conn.prepareStatement( REPORT_SQL );
  int colCount = 1;
  if( toDate != null )
  {
    ps.setDate( colCount++, new java.sql.Date( toDate.getTime().getTime() ) );
  }
  if( fromDate != null )
  {
    ps.setDate( colCount++, new java.sql.Date( fromDate.getTime().getTime() ) );
  }
  if( magName.length() > 0 )
  {
    ps.setString( colCount++, "%" + magName + "%" );
  }
  if( otherName.length() > 0 )
  {
    ps.setString( colCount++, "%" + otherName + "%" );
  }

  rs = ps.executeQuery();

  PropertyFile ddProps = new PropertyFile( "com.extware.properties.DropDowns" );
  String refDescription;
  String other;
  String magazine;
  int frequency;
  int count = 0;

  while( rs.next() )
  {
    if( count++ == 0 )
    {
%><tr>
  <td class="listHead">Where Did You Hear About Us?</td>
  <td colspan="3" class="listHead">Frequency</td>
</tr>
<%
    }

    refDescription = ddProps.getString( "wheredidyouhearref." + rs.getInt( "ref" ) );
    other          = rs.getString( "other" );
    magazine       = rs.getString( "magazine" );
    frequency      = rs.getInt( "frequency" );

%><tr>
  <td class="listLine<%= ( count % 2 ) %>"><%= refDescription %><%= magazine == null ? "" : ": "  + magazine %><%= other == null ? "" : ": "  + other %></td>
  <td class="listLine<%= ( count % 2 ) %>"><%= frequency %></td>
</tr>
<%
  }

  if( count == 0 )
  {
%>
<tr>
  <td class="listLine<%= ( count % 2 ) %>">No results matched</td>
</tr>
<%
  }

  rs.close();
  ps.close();
  conn.close();
%></table>
<%
}
%>

</html>




