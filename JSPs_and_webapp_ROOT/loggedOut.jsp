<%@ page language="java"
         import="com.extware.utils.BooleanUtils"
%><%
boolean fromPullDown = BooleanUtils.isTrue( request.getParameter( "fromPullDown" ) );
String pageInclude = fromPullDown ? "plslogin1" : "loggedout1";

%><jsp:include page="/inc/pageHead.jsp" flush="true" />
<jsp:include page="/text/text.jsp" flush="true" >
  <jsp:param name="t" value="<%= pageInclude %>"/>
</jsp:include>
<%

if( fromPullDown )
{

%>
<br />
<table cellpadding="0" cellspacing="0" width="100%">
<tr>
  <td nowrap="nowrap"><h6><a href="/pages/registerJoinup.jsp">Tell me more about joining up</a></h6></td>
  <td width="100%"></td>
</tr>
</table>
<%

}

%>
<jsp:include page="/inc/pageFoot.jsp" flush="true" />