<%
request.getSession().setAttribute( "inworldpay", "true" );
%>
<jsp:include page="/inc/pageHead.jsp" flush="true">
  <jsp:param name="wideForWorldpay" value="true" />
</jsp:include>
<iframe src="/pages/worldpay/membersToFrame.jsp<%= request.getParameter( "first" ) == null ? "" : "?first=true" %>" width="430" height="1050" border=0" frameborder="0" ></iframe>
<jsp:include page="/inc/pageFoot.jsp" flush="true">
  <jsp:param name="wideForWorldpay" value="true" />
</jsp:include>
