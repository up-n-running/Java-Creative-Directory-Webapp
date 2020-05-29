<%@ page language="java"
  import="com.extware.member.Member"
%><%
//Get logged in user
Member member = (Member)request.getSession().getAttribute( "member" );

//if not logged in, sack them off
if( member==null )
{
  %><jsp:forward page="/loggedOut.jsp" /><%
  return;
}

%><jsp:include page="/inc/pageHead.jsp" flush="true" />
<h1>Delete account</h1>
<img src="/art/filingCabinetDeleted.gif" width="105" height="115" style="float: right;"/>
<jsp:include page="/text/text.jsp" flush="true" >
  <jsp:param name="t" value="deleteaccount"/>
</jsp:include>
<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr>
  <td nowrap="nowrap"><h6><a href="/pages/accountManager.jsp">I've changed my mind, return to account manager</a></h6></td>
  <td width="100%"></td>
</tr>
</table>
<h5>Or</h5>
<form name="deleteaccount" action="/servlet/MemberDetails">
<input type="hidden" name="mode" value="delete" />
<input type="hidden" name="form" value="deleteaccount" />
<input type="hidden" name="redirectto" value="/index.jsp" />
<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr>
<script type="text/javascript">
if( IE )
{
  document.write( '    <td><input class="IECheckBoxCorrection"type="checkbox" name="deleteactivate" value="t" /></td>' );
}
else
{
  document.write( '    <td><input style="margin-left:0px"type="checkbox" name="deleteactivate" value="t" /></td>' );
}
</script>
<noscript>
    <td><input class="IECheckBoxCorrection" type="checkbox" name="deleteactivate" value="t" /></td>
</noscript>

  <td><h5>Tick this box to activate the option below</h5></td>
</tr>
</table>
<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr>
  <td nowrap="nowrap"><h6 class="burgundyh6"><a onclick="theForm = document.forms[ 'deleteaccount' ]; if( !theForm.deleteactivate.checked ) { alert( 'You must activate this link by clicking the checkbox above' ); return false; } theForm.submit(); return false;" href="/servlet/MemberDetails">Delete my account now</a></h6></td>
  <td width="100%"></td>
</tr>
</table>
</form>
<jsp:include page="/inc/pageFoot.jsp" flush="true"/>