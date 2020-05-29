<%@ page language="java"
  import="com.extware.utils.StringUtils,
          com.extware.utils.CookieUtils,
          com.extware.utils.DatabaseUtils,
          java.net.URLDecoder,
          java.net.URLEncoder,
          java.sql.Connection,
          java.sql.ResultSet,
          java.sql.ResultSetMetaData,
          java.sql.PreparedStatement,
          java.sql.SQLException,
          java.util.StringTokenizer"
%><%!

String getParamOrCookie( HttpServletRequest request, HttpServletResponse response, CookieUtils cookies, String name )
{
  String value = "";

  try
  {
    value = ( request.getParameter( name ) != null ) ? request.getParameter( name ) : URLDecoder.decode( StringUtils.nullString( cookies.getCookieVal( name ) ) );
    response.addCookie( cookies.createCookie( name, URLEncoder.encode( value ), 60 * 60 * 24 * 365 ) );
  }
  catch( Exception ex )
  {
  }

  return value;
}

%><%

CookieUtils cookies = new CookieUtils( request.getCookies() );

String sql01     = getParamOrCookie( request, response, cookies, "sql01" );
String sql01rows = getParamOrCookie( request, response, cookies, "sql01rows" );

String sql02     = getParamOrCookie( request, response, cookies, "sql02" );
String sql02rows = getParamOrCookie( request, response, cookies, "sql02rows" );

String sql03     = getParamOrCookie( request, response, cookies, "sql03" );
String sql03rows = getParamOrCookie( request, response, cookies, "sql03rows" );

String sql04     = getParamOrCookie( request, response, cookies, "sql04" );
String sql04rows = getParamOrCookie( request, response, cookies, "sql04rows" );

String sql05     = getParamOrCookie( request, response, cookies, "sql05" );
String sql05rows = getParamOrCookie( request, response, cookies, "sql05rows" );

%>
<html>
<head>
  <title>extWare : Admin - SQL Editor</title>
