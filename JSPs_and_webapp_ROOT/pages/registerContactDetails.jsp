<%@ page language="java"
  import="java.util.ArrayList,
          com.extware.member.Member,
          com.extware.member.MemberContact"
%><%
String mode=request.getParameter( "mode" );

Member loggedInMember = null;
Member formPopulateMember = null;
MemberContact formPopulateMemberContact = null;

//where are we going to redirect to on form submission - default to profile form
//String redirectTo = "/pages/registerPayment.jsp";
//changed for march only
String redirectTo = "/pages/registerProfileDetails.jsp?mode=edit";

if( request.getParameter( "divertto" )!=null && request.getParameter( "divertto" ).equals( "accountman" ) )
{
  redirectTo = "/pages/accountManager.jsp";
}

//if we are coming back from reg servlet with errors
ArrayList errorsToReport = (ArrayList)request.getAttribute( "errors" );

if( errorsToReport != null && errorsToReport.size() > 0 )
{
  formPopulateMember = (Member)request.getAttribute( "formmember" );
  formPopulateMemberContact = (MemberContact)request.getAttribute( "formmembercontact" );
}
else
{
  //so we're coming to the form for the first time, so if adding, we need a blank form, otherwise we need to edit the currently logged in user
  if( mode.equals( "edit" ) )
  {
    loggedInMember = (Member)request.getSession().getAttribute( "member" );

    if( loggedInMember==null )
    {
      %><jsp:forward page="/loggedOut.jsp" /><%
      return;
    }

    formPopulateMember = loggedInMember;
    formPopulateMemberContact = loggedInMember.moderationMemberContact!=null ? loggedInMember.moderationMemberContact : loggedInMember.memberContact;
  }
}

//temp variables needed to fill jsp params
String v = null;
String c1v = null;
String c2v = null;
String c3v = null;
String o1 = null;
String o2 = null;

%><jsp:include page="/inc/pageHead.jsp" flush="true" />
<jsp:include page="/text/text.jsp" flush="true" >
  <jsp:param name="t" value="regcontact1"/>
</jsp:include>
<%

//if we are returning from reg servlet with errors
if( errorsToReport != null )
{

%>
<p>There were some problems with the data you entered, please address the issues listed below and try again.<p>
<%

  for( int i=0; i<errorsToReport.size(); i++ )
  {
%><p class="error"><%= (String)errorsToReport.get( i ) %></p>
<%

  }

}
else
{

%>
<h5 class="emphasiseColor">Add or edit your personal details</h5>
<%

}

%>
<form name="registercontactdetails" method="post" action="/servlet/MemberDetails">
  <input type="hidden" name="form" value="registercontactdetails">
  <input type="hidden" name="mode" value="<%= mode %>">
  <input type="hidden" name="redirectto" value="<%= redirectTo %>">

  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="formTable">
  <tr>
    <td class="formLabel">Organisation/Your name*</td>
    <td class="formElementCell"><input class="formElement" name="name" type="text" value="<%= formPopulateMemberContact==null ? "" : formPopulateMemberContact.name %>" maxlength="200"></td>
  </tr>
<%
v = formPopulateMemberContact==null ? "" : String.valueOf( formPopulateMemberContact.statusRef );
o1 = formPopulateMemberContact==null ? "" : formPopulateMemberContact.statusOther;
%>
<jsp:include page="/inc/dropdown.jsp" flush="true" >
  <jsp:param name="formname" value="registercontactdetails"/>
  <jsp:param name="dropdownlabel" value="Your status*"/>
  <jsp:param name="dropdownname"  value="statusref"/>
  <jsp:param name="dropdownvalue" value="<%= v %>"/>
</jsp:include>
<%
v = formPopulateMemberContact==null ? "" : String.valueOf( formPopulateMemberContact.primaryCategoryRef );
c1v = formPopulateMemberContact==null ? "" : String.valueOf( formPopulateMemberContact.primaryDisciplineRef );
%>
  <tr>
    <td colspan="2" class="regFormSpacer">Select the category &amp; discipline relevant to your profile or product</td>
  </tr>
  <tr>
    <td colspan="2" class="regFormSpacer"><a href="/pages/list.jsp?l=faqs" target="_blank">Your category and discipline options</a></td>
  </tr>
