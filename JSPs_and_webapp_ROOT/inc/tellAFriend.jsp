<%@ page language="java"
  import="com.extware.utils.BooleanUtils,
          com.extware.utils.PropertyFile"
%><%
PropertyFile dataDictionary = PropertyFile.getDataDictionary();
String hostUrl = "http://" + dataDictionary.getString( "hostUrl" );
boolean bigTitle = BooleanUtils.isTrue( request.getParameter( "bigtitle" ) );

if( bigTitle )
{

%><div class="h1style">Tell a friend about Nextface</div><%

}
else
{

%><h4>Tell a friend about Nextface!</h4><%

}

%>
<jsp:include page="/text/text.jsp" flush="true" >
  <jsp:param name="t" value="tellafriend"/>
</jsp:include>
<br />
<script type="text/javascript">
function focusField( inpt, text )
{
  if( inpt.value==text )
    inpt.value='';
}
function blurField( inpt, text )
{
  if( inpt.value=='' )
    inpt.value=text;
}
</script>

<form name="tellafriend" method="post" target="_parent" action="<%= hostUrl %>/pages/toldAFriend.jsp">
  <input type="hidden" name="form" value="tellafriend">
<%

if( BooleanUtils.parseBoolean( request.getParameter( "redirecttoaccman" ) ) )
{

%>  <input type="hidden" name="redirectto" value="accountman">
<%

}

%>  <input class="bigFormElement" type="text" name="email1" maxlength="200" onfocus="focusField( this, 'Type email address here' );" onblur="blurField( this, 'Type email address here' );" value="Type email address here" /><br /><br />
  <input class="bigFormElement" type="text" name="email2" maxlength="200" onfocus="focusField( this, 'Type second email address here' );" onblur="blurField( this, 'Type second email address here' );" value="Type second email address here" /><br /><br />
  <input class="bigFormElement" type="text" name="email2" maxlength="200" onfocus="focusField( this, 'Type third email address here' );" onblur="blurField( this, 'Type third email address here' );" value="Type third email address here" /><br /><br />
  <table cellpadding="0" cellspacing="0"><tr><td nowrap="nowrap"><a onclick="document.forms[ 'tellafriend' ].submit();return false;" href="<%= hostUrl %>/pages/toldAFriend.jsp"><h6>Send emails</h6></a></td><td width="100%"></td></tr></table>
</form>
