<%@ page language="java"
  import="com.extware.utils.PropertyFile,
          com.extware.utils.StringUtils"
%><%

PropertyFile dataDictionary = PropertyFile.getDataDictionary();
PropertyFile extSiteProps = new PropertyFile( dataDictionary.getString( "extsite.property.class" ) );

String submenu     = StringUtils.nullReplace( (String)request.getAttribute( "submenu" ), "1" );

if( !submenu.equals( "0" ) )
{
  String submenuPage = extSiteProps.getString( "dir.includes.submenu" ) + "/" + submenu + ".jsp";

%><jsp:include page="<%= submenuPage %>" flush="true" /><%

}

%>