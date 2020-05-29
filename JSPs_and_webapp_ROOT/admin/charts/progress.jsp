<%@ page import="

"%>
<%
  String progressMessage = ((String)request.getAttribute("progressMessage"));
  if( progressMessage == null )
  {
    progressMessage = "";
  }
%>

    <br />
    <%= progressMessage %>
