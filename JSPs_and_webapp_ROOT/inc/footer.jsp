<%@ page language="java"
  import="com.extware.utils.PropertyFile,
          com.extware.utils.StringUtils"
%><%

PropertyFile dataDictionary = PropertyFile.getDataDictionary();
PropertyFile extSiteProps = new PropertyFile( dataDictionary.getString( "extsite.property.class" ) );

String footerPage = extSiteProps.getString( "dir.includes.footer" ) + "/" + StringUtils.nullReplace( (String)request.getAttribute( "footer" ), "1" ) + ".jsp";

%><jsp:include page="<%= footerPage %>" flush="true" />