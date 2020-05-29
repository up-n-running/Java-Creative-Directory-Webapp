<%@ page language="java"
  import="com.extware.utils.PropertyFile,
          com.extware.utils.StringUtils"
%><%

PropertyFile dataDictionary = PropertyFile.getDataDictionary();
PropertyFile extSiteProps = new PropertyFile( dataDictionary.getString( "extsite.property.class" ) );

String mainmenuPage = extSiteProps.getString( "dir.includes.mainmenu" ) + "/" + StringUtils.nullReplace( (String)request.getAttribute( "mainmenu" ), "1" ) + ".jsp";

%><jsp:include page="<%= mainmenuPage %>" flush="true" />