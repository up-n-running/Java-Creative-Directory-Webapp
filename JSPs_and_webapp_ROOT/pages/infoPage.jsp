<%@ page language="java"
         import="com.extware.utils.BooleanUtils"
%><%

String pageInclude = request.getParameter( "page" );

%><jsp:include page="/inc/pageHead.jsp" flush="true" />
<jsp:include page="/text/text.jsp" flush="true" >
  <jsp:param name="t" value="<%= pageInclude %>"/>
</jsp:include>
<br />
<%

if( pageInclude.equals( "addinfo" ) )
{

%>
<table cellpadding="0" cellspacing="0" width="100%">
<tr>
  <td nowrap="nowrap"><h6><a href="/pages/advertsEdit.jsp">Show me the advertising options</a></h6></td>
  <td width="100%"></td>
</tr>
</table>
<%

}
else
{

%>
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