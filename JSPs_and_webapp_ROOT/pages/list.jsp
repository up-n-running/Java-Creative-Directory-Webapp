<%@ page language="java"
  import="com.extware.utils.StringUtils,
          com.extware.utils.NumberUtils"
%><%
  String l = StringUtils.nullString( request.getParameter( "l" ) );
  String includePage = "";
  if( l.length() > 0 )
  {
    includePage = "/lists/" + l + ".jsp";
  }

  int i = NumberUtils.parseInt( request.getParameter( "i" ), -1 );
  if( i != -1 )
  {
    includePage = "/items/" + l + ".jsp";
  }

%><jsp:include page="/inc/pageHead.jsp" flush="true"/>
<jsp:include page="<%= includePage %>" flush="true">
  <jsp:param name="l" value="<%= l %>"/>
  <jsp:param name="i" value="<%= i %>"/>
</jsp:include>
<jsp:include page="/inc/pageFoot.jsp" flush="true"/>