<jsp:include page="/inc/dropdown.jsp" flush="true" >
  <jsp:param name="formname" value="registercontactdetails"/>
  <jsp:param name="dropdownlabel" value="Category 1*"/>
  <jsp:param name="dropdownname"  value="primarycategoryref"/>
  <jsp:param name="dropdowngroup"  value="categoryref"/>
  <jsp:param name="dropdownvalue" value="<%= v %>"/>
  <jsp:param name="child1label" value="Discipline 1*"/>
  <jsp:param name="child1name"  value="primarydisciplineref"/>
  <jsp:param name="child1value" value="<%= c1v %>"/>
</jsp:include>
<%
v = formPopulateMemberContact==null ? "" : String.valueOf( formPopulateMemberContact.secondaryCategoryRef );
c1v = formPopulateMemberContact==null ? "" : String.valueOf( formPopulateMemberContact.secondaryDisciplineRef );
%>
  <tr>
    <td colspan="2" class="regFormSpacer">As an option, get listed under two other categories and disciplines</td>
  </tr>
<jsp:include page="/inc/dropdown.jsp" flush="true" >
  <jsp:param name="formname" value="registercontactdetails"/>
  <jsp:param name="dropdownlabel" value="Category 2"/>
  <jsp:param name="dropdownname"  value="secondarycategoryref"/>
  <jsp:param name="dropdowngroup"  value="categoryref"/>
  <jsp:param name="childrenarrayalreadyaefined"  value="true"/>
  <jsp:param name="dropdownvalue" value="<%= v %>"/>
  <jsp:param name="child1label" value="Discipline 2"/>
  <jsp:param name="child1name"  value="secondarydisciplineref"/>
  <jsp:param name="child1value" value="<%= c1v %>"/>
</jsp:include>
<%
v = formPopulateMemberContact==null ? "" : String.valueOf( formPopulateMemberContact.tertiaryCategoryRef );
c1v = formPopulateMemberContact==null ? "" : String.valueOf( formPopulateMemberContact.tertiaryDisciplineRef );
%>
<jsp:include page="/inc/dropdown.jsp" flush="true" >
  <jsp:param name="formname" value="registercontactdetails"/>
  <jsp:param name="dropdownlabel" value="Category 3"/>
  <jsp:param name="dropdownname"  value="tertiarycategoryref"/>
  <jsp:param name="dropdowngroup"  value="categoryref"/>
  <jsp:param name="dropdownvalue" value="<%= v %>"/>
  <jsp:param name="childrenarrayalreadyaefined"  value="true"/>
  <jsp:param name="child1label" value="Discipline 3"/>
  <jsp:param name="child1name"  value="tertiarydisciplineref"/>
  <jsp:param name="child1value" value="<%= c1v %>"/>
</jsp:include>
<%
v = formPopulateMemberContact==null ? "" : String.valueOf( formPopulateMemberContact.sizeRef );
%>
<jsp:include page="/inc/dropdown.jsp" flush="true" >
  <jsp:param name="formname" value="registercontactdetails"/>
  <jsp:param name="dropdownlabel" value="People in organisation*"/>
  <jsp:param name="dropdownname"  value="sizeref"/>
  <jsp:param name="dropdownvalue" value="<%= v %>"/>
</jsp:include>
<%
v = formPopulateMemberContact==null ? "" : String.valueOf( formPopulateMemberContact.countryRef );
%>
<jsp:include page="/inc/dropdown.jsp" flush="true" >
  <jsp:param name="formname" value="registercontactdetails"/>
  <jsp:param name="dropdownlabel" value="Country*"/>
  <jsp:param name="dropdownname"  value="countryref"/>
  <jsp:param name="dropdownvalue" value="<%= v %>"/>
  <jsp:param name="bespokespecialtreatment" value="countryukcheck"/>