<style>
body     { background-color:#ffffff; color:#000000; }
td       { font-family:arial; font-size:8pt; vertical-align:top }
textarea { font-family:courier; font-size:8pt }
.border  { background-color:#666666 }
.form    { background-color:#eeeeee }
.desc    { background-color:#eeeeee }
.text    { background-color:#cccccc }
.col     { background-color:#cccccc }
.data    { background-color:#ffffcc }
</style>
</head>
<body>
<center>
<%

try
{
  Connection conn = null;
  conn = DatabaseUtils.getDatabaseConnection();

%>
<%= conn.getMetaData().getURL() %>
<form name="f1" method="post">
<input type="hidden" name="sql" value="">
<input type="hidden" name="maxrows" value="">
<table border="0" cellpadding="1" cellspacing="0">

<tr>
  <td class="border" colspan="2">
    <table border="0" cellpadding="2" cellspacing="1">
    <tr>
      <td rowspan="2" class="form">sql0<br>
        <textarea name="sql01" cols="28" rows="10"><%= sql01 %></textarea><br>
        max rows <input type="text" size="3" name="sql01rows" value="<%= sql01rows %>">
        <input type="submit" onclick="document.f1.sql.value=document.f1.sql01.value;document.f1.maxrows.value=document.f1.sql01rows.value" class="button" value="run"><input type="button" onclick="document.f1.sql01.value=''" value="clear"><br>
        <input type="button" value="get1" onclick="document.f1.sql01.value=document.f1.sql02.value;document.f1.sql01rows.value=document.f1.sql02rows.value"><input type="button" value="put1" onclick="document.f1.sql02.value=document.f1.sql01.value;document.f1.sql02rows.value=document.f1.sql01rows.value">
        <input type="button" value="get2" onclick="document.f1.sql01.value=document.f1.sql03.value;document.f1.sql01rows.value=document.f1.sql03rows.value"><input type="button" value="put2" onclick="document.f1.sql03.value=document.f1.sql01.value;document.f1.sql03rows.value=document.f1.sql01rows.value"><br>
        <input type="button" value="get3" onclick="document.f1.sql01.value=document.f1.sql04.value;document.f1.sql01rows.value=document.f1.sql04rows.value"><input type="button" value="put3" onclick="document.f1.sql04.value=document.f1.sql01.value;document.f1.sql04rows.value=document.f1.sql01rows.value">
        <input type="button" value="get4" onclick="document.f1.sql01.value=document.f1.sql05.value;document.f1.sql01rows.value=document.f1.sql05rows.value"><input type="button" value="put4" onclick="document.f1.sql05.value=document.f1.sql01.value;document.f1.sql05rows.value=document.f1.sql01rows.value">
        <br>
        <select name="describe" onchange="document.f1.submit()">
          <option value="">Describe Table</option>
<%

  try
  {
    ResultSet rs = conn.getMetaData().getTables( null, null, null, new String[] { "TABLE" } );

    while( rs.next() )
    {

%>          <option><%= rs.getString( "TABLE_NAME" ) %></option>
<%

    }
  }
  catch( Exception ex )
  {

%>          <option><%= ex %></option>
<%

  }

%>
        </select><br>
      </td>
      <td class="form">sql1<br>
        <textarea name="sql02" cols="18" rows="5"><%= sql02 %></textarea><br>
        max rows <input type="text" size="3" name="sql02rows" value="<%= sql02rows %>">
        <input type="submit" onclick="document.f1.sql.value=document.f1.sql02.value;document.f1.maxrows.value=document.f1.sql02rows.value" class="button" value="run"><input type="button" onclick="document.f1.sql02.value=''" value="clear">
      </td>
      <td class="form">sql2<br>
        <textarea name="sql03" cols="18" rows="5"><%= sql03 %></textarea><br>
        max rows <input type="text" size="3" name="sql03rows" value="<%= sql03rows %>">
        <input type="submit" onclick="document.f1.sql.value=document.f1.sql03.value;document.f1.maxrows.value=document.f1.sql03rows.value" class="button" value="run"><input type="button" onclick="document.f1.sql03.value=''" value="clear">
      </td>
    </tr>
    <tr>
      <td class="form">sql3<br>
        <textarea name="sql04" cols="18" rows="5"><%= sql04 %></textarea><br>
        max rows <input type="text" size="3" name="sql04rows" value="<%= sql04rows %>">
        <input type="submit" onclick="document.f1.sql.value=document.f1.sql04.value;document.f1.maxrows.value=document.f1.sql04rows.value" class="button" value="run"><input type="button" onclick="document.f1.sql04.value=''" value="clear">
      </td>
      <td class="form">sql4<br>
        <textarea name="sql05" cols="18" rows="5"><%= sql05 %></textarea><br>
        max rows <input type="text" size="3" name="sql05rows" value="<%= sql05rows %>">
        <input type="submit" onclick="document.f1.sql.value=document.f1.sql05.value;document.f1.maxrows.value=document.f1.sql05rows.value" class="button" value="run"><input type="button" onclick="document.f1.sql05.value=''" value="clear">
      </td>
    </tr>
    </table>
  </td>
</tr>
</table>
<br>
<%

  String describe = ( request.getParameter( "describe" ) != null && !request.getParameter( "describe" ).equals( "" ) ) ? request.getParameter( "describe" ) : null;

  if( describe != null )
  {

%>
<br>
<table border="0" cellpadding="1" cellspacing="0">
<tr>
  <td class="border">
    <table border="0" cellpadding="2" cellspacing="1">
    <tr>
      <td class="desc" colspan="3">Describe table <%= describe %></td>
    </tr>
    <tr>
      <td class="col"><b>column name</b></td>
      <td class="col"><b>format</b></td>
      <td class="col"><b>nulls</b></td>
    </tr>
<%

    try
    {
      ResultSet rs = conn.getMetaData().getColumns( null, null, describe, null );

      while( rs.next() )
      {

%>
    <tr>
      <td class="data"><%= rs.getString( "COLUMN_NAME" ) %></td>
      <td class="data"><%= rs.getString( "TYPE_NAME" ) %>(<%= rs.getString( "COLUMN_SIZE" ) %>)</td>
      <td class="data"><%= rs.getString( "IS_NULLABLE" ) %></td>
    </tr>
<%

      }
    }
    catch( Exception ex )
    {

%>
    <tr>
      <td><%= ex %></td>
    </tr>
<%

    }

%>
    </table>
  </td>
</tr>
</table>
<%

  }

  String sql = ( request.getParameter( "sql" ) != null && !request.getParameter( "sql" ).equals( "" ) ) ? request.getParameter( "sql" ) : null;
  int maxrows = 0;

  try
  {
    maxrows = Integer.parseInt( request.getParameter( "maxrows" ) );
  }
  catch( Exception ex )
  {
  }

  if( sql != null )
  {
    StringTokenizer s = new StringTokenizer( sql, ";" );

    while( s.hasMoreTokens() )
    {
      String this2run = s.nextToken().trim();

      if( !this2run.equals( "" ) )
      {

%>
<br>
<table border="0" cellpadding="1" cellspacing="0">
<tr>
  <td class="border">
    <table border="0" cellpadding="2" cellspacing="1">
<%

        boolean posSelect = this2run.regionMatches( true, 0, "select", 0, 6 );

        if( posSelect )
        {
          ResultSet rs = null;
          int cols = 0;

          try
          {
            if( maxrows == 0 )
            {
              PreparedStatement ps = conn.prepareStatement( this2run );
              rs = ps.executeQuery();
            }
            else
            {
              PreparedStatement ps = conn.prepareStatement( this2run );
              ps.setMaxRows( maxrows );
              rs = ps.executeQuery();
            }

            ResultSetMetaData rsMeta = rs.getMetaData();
            cols = rsMeta.getColumnCount();

%>
    <tr>
      <td colspan="<%= cols %>" class="desc"><%= this2run %></td>
    </tr>
    <tr>
<%

            for( int i = 1 ; i <= cols ; i++ )
            {

%>
      <td class="col"><%= rsMeta.getColumnLabel( i ) %></td>
<%

            }

%>
    </tr>
<%

            while( rs.next() )
            {

%>
    <tr>
<%

              for( int i = 1 ; i <= cols ; i++ )
              {

%>
      <td class="data"><%= rs.getString( i ) %>&nbsp;</td>
<%

              }

%>
    </tr>
<%

            }
          }
          catch( Exception ex )
          {

%>
    <tr>
      <td colspan="<%= cols %>" class="desc"><%= this2run %></td>
     </tr>
    <tr>
      <td class="text" colspan="<%= cols %>"><%= ex %></td>
    </tr>
<%

          }
        }
        else
        {
          try
          {
            PreparedStatement ps = conn.prepareStatement( this2run );
            int effect = ps.executeUpdate();

%>
    <tr>
      <td class="desc"><%= this2run %></td>
    </tr>
    <tr>
      <td class="text"><%= effect %> rows effected</td>
    </tr>
<%

          }
          catch( Exception ex )
          {

%>
    <tr>
      <td class="desc"><%= this2run %></td>
    </tr>
    <tr>
      <td class="text"><%= ex.getClass().getName() %><br /><%= ( ( ex instanceof java.sql.SQLException ) ? ( (SQLException)ex ).getSQLState() + "<br />" + ( (SQLException)ex ).getErrorCode() + "<br />" : "" ) %><%= ex %></td>
    </tr>
<%

          }
        }

%>
    </table>
  </td>
</tr>
</table>
<%

      }
    }
  }

  conn.close();
}
catch( Exception ex )
{

%>Exception : <%= ex %><br><%

}
catch( Error err )
{

%>Error : <%= err %><br><%

}

%>
</center>
</body>
</html>