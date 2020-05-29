<%@ page language="java"
  import="com.extware.utils.BooleanUtils,
          com.extware.utils.NumberUtils,
          com.extware.utils.StringUtils,
          java.util.GregorianCalendar,
          java.text.SimpleDateFormat"
%><%

String nameRoot = StringUtils.nullReplace( request.getParameter( "nameRoot" ), "date" );
String dayExt   = StringUtils.nullReplace( request.getParameter( "dayExt" ),   "Day" );
String monthExt = StringUtils.nullReplace( request.getParameter( "monthExt" ), "Month" );
String yearExt  = StringUtils.nullReplace( request.getParameter( "yearExt" ),  "Year" );

boolean setDate       = BooleanUtils.parseBoolean( request.getParameter( "setDate" ) );
boolean includeBlanks = BooleanUtils.parseBoolean( request.getParameter( "includeBlanks" ) );

GregorianCalendar todayCal = new GregorianCalendar();

SimpleDateFormat monthName = new SimpleDateFormat( "MMM" );

int minYear = NumberUtils.parseInt( request.getParameter( "minYear" ), todayCal.get( todayCal.YEAR ) - NumberUtils.parseInt( request.getParameter( "befYears" ), 2 ) );
int maxYear = NumberUtils.parseInt( request.getParameter( "maxYear" ), todayCal.get( todayCal.YEAR ) + NumberUtils.parseInt( request.getParameter( "aftYears" ), 2 ) );

int day   = NumberUtils.parseInt( request.getParameter( nameRoot + dayExt ),   -1 );
int month = NumberUtils.parseInt( request.getParameter( nameRoot + monthExt ), -1 );
int year  = NumberUtils.parseInt( request.getParameter( nameRoot + yearExt ),  -1 );

if( day == -1 )
{
  day = todayCal.get( todayCal.DAY_OF_MONTH );
}

if( month == -1 )
{
  month = todayCal.get( todayCal.MONTH );
}

if( year == -1 )
{
  year = todayCal.get( todayCal.YEAR );
}

minYear = Math.min( minYear, year );
maxYear = Math.max( maxYear, year );

%><select name="<%= nameRoot + dayExt %>" class="formElement">
<%

if( includeBlanks )
{

%>  <option></option>
<%

}

for( int d = 1 ; d <= 31 ; d++ )
{

%>  <option<%= ( ( setDate && d == day ) ? " selected=\"selected\"" : "" ) %>><%= d %></option>
<%

}

%></select><select name="<%= nameRoot + monthExt %>" class="formElement">
<%

if( includeBlanks )
{

%>  <option></option>
<%

}

for( int m = 0 ; m <= 11 ; m++ )
{
  todayCal.set( todayCal.MONTH, m );

%>  <option value="<%= ( m + 1 ) %>"<%= ( ( setDate && m == month ) ? " selected=\"selected\"" : "" ) %>><%= monthName.format( todayCal.getTime() ) %></option>
<%

}

%></select><select name="<%= nameRoot + yearExt %>" class="formElement">
<%

if( includeBlanks )
{

%>  <option></option>
<%

}

for( int y = minYear ; y <= maxYear ; y++ )
{

%>  <option<%= ( ( setDate && y == year ) ? " selected=\"selected\"" : "" ) %>><%= y %></option>
<%

}

%></select>