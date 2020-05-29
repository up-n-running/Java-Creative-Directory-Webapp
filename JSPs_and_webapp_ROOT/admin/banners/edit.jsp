<%@ page language="java"
  import="com.extware.extsite.banners.Banner,
          com.extware.utils.DatabaseUtils,
          com.extware.utils.NumberUtils,
          com.extware.utils.PropertyFile,
          com.extware.utils.StringUtils,
          com.extware.user.UserDetails,
          java.net.URLEncoder,
          java.sql.Connection,
          java.sql.PreparedStatement,
          java.sql.ResultSet,
          java.util.Date,
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

String SELECT_BANNER_TYPES_SQL = "SELECT bannerTypeId, bannerTypeName, displayWidth, displayHeight FROM bannerTypes ORDER BY bannerTypeName";
String SELECT_BANNER_SQL       = "SELECT bannerTypeId, bannerName, linkUrl, assetId, dateLive, dateRemove FROM banners WHERE bannerId=?";

int displayWidth;
int displayHeight;
int thisBannerTypeId;
int bannerId         = NumberUtils.parseInt( request.getParameter( "bannerId" ),     -1 );
int bannerTypeId     = NumberUtils.parseInt( request.getParameter( "bannerTypeId" ), -1 );
int assetId          = NumberUtils.parseInt( request.getParameter( "assetId" ),      -1 );

String assetsFolder;
String bannerTypeName;
String mode           = "Edit";
String errors         = StringUtils.nullString( request.getParameter( "errors" ) ).trim();
String message        = StringUtils.nullString( request.getParameter( "message" ) ).trim();
String bannerName     = StringUtils.nullString( request.getParameter( "bannerName" ) ).trim();
String linkUrl        = StringUtils.nullString( request.getParameter( "linkUrl" ) ).trim();

GregorianCalendar dateLive   = getCalendar( request, "dateLive" );
GregorianCalendar dateRemove = getCalendar( request, "dateRemove" );

PropertyFile dataDictionary = PropertyFile.getDataDictionary();

Banner banner = null;

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

if( bannerId != -1 )
{
  banner = Banner.getBanner( conn, bannerId );

  if( banner != null )
  {
    bannerTypeId = banner.bannerTypeId;
    bannerName   = banner.bannerName;
    linkUrl      = banner.linkUrl;
    assetId      = banner.assetId;
    dateLive     = setCalendar( banner.dateLive );
    dateRemove   = setCalendar( banner.dateRemove );
  }
}
else
{
  mode = "Add";
}

%><html>
<head>
  <title>List Admin</title>
  <link rel="stylesheet" href="/style/admin.css" type="text/css">
<script type="text/javascript" src="/js/dateForm.js"></script>
<script type="text/javascript">
dateElementRoots = new Array( "dateLive", "dateRemove" );
dateListToSetTo  = new Array();
dateListToSetTo[0] = <%= ( ( dateLive   != null || mode.equals( "Add" ) ) ? "new Date(" + ( ( dateLive   != null ) ? " " + dateLive.get( dateLive.YEAR )     + ", " + dateLive.get( dateLive.MONTH )     + ", " + dateLive.get( dateLive.DAY_OF_MONTH )     : "" ) + ")" : "null" ) %>;
dateListToSetTo[1] = <%= ( ( dateRemove != null || mode.equals( "Add" ) ) ? "new Date(" + ( ( dateRemove != null ) ? " " + dateRemove.get( dateRemove.YEAR ) + ", " + dateRemove.get( dateRemove.MONTH ) + ", " + dateRemove.get( dateRemove.DAY_OF_MONTH ) : "" ) + ")" : "null" ) %>;
</script>
</head>
<body class="adminPane">
<form action="database.jsp" method="post" enctype="multipart/form-data">
<input type="hidden" name="bannerId" value="<%= bannerId %>" />
<input type="hidden" name="assetId" value="<%= assetId %>" />
<input type="hidden" name="mode" value="<%= mode.toLowerCase() %>" />
<table border="0" cellpadding="0" cellpadding="0">
<tr>
  <td colspan="3" class="title"><%= mode %> a Banner</td>
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
  <td class="formLabel">Banner Name</td>
  <td colspan="2"><input type="text" name="bannerName" value="<%= bannerName %>" class="formElement" /></td>
</tr>

<tr>
  <td class="formLabel">Url</td>
  <td colspan="2"><input type="text" name="linkUrl" value="<%= linkUrl %>" class="formElement" /></td>
</tr>

<tr>
  <td class="formLabel">Banner Type</td>
  <td><select name="bannerTypeId" class="formElement">
<%

ps = conn.prepareStatement( SELECT_BANNER_TYPES_SQL );
rs = ps.executeQuery();

while( rs.next() )
{
  thisBannerTypeId = rs.getInt(    "bannerTypeId" );
  bannerTypeName   = rs.getString( "bannerTypeName" );
  displayWidth     = rs.getInt(    "displayWidth" );
  displayHeight    = rs.getInt(    "displayHeight" );

%>      <option value="<%= thisBannerTypeId %>"<%= ( ( thisBannerTypeId == bannerTypeId || ( bannerTypeId == -1 && bannerTypeName.toLowerCase().equals( "full banner" ) ) ) ? " selected=\"selected\"" : "" ) %>><%= bannerTypeName %> (<%= displayWidth %>x<%= displayHeight %>)</option>
<%

}

rs.close();
ps.close();

%>
    </select></td>
</tr>

<tr>
  <td class="formLabel">File</td>
  <td><input type="file" name="file" class="formElement" size="30" /></td>
</tr>

<tr>
  <td class="formLabel">On Site From</td>
  <td><jsp:include page="/inc/dateSelect.jsp" flush="true" >
      <jsp:param name="nameRoot" value="dateLive"/>
      <jsp:param name="includeBlanks" value="f"/>
    </jsp:include></td>
</tr>

<tr>
  <td class="formLabel">To</td>
  <td><jsp:include page="/inc/dateSelect.jsp" flush="true" >
      <jsp:param name="nameRoot" value="dateRemove"/>
      <jsp:param name="includeBlanks" value="t"/>
    </jsp:include> <a href="#" onclick="return blankDate('dateRemove')">No Date</a></td>
</tr>

<tr>
  <td colspan="3" class="formButtons"><input type="button" onclick="document.location.href='index.jsp'" value="Cancel" class="formButton" /> <input type="submit" value="<%= mode %>" class="formButton" /></td>
</tr>

<tr>
  <td></td>
  <td><%

if( banner != null )
{
  out.println( banner.getHtml() );
}
else
{
  out.print( "Null Banner" );
}

%></td>

</tr>

</table>
</form>
</body>
</html><%

conn.close();

%>