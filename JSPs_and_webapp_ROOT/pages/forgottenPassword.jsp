<%@ page language="java"
  import="com.extware.member.Member,
          com.extware.utils.StringUtils"
%><%

String email = StringUtils.nullString( request.getParameter( "email" ) );

%><jsp:include page="/inc/pageHead.jsp" flush="true" />
<jsp:include page="/text/text.jsp" flush="true" >
  <jsp:param name="t" value="forgotpass1"/>
</jsp:include>
<form name="forgtopassword" method="post" action="/pages/forgottenPassword2.jsp">
  <input class="bigFormElement" name="email" type="text" value="<%= email %>" maxlength="200">
  <table cellpadding="0" cellspacing="0" width="100%">
  <tr>
    <td nowrap="nowrap"><h6><a onclick="if( document.forms[ 'forgtopassword' ].email.value != '' ) { document.forms[ 'forgtopassword' ].submit(); } else { alert( 'Please enter you email address inthe box provided.' ); }return false;" href="">Email me my password</a></h6></td>
    <td width="100%"></td>
  </tr>
  </table>
</form>
<jsp:include page="/inc/pageFoot.jsp" flush="true" />