</jsp:include>
<%
v = formPopulateMemberContact==null ? "" : String.valueOf( formPopulateMemberContact.regionRef );
c1v = formPopulateMemberContact==null ? "" : String.valueOf( formPopulateMemberContact.countyRef );
String p1 = formPopulateMemberContact==null ? "" : formPopulateMemberContact.address1;
String p2 = formPopulateMemberContact==null ? "" : formPopulateMemberContact.address2;
String p3 = formPopulateMemberContact==null ? "" : formPopulateMemberContact.city;
String p4 = formPopulateMemberContact==null ? "" : formPopulateMemberContact.postcode;
%>
<jsp:include page="/inc/dropdown.jsp" flush="true" >
  <jsp:param name="formname" value="registercontactdetails"/>
  <jsp:param name="dropdownlabel" value="UK region*"/>
  <jsp:param name="dropdownname"  value="ukregionref"/>
  <jsp:param name="dropdownvalue" value="<%= v %>"/>
  <jsp:param name="bespokespecialtreatment" value="addressinsert"/>
  <jsp:param name="address1" value="<%= p1 %>"/>
  <jsp:param name="address2" value="<%= p2 %>"/>
  <jsp:param name="city" value="<%= p3 %>"/>
  <jsp:param name="postcode" value="<%= p4 %>"/>
  <jsp:param name="child1label"   value="County / Unitary authority*"/>
  <jsp:param name="child1name"    value="countyref"/>
  <jsp:param name="child1value"   value="<%= c1v %>"/>
</jsp:include>
<%
v = formPopulateMemberContact==null ? "" : String.valueOf( formPopulateMemberContact.contactTitleRef );
%>
<jsp:include page="/inc/dropdown.jsp" flush="true" >
  <jsp:param name="formname" value="registercontactdetails"/>
  <jsp:param name="dropdownlabel" value="Contact title*"/>
  <jsp:param name="dropdownname"  value="contacttitleref"/>
  <jsp:param name="dropdownvalue" value="<%= v %>"/>
</jsp:include>
  <tr>
    <td class="formLabel">Contact first name*</td>
    <td class="formElementCell"><input class="formElement" name="contactfirstname" value="<%= formPopulateMemberContact==null ? "" : formPopulateMemberContact.contactFirstName %>" type="text" maxlength="200"></td>
  </tr>
  <tr>
    <td class="formLabel">Contact surname*</td>
    <td class="formElementCell"><input class="formElement" name="contactsurname" value="<%= formPopulateMemberContact==null ? "" : formPopulateMemberContact.contactSurname %>" type="text" maxlength="200"></td>
  </tr>
  <tr>
    <td class="formLabel">Telephone number*</td>
    <td class="formElementCell"><input class="formElement" name="telephone" value="<%= formPopulateMemberContact==null ? "" : formPopulateMemberContact.telephone %>" type="text" maxlength="200"></td>
  </tr>
  <tr>
    <td class="formLabel">Mobile number</td>
    <td class="formElementCell"><input class="formElement" name="mobile" value="<%= formPopulateMemberContact==null ? "" : formPopulateMemberContact.mobile %>" type="text" maxlength="200"></td>
  </tr>
  <tr>
    <td class="formLabel">Fax number</td>
    <td class="formElementCell"><input class="formElement" name="fax" value="<%= formPopulateMemberContact==null ? "" : formPopulateMemberContact.fax %>" type="text" maxlength="200"></td>
  </tr>
  <tr>
    <td class="formLabel">Your existing website address</td>
    <td class="formElementCell"><input class="formElement" name="webaddress" value="<%= formPopulateMemberContact==null ? "http://" : formPopulateMemberContact.webAddress %>" type="text" maxlength="200"></td>
  </tr>
  <tr><td colspan="2" style="padding-top: 10px"><h4>Email address</h4></td></tr>
  <tr><td colspan="2" class="regFormSpacer">This is a vital part or your registration so please type this correctly</td></tr>
  <tr>
    <td class="formLabel"><b>Email address*</b></td>
    <td class="formElementCell"><input class="formElement<%= mode.equals( "edit" ) ? "Readonly" : "" %>" <%= mode.equals( "edit" ) ? " readonly=\"readonly\" " : "" %>name="email" value="<%= formPopulateMember==null ? "" : formPopulateMember.email %>" type="text" maxlength="200"></td>
  </tr>
<%

