<%@ page language="java"
  import="com.extware.utils.StringUtils"
%><%

String nameRoot = StringUtils.nullReplace( request.getParameter( "nameRoot" ), "date" );

String fromName = nameRoot + StringUtils.nullReplace( request.getParameter( "fromExt" ), "From" );
String toName   = nameRoot + StringUtils.nullReplace( request.getParameter( "toExt" ),   "To" );

String fromLabel = StringUtils.nullReplace( request.getParameter( "fromLab" ), "from " );
String toLabel   = StringUtils.nullReplace( request.getParameter( "toLab" ),   " to " );

%><%= fromLabel %><jsp:include page="/inc/dateSelect.jsp" flush="true" >
  <jsp:param name="nameRoot" value="<%= fromName %>"/>
</jsp:include><%= toLabel %><jsp:include page="/inc/dateSelect.jsp" flush="true" >
  <jsp:param name="nameRoot" value="<%= toName %>"/>
</jsp:include>