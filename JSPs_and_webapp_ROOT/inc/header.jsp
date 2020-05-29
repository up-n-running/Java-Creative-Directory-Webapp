<%@ page language="java"
  import="com.extware.utils.PropertyFile,
          com.extware.utils.StringUtils"
%><%

PropertyFile dataDictionary = PropertyFile.getDataDictionary();
PropertyFile extSiteProps = new PropertyFile( dataDictionary.getString( "extsite.property.class" ) );

String headerPage = extSiteProps.getString( "dir.includes.header" ) + "/" + StringUtils.nullReplace( (String)request.getAttribute( "header" ), "1" ) + ".jsp";

%><jsp:include page="<%= headerPage %>" flush="true" />