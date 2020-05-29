<%@ page language="java"
  import="com.extware.member.Member,
          com.extware.member.MemberContact,
          com.extware.member.MemberJob,
          com.extware.utils.StringUtils,
          java.util.ArrayList"
%><%
//Get logged in user if there is a user logged in
Member loggedInMember = (Member)request.getSession().getAttribute( "member" );

//if not logged in, sack them off
if( loggedInMember==null )
{
  %><jsp:forward page="/loggedOut.jsp" /><%
  return;
}

String redirectTo = "/pages/accountManager.jsp";

//hold the details of the objects used to populate the form.
MemberJob formPopulateMemberJob = (MemberJob)request.getAttribute( "memberjobtoedit" );  //this will be set to null if adding not editing a job
MemberContact memberContactFallback = loggedInMember.moderationMemberContact != null ? loggedInMember.moderationMemberContact : loggedInMember.memberContact;
Member memberFallback = loggedInMember;

//edit / delete options
String introTextPageHandle = "jobsadd1";
String mode="add";
if( formPopulateMemberJob != null )
{
  introTextPageHandle = "jobsedit1";
  mode="edit";
}

ArrayList errorsToReport = (ArrayList)request.getAttribute( "errors" );
if( errorsToReport != null && errorsToReport.size() > 0 )
{
  formPopulateMemberJob = (MemberJob)request.getAttribute( "formmemberjob" );
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
  <jsp:param name="t" value="<%= introTextPageHandle %>"/>
</jsp:include>

<table cellpadding="0" cellspacing="0" width="100%">
<tr>
  <td nowrap="nowrap"><h6 class="burgundyh6"><a href="/pages/accountManager.jsp">Go back to account manager</a></h6></td>
  <td width="100%"></td>
</tr>
</table>

<%

if( mode.equals( "edit" ) )
{

%><table cellpadding="0" cellspacing="0" width="100%">
<tr>
  <td nowrap="nowrap"><h6 class="burgundyh6"><a onclick="document.forms[ 'jobsearch' ].jobselect.selectedIndex=0; document.forms[ 'jobsearch' ].submit(); return false;" href="">Cancel editing this job and add a new job</a></h6></td>
  <td width="100%"></td>
</tr>
</table>
<%

}

%>
<table cellpadding="0" cellspacing="0" width="100%">
<tr>
  <td nowrap="nowrap"><h6 class="linkNoTarget">Or proceed below...</h6></td>
  <td width="100%"></td>
</tr>
</table>

<br />
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

%>
<h4>Edit details of an exisiting job vacancy</h4>
<form name="jobsearch" method="post" action="/servlet/MemberJobs">
  <input type="hidden" name="form" value="jobsearch">
  <input type="hidden" name="divertto" value="<%= request.getParameter( "divertto" )==null ? "" : request.getParameter( "divertto" ) %>">
  <input type="hidden" name="mode" value="edit">

  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="formTable">
  <tr>
    <td class="formLabel">Select a<%= (mode!=null && mode.equals( "edit" )) ? "nother" : "" %> job to edit</td>
    <td class="formElementCell">
      <select class="formElement" name="jobselect" onChange="if( this.value != 'none' ){ this.form.submit(); }">
<%

if( formPopulateMemberJob==null || formPopulateMemberJob.memberJobId == -1 )
{

%>        <option value="none" selected="selected">Select a job to edit or delete</option>
<%

}
else
{

%>        <option value="add">Cancel and add a new job</option>
<%

}

MemberJob job = null;
String selectValue = null;
String selectedInsert="";

for( int i = 0 ; i < loggedInMember.memberJobs.size() ; i++ )
{
  job = loggedInMember.getJobForAccountManager( i );
  selectedInsert="";

  if( formPopulateMemberJob!=null && formPopulateMemberJob.memberJobId == job.memberJobId )
  {
    selectedInsert = "selected=\"selected\"";
  }

  selectValue = job.referenceNo + ": " + job.title;
  if( selectValue.length() > 50 )
  {
    selectValue = selectValue.substring( 0, 47 ) + "...";
  }

%>        <option <%= selectedInsert %> value="<%= job.memberJobId %>"><%= selectValue %></option>
<%

}

%>      </select>
    </td>
  </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" >To delete a vacancy, select it above and click 'delete'</td>
    <td><input type="image" onclick=" if( this.form.jobselect.value=='add' ){ alert( 'To delete an existing job you must first select one from the drop down box above' ); return false; }   if( confirm( 'Are you sure that you want to delete the selected job' ) ) { this.form.mode.value = 'delete'; return true; } else { return false; }" src="/art/deleteButton.gif" name="delete" /></td>
  </tr>
  </table>
</form>
<br />
<br />
<h4><%= (mode!=null && mode.equals( "edit" )) ? "Edit your" : "Post new" %> job vacancy details here:</h4>
<form name="jobedit" method="post" action="/servlet/MemberJobs">
  <input type="hidden" name="form" value="jobedit">
  <input type="hidden" name="redirectto" value="<%= redirectTo %>" />
  <input type="hidden" name="mode" value="<%= mode %>" />
  <input type="hidden" name="memberjobid" value="<%= formPopulateMemberJob==null ? -1 : formPopulateMemberJob.memberJobId %>" />

  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="formTable">
  <tr>
    <td class="formLabel">Job title*</td>
    <td class="formElementCell"><input class="formElement" name="title" value="<%= formPopulateMemberJob==null ? "" : formPopulateMemberJob.title %>" type="text" maxlength="200"></td>
  </tr>
  <tr>
    <td class="formLabel">Job reference number*</td>
    <td class="formElementCell"><input class="formElement" name="referencenumber" value="<%= formPopulateMemberJob==null ? "" : formPopulateMemberJob.referenceNo %>" type="text" maxlength="200"></td>
  </tr>
<!--job category and job discipline-->
<%
v = formPopulateMemberJob==null ? String.valueOf(  memberContactFallback.primaryCategoryRef ) : String.valueOf( formPopulateMemberJob.mainCategoryRef );
c1v = formPopulateMemberJob==null ? String.valueOf(  memberContactFallback.primaryDisciplineRef ) : String.valueOf( formPopulateMemberJob.disciplineRef );
%>
<jsp:include page="/inc/dropdown.jsp" flush="true" >
  <jsp:param name="formname"      value="jobedit"/>
  <jsp:param name="dropdownlabel" value="Job category*"/>
  <jsp:param name="dropdownname"  value="maincategoryref"/>
  <jsp:param name="dropdowngroup"  value="categoryref"/>
  <jsp:param name="dropdownvalue" value="<%= v %>"/>
  <jsp:param name="child1label" value="Job discipline*"/>
  <jsp:param name="child1name"  value="disciplineref"/>
  <jsp:param name="child1value" value="<%= c1v %>"/>
</jsp:include>
<!--type of work-->
<%
v = formPopulateMemberJob==null ? "" : String.valueOf( formPopulateMemberJob.typeOfWorkRef );
%>
<jsp:include page="/inc/dropdown.jsp" flush="true" >
  <jsp:param name="formname"      value="jobedit"/>
  <jsp:param name="dropdownlabel" value="Type of work*"/>
  <jsp:param name="dropdownname"  value="typeofworkref"/>
  <jsp:param name="dropdownvalue" value="<%= v %>"/>
</jsp:include>
  <tr>
    <td class="formLabel">Salary*</td>
    <td class="formElementCell"><input class="formElement" name="salary" value="<%= formPopulateMemberJob==null ? "" : formPopulateMemberJob.salary %>" type="text" maxlength="200"></td>
  </tr>
<!--country-->
<%
v = formPopulateMemberJob==null ? String.valueOf( memberContactFallback.countryRef ) : String.valueOf( formPopulateMemberJob.countryRef );
%>
<jsp:include page="/inc/dropdown.jsp" flush="true" >
  <jsp:param name="formname"      value="jobedit"/>
  <jsp:param name="dropdownlabel" value="Job location (Country)*"/>
  <jsp:param name="dropdownname"  value="countryref"/>
  <jsp:param name="dropdownvalue" value="<%= v %>"/>
  <jsp:param name="bespokespecialtreatment" value="countryukcheck"/>
</jsp:include>
<!--UK Region and county-->
<%
v = formPopulateMemberJob==null ? String.valueOf( memberContactFallback.regionRef ) : String.valueOf( formPopulateMemberJob.ukRegionRef );
c1v = formPopulateMemberJob==null ? String.valueOf( memberContactFallback.countyRef ) : String.valueOf( formPopulateMemberJob.countyRef );
%>
<jsp:include page="/inc/dropdown.jsp" flush="true" >
  <jsp:param name="formname"      value="jobedit"/>
  <jsp:param name="dropdownlabel" value="Job location (UK region)*"/>
  <jsp:param name="dropdownname"  value="ukregionref"/>
  <jsp:param name="dropdownvalue" value="<%= v %>"/>
  <jsp:param name="child1label"   value="Job location (UK county)*"/>
  <jsp:param name="child1name"    value="countyref"/>
  <jsp:param name="child1value"   value="<%= c1v %>"/>
</jsp:include>
  <tr>
    <td class="formLabel">Location (town or city name)</td>
    <td class="formElementCell"><input class="formElement" name="city" value="<%= formPopulateMemberJob==null ? memberContactFallback.city : formPopulateMemberJob.city %>" type="text" maxlength="200"></td>
  </tr>
  <tr>
    <td class="formLabel">Contact telephone number*</td>
    <td class="formElementCell"><input class="formElement" name="telephone" value="<%= formPopulateMemberJob==null ? memberContactFallback.telephone : formPopulateMemberJob.telephone %>" type="text" maxlength="200"></td>
  </tr>
  <tr>
    <td class="formLabel">Contact email address*</td>
    <td class="formElementCell"><input class="formElement" name="email" value="<%= formPopulateMemberJob==null ? memberFallback.email : formPopulateMemberJob.email %>" type="text" maxlength="200"></td>
  </tr>
  <tr>
    <td class="formLabel">Contact name*</td>
    <td class="formElementCell"><input class="formElement" name="contactname" value="<%= formPopulateMemberJob==null ? memberContactFallback.contactFirstName + " " + memberContactFallback.contactSurname : formPopulateMemberJob.contactName %>" type="text" maxlength="200"></td>
  </tr>
  </table>
  <br />
  <b>Type the job description here (maximum 300 words)</b><br />
  <textarea class="bigFormElement" name="description" maxlength="2000" rows="4"><%= formPopulateMemberJob==null ? "" : formPopulateMemberJob.description %></textarea><br />
  <br />
  <jsp:include page="/inc/tasteAndTermsInclude.jsp" flush="true" />
  <br />
<jsp:include page="/text/text.jsp" flush="true" >
  <jsp:param name="t" value="jobsadd2"/>
</jsp:include>
<%
if( mode.equals( "edit" ) )
{
%>  <table cellpadding="0" cellspacing="0" width="100%"><tr><td nowrap="nowrap"><h6 class="burgundyh6"><a onclick="document.forms[ 'jobsearch' ].jobselect.selectedIndex=0; document.forms[ 'jobsearch' ].submit(); return false;" href="">Cancel editing this job and add a new job</a></h6></td><td width="100%"></td></tr></table>
<%
}
%><table cellpadding="0" cellspacing="0" width="100%"><tr><td nowrap="nowrap"><h6><a onclick="if( tAndTCheck() ) { document.forms[ 'jobedit' ].submit(); } return false;" href="">Submit <%= mode.equals( "edit" ) ? "these changes" : "this job vacancy" %></a></h6></td><td width="100%"></td></tr></table>
</form>
<jsp:include page="/inc/pageFoot.jsp" flush="true" />
