<%@ page language="java"
  import="com.extware.member.Member,
          com.extware.member.MemberContact,
          com.extware.utils.StringUtils,
          java.util.ArrayList,
          com.extware.utils.PropertyFile"
%><%
//Get logged in user if there is a user logged in
Member loggedInMember = (Member)request.getSession().getAttribute( "member" );
MemberContact formPopulateMemberContact = loggedInMember == null ? null : ( loggedInMember.memberContact == null ? loggedInMember.moderationMemberContact : loggedInMember.memberContact );

PropertyFile dataDictionary = PropertyFile.getDataDictionary();
String adminEmail = dataDictionary.getString( "admin.email" );

String pageInclude = "contactus";
boolean isNews = StringUtils.nullString( request.getParameter( "type" ) ).equals( "news" );
if( isNews )
{
  pageInclude = "contactnews";
}

%><jsp:include page="/inc/pageHead.jsp" flush="true" />
<jsp:include page="/text/text.jsp" flush="true" >
  <jsp:param name="t" value="<%= pageInclude %>"/>
</jsp:include>
<br />
<h5 class="emphasiseColor">Your contact details</h5>

<form name="contactus" action="/cgi-bin/mailto.pl" method="post">
<input type="hidden" name="MAILTO" value="<%= adminEmail %>"/>
<input type="hidden" name="SUBJECT" value="Nextface:"/>
<input type="hidden" name="EMAIL" value="Email"/>
<input type="hidden" name="REPLY" value="/pages/contactUsThanks.jsp"/>

<table width="100%" border="0" cellspacing="0" cellpadding="0" class="formTable">
<tr>
  <td class="formLabel">Your first name</td>
  <td class="formElementCell"><input class="formElement" name="First_Name" type="text" value="<%= formPopulateMemberContact==null ? "" : formPopulateMemberContact.contactFirstName %>" maxlength="200"></td>
</tr>
<tr>
  <td class="formLabel">Your second name</td>
  <td class="formElementCell"><input class="formElement" name="Second_Name" type="text" value="<%= formPopulateMemberContact==null ? "" : formPopulateMemberContact.contactSurname %>" maxlength="200"></td>
</tr>
<tr>
  <td class="formLabel">Your email address</td>
  <td class="formElementCell"><input class="formElement" name="Email" type="text" value="<%= loggedInMember==null ? "" : loggedInMember.email %>" maxlength="200"></td>
</tr>
</table>

<br />
<h5 class="emphasiseColor">Send us your message</h5>

  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="formTable">
  <tr>
    <td class="formLabel">Nature of your message</td>
    <td class="formElementCell">
      <select class="formElement" name="Type_Of_Message">
        <option <%= isNews ? "" : "selected=\"selected\" " %>value="none">Please select type</option>
        <option value="Suggestion">A suggestion</option>
        <option value="Complaint">A complaint</option>
        <option value="Enquiry">An enquiry</option>
        <option <%= isNews ? "selected=\"selected\" " : "" %>value="News_Article">Submit a news article</option>
      </select>
    </td>
  </tr>
  <tr>
    <td class="formLabel">Message title</td>
    <td class="formElementCell"><input class="formElement" name="Message_Title" type="text" value="" maxlength="200"></td>
  </tr>
  </table>
<br />
<h5 class="emphasiseColor">Type your message here</h5>
  <textarea class="bigFormElement" name="Message_Body" maxlength="2000" rows="5"></textarea><br />
<br />
<jsp:include page="/inc/tasteAndTermsInclude.jsp" flush="true" />
<br >
<p>Please allow 24 hours for a reply to this message</p>
<table cellpadding="0" cellspacing="0" width="100%"><tr><td nowrap="nowrap"><h6><a onclick="if( tAndTCheck() ) { theform = document.forms[ 'contactus' ]; theform.SUBJECT.value = 'Nextface Site: ' + theform.Type_Of_Message.value + ': ' + theform.Message_Title.value; theform.submit(); } return false;" href="">Submit this message</a></h6></td><td width="100%"></td></tr></table>
</form>
<jsp:include page="/inc/pageFoot.jsp" flush="true" />
