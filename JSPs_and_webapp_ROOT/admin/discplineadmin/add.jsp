<%@ page language="java"
  import="com.extware.utils.BooleanUtils,
          com.extware.utils.StringUtils,
          com.extware.utils.PropertyFile,
          com.extware.user.UserDetails,
	  java.util.ArrayList,
	  java.util.Collections"
%><%!
String getQuery( String tableName, String catColumn, int catNumber, String discColumn, int discNumber )
{
  String query = "UPDATE " + tableName + " <br />SET " + discColumn + " = " + discColumn + " + 1 <br />WHERE " + catColumn + " = " + catNumber + " <br />AND " + discColumn + " >= " + discNumber + ";<br />";
  return query;
}
%>
<%

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

int categoryRef = request.getParameter( "categoryref" ) == null ? -1 : StringUtils.parseInt( request.getParameter( "categoryref" ), -1 );
String disciplineName = request.getParameter( "disciplinename" ) == null ? "" : request.getParameter( "disciplinename" );


boolean reloadMenu = BooleanUtils.parseBoolean( request.getParameter( "reloadMenu" ) );


%><html>
<head>
  <title>Discipline Admin</title>
  <link rel="stylesheet" href="/style/admin.css" type="text/css">
</head>
<body class="adminPane"<%= ( ( reloadMenu ) ? " onload=\"if( typeof( parent.menu ) ) { parent.menu.document.location.reload(); }\"" : "" ) %>>
<form name="disciplineadmin" action="add.jsp" method="post">
<input type="hidden" name="fromForm" value="true" />
<table border="0" cellpadding="0" cellspacing="0">
<tr>
  <td colspan="5" class="title">Add discipline help</td>
</tr>
<tr>
<jsp:include page="/inc/dropdown.jsp" flush="true" >
  <jsp:param name="formname" value="disciplineadmin"/>
  <jsp:param name="dropdownlabel" value="Add to which category"/>
  <jsp:param name="dropdownname"  value="categoryref"/>
  <jsp:param name="dropdowngroup"  value="categoryref"/>
  <jsp:param name="dropdownvalue" value="<%= categoryRef %>"/>
</jsp:include>
</td>
</tr>
<tr>
  <td class="formLabel" style="padding-top: 6px">New Discipline Name (should begin with upper-case letter)</td>
  <td style="padding-top: 6px"><input class="formElement" name="disciplinename" type="text" value="<%= disciplineName %>" maxlength="200"></td>
</tr>
<tr>
  <td colspan="2"><input class="formElement" type="submit" value="Get instructions" maxlength="200"></td>
</tr>
</table>
</form>

<%

if( categoryRef != -1 && disciplineName != null && disciplineName.length() > 0 )
{

  PropertyFile dropDownProps = new PropertyFile( "com.extware.properties.DropDowns" );
  int discRef = 0;
  boolean foundDiscId = false;
  String desc = "";
  while( !foundDiscId && desc != null )
  {
    discRef++;
    desc = dropDownProps.getString( "disciplineref." + categoryRef + "." + discRef );
    if( desc != null )
    {
      ArrayList temp = new ArrayList();
      temp.add( desc );
      temp.add( disciplineName );
      Collections.sort( temp );
      if( temp.get( 0 ).equals( disciplineName ) )
      {
        foundDiscId = true;
      }
    }
  }




%>
<p><b>Run the following queries:</b></p>
<p><%= getQuery( "memberContacts", "primaryCategoryRef", categoryRef, "primaryDisciplineRef", discRef ) %></p>
<p><%= getQuery( "memberContacts", "secondaryCategoryRef", categoryRef, "secondaryDisciplineRef", discRef ) %></p>
<p><%= getQuery( "memberContacts", "tertiaryCategoryRef", categoryRef, "tertiaryDisciplineRef", discRef ) %></p>
<p>
  <br /><b>Add the following line to DropDowns.properties (and renumber lines after accordingly):</b>
  <br />
  <%= "disciplineref." + categoryRef + "." + discRef + " = " + disciplineName %>
  </p>
<p>
  <br />
  <b>Open /js/srchNBrowz.js and find the line beginning:</b>
  <br />
  disciplineSrc[ '<%= categoryRef %>' ] = new Array(
  <br />
  <b>And add:</b>
  <br />
  '<%= disciplineName %>'
  <br />
<%
  if( discRef==1 )
  {
%>  <b>at the start of the array.</b>
<%
  }
  else
  {
%>  <b>after:</b>
  <br />
  '<%= dropDownProps.getString( "disciplineref." + categoryRef + "." + ( discRef-1) ) %>'
<%
  }
%>
</p>
</p><br /><b>The End</b></p>
<%
}
%>
</html>