if( mode.equals( "add" ) )
{

%>
  <tr>
    <td class="formLabel">Confirm email address*</td>
    <td class="formElementCell"><input class="formElement" name="confirmemail" value="<%= (   (String)request.getAttribute( "confirmemail" )!=null   ?   (String)request.getAttribute( "confirmemail" )   :   (formPopulateMember==null ? "" : formPopulateMember.email)    ) %>" type="text" maxlength="200"></td>
  </tr>
<%

}
else
{

%>  <input type="hidden" name="confirmemail" value="<%= (   (String)request.getAttribute( "confirmemail" )!=null   ?   (String)request.getAttribute( "confirmemail" )   :   (formPopulateMember==null ? "" : formPopulateMember.email)    ) %>" />
<%

}

%>  <tr>
    <td class="formLabel"><b><%= mode.equals( "edit" ) ? "Change " : "" %>Your password</b><br />(5-12 characters)</td>
    <td class="formElementCell"><input class="formElement" name="passwd" value="<%= formPopulateMember==null ? "" : formPopulateMember.passwd %>" type="password" maxlength="12"></td>
  </tr>
  <tr>
    <td class="formLabel">Confirm your password*</td>
    <td class="formElementCell"><input class="formElement" name="confirmpasswd" value="<%= formPopulateMember==null ? "" : formPopulateMember.passwd %>" type="password" maxlength="12"></td>
  </tr>
  <tr><td colspan="2" style="padding-top: 10px"><h4>Your unique Nextface website address</h4></td></tr>
  <tr><td colspan="2" style="padding-bottom: 9px">The Nextface directory allows you to create your own personal website address for use on your promotional material and stationery.</td></tr>
  <tr><td colspan="2" class="regFormSpacer">The format of your unique Nextface website address will be:</td></tr>
  <tr>
    <td class="formLabel" style="text-align: right; padding-top: 2px;">www.nextface.net/</td>
    <td class="formElementCell"><input class="formElement" name="profileurl" onfocus="if( this.value=='Type whatever you want here' ) { this.value=''; }" onblur="if( this.value=='' ) { this.value='Type whatever you want here'; }" value="<%= formPopulateMember==null ? "Type whatever you want here" : formPopulateMember.profileURL %>" type="text" maxlength="100"></td>
  </tr>
<!--where dif you hear about us, other & which magasine-->
<%
v = formPopulateMemberContact==null ? "" : String.valueOf( formPopulateMemberContact.whereDidYouHearRef );
o1 = formPopulateMemberContact==null ? "" : formPopulateMemberContact.whereDidYouHearOther;
o2 = formPopulateMemberContact==null ? "" : formPopulateMemberContact.whereDidYouHearMagazine;
%>
  <tr>
    <td colspan="2" style="padding-top: 4px">&nbsp;</td>
  </tr>
<jsp:include page="/inc/dropdown.jsp" flush="true" >
  <jsp:param name="formname" value="registercontactdetails"/>
  <jsp:param name="dropdownlabel" value="Where did you hear about Nextface?*"/>
  <jsp:param name="dropdownname"  value="wheredidyouhearref"/>
  <jsp:param name="dropdownvalue" value="<%= v %>"/>
  <jsp:param name="other1label" value="Other"/>
  <jsp:param name="other1name"  value="wheredidyouhearother"/>
  <jsp:param name="other1value" value="<%= o1 %>"/>
  <jsp:param name="other2label" value="Magazine name"/>
  <jsp:param name="other2name"  value="wheredidyouhearmagazine"/>
  <jsp:param name="other2value" value="<%= o2 %>"/>
</jsp:include>
  </table>
  <br />
<jsp:include page="/text/text.jsp" flush="true" >
  <jsp:param name="t" value="regcontact2"/>
</jsp:include>
  <table cellpadding="0" cellspacing="0" width="100%">
  <tr>
    <td nowrap="nowrap"><h6><a onclick="document.forms['registercontactdetails'].submit(); return false;" href="">Submit this data and continue</a></h6></td>
    <td width="100%"></td>
  </tr>
  </table>
</form>
<jsp:include page="/inc/pageFoot.jsp" flush="true" />