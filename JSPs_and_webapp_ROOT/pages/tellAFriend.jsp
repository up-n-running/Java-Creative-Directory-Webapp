<%@ page language="java"
%>
<jsp:include page="/inc/pageHead.jsp" flush="true" />
<jsp:include page="/inc/tellAFriend.jsp" flush="true" >
  <jsp:param name="redirecttoaccman" value="false"/>
  <jsp:param name="bigtitle" value="true"/>
</jsp:include>
<jsp:include page="/inc/pageFoot.jsp" flush="true" />

