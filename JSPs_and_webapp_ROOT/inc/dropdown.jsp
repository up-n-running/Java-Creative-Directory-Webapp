<%@ page language="java"
  import="com.extware.utils.StringUtils,
          com.extware.utils.PropertyFile,
          com.extware.utils.BooleanUtils,
          java.util.ArrayList"
%><%

String otherNotApplicable = "N/A";
String otherPleaseSelectAbove = "Select option above";

String dropDownLabel = StringUtils.nullString( request.getParameter( "dropdownlabel" ) );
String dropDownName = StringUtils.nullString( request.getParameter( "dropdownname" ) );
String dropDownGroup = StringUtils.nullString( request.getParameter( "dropdowngroup" ) );
if( dropDownGroup.equals( "" ) )
{
  dropDownGroup = dropDownName;
}
String dropDownValue = request.getParameter( "dropdownvalue" ); //this will be populated as it is drawn. id to be set to null no value already exists (ie if none is passed in)
dropDownValue = ( dropDownValue==null || dropDownValue.length()==0 || dropDownValue.equals( "-1" ) || dropDownValue.equals( "none" ) ) ? null : dropDownValue;  //we must treat an empty input as no input at all.
int dropDownSize = 0; //gets pupulated in first loop through
String formName = request.getParameter( "formname" ) == null ? "0" : "'" + request.getParameter( "formname" ) + "'";

String[] others = new String[5];
others[0] = request.getParameter( "other1name" );
others[1] = request.getParameter( "other2name" );
others[2] = request.getParameter( "other3name" );
others[3] = request.getParameter( "other4name" );
others[4] = request.getParameter( "other5name" );

String[] children = new String[5];
children[0] = request.getParameter( "child1name" );
children[1] = request.getParameter( "child2name" );
children[2] = request.getParameter( "child3name" );
children[3] = request.getParameter( "child4name" );
children[4] = request.getParameter( "child5name" );

PropertyFile dropDownProps = new PropertyFile( "com.extware.properties.DropDowns" );
String pleaseChooseOne = dropDownProps.getString( dropDownGroup + ".pleaseChooseOne" );

//create onchange string to manage 'other' fields and child drop down boxes if there are any others fields
String onChangeScript="";


//now display drop down
String isDefaultInsert = "";
%>  <tr>
    <td class="formLabel"><%= dropDownLabel %></td>
    <td class="formElementCell">
      <select class="formElement" name="<%= dropDownName %>" onChange="<%= dropDownName %>OnChange( this )">
<%
//if we want to put "please choose.." as top option
if( pleaseChooseOne!=null )
{
  if( dropDownValue==null )
  {
    dropDownValue = "none";
    isDefaultInsert = "selected=\"selected\" ";
  }
%>        <option <%= isDefaultInsert %>value="none"><%= pleaseChooseOne %></option>
<%
}
if( dropDownValue==null )   //if not set - it will be set to the first entry on drop down box
{
  dropDownValue = "1";
}


//loop through options displaying them
for( int loopHandle=1 ; dropDownProps.getString( dropDownGroup + "." + loopHandle ) != null ; loopHandle++ )
{
  //set if this is the selected one
  if( dropDownValue.equals( String.valueOf( loopHandle ) ) )
  {
    isDefaultInsert = "selected=\"selected\" ";
  }
  else
  {
    isDefaultInsert = "";
  }
%>        <option <%= isDefaultInsert %>value="<%= loopHandle %>"><%= dropDownProps.getString( dropDownGroup + "." + loopHandle ) %></option>
<%
dropDownSize = loopHandle; //keep track of size for future looping
}
%>      </select>
    </td>
  </tr>
<%


//now, if there are any 'others' fields, display them
for( int i = 0 ; i<others.length && others[i]!=null && others[i].length()>0 ; i++ )
{
  String otherFormFieldName = others[i];
  String otherFormFieldLabel = StringUtils.nullString( request.getParameter( "other" + (i+1) + "label" ) );
  String otherFormFieldHandle = dropDownProps.getString( dropDownGroup + ".othersHandle." + (i+1) );
  String otherFormFieldDisabledAndValueInsert;

  if( dropDownValue.equals( otherFormFieldHandle ) )
  {
    otherFormFieldDisabledAndValueInsert = "value=\"" + StringUtils.nullString( request.getParameter( "other" + (i+1) + "value" ) ) + "\"";
  }
  else if( dropDownValue.equals( "none" ) )
  {
    otherFormFieldDisabledAndValueInsert = "disabled=\"disabled\" value=\"" + otherPleaseSelectAbove + "\"";
  }
  else
  {
    otherFormFieldDisabledAndValueInsert = "disabled=\"disabled\" value=\"" + otherNotApplicable + "\"";
  }
%>  <tr>
    <td class="formLabel"><%= otherFormFieldLabel %></td>
    <td class="formElementCell"><input class="formElement" name="<%= otherFormFieldName %>" type="text" <%=otherFormFieldDisabledAndValueInsert %> onfocus="if( this.disabled ) this.blur();" maxlength="200"></td>
  </tr>
<%
  //set onchange string to manage this 'other' field
  onChangeScript +=         " setOtherFieldStatus( box, box.form." + otherFormFieldName + ", '" + otherFormFieldHandle + "', '" + otherPleaseSelectAbove + "', '" + otherNotApplicable +"' );\n" ;
}

//if children need to be set to a value on form load, this script will be set.
String intialiseChildrenScript = "";

//nextface specific code - rip this out if not for nextface
String bespokespecialtreatment = StringUtils.nullString( request.getParameter( "bespokespecialtreatment" ) );
if( bespokespecialtreatment.equals( "addressinsert" ) )
{
%>  <tr>
    <td class="formLabel">Address line 1*</td>
    <td class="formElementCell"><input class="formElement" name="address1" value="<%= request.getParameter( "address1" ) %>" type="text" maxlength="200"></td>
  </tr>
  <tr>
    <td class="formLabel">Address line 2</td>
    <td class="formElementCell"><input class="formElement" name="address2" value="<%= request.getParameter( "address2" ) %>" type="text" maxlength="200"></td>
  </tr>
  <tr>
    <td class="formLabel">Town/city (or nearest)*</td>
    <td class="formElementCell"><input class="formElement" name="city" value="<%= request.getParameter( "city" ) %>" type="text" maxlength="200"></td>
  </tr>
  <tr>
    <td class="formLabel">Postcode*</td>
    <td class="formElementCell"><input class="formElement" name="postcode" value="<%= request.getParameter( "postcode" ) %>" type="text" maxlength="200"></td>
  </tr>
<%
  intialiseChildrenScript += "      countryrefOnChange( document.forms[" + formName + "].countryref );\n";
}



//now, if there are any child drop downs, display them
String childDropDown = dropDownProps.getString( dropDownGroup + ".childDropDown" );

if( childDropDown!=null && !childDropDown.equals( "" ) && children[0]!=null && children[0].length()>0)  //if property file says there is a child and if child params passed into this jsp
{
  if( !dropDownValue.equals( "none" ) )
  {
      //intialiseChildrenScript = "    alert( document );";
      //intialiseChildrenScript += "    alert( document.forms[" + formName + "] );";
      //intialiseChildrenScript += "    alert( document.forms[" + formName + "].elements[ '" + dropDownName + "' ] );";

    intialiseChildrenScript = "    " + dropDownName + "OnChange( document.forms[" + formName + "].elements[ '" + dropDownName + "' ] );\n";
  }

  String childPleaseChooseOne = StringUtils.nullString( dropDownProps.getString( childDropDown + ".pleaseChooseOne" ) );

  String jsArrayName = dropDownGroup + "Data";

  //first we need to create a javascript script that defines an array with all of the drop down content in it uness a parent box of this type has already been defined in the form, in which case they'll have passed in a parameter telling them not to repeat this array definition
  if( !BooleanUtils.isTrue( request.getParameter( "childrenarrayalreadyaefined" ) ) )
  {
    String dropDownDataJS = "  <script language=\"javascript\">\n" +
                            "    var " + jsArrayName + " = new Array();\n";
    for( int parentLoopHandle=1 ; parentLoopHandle<=dropDownSize ; parentLoopHandle++ )
    {
      dropDownDataJS += "    " + jsArrayName + "[ '" + parentLoopHandle + "' ] = new Array(";
      for( int childLoopHandle=1 ; dropDownProps.getString( childDropDown + "." + parentLoopHandle + "." + childLoopHandle ) != null ; childLoopHandle++ )
      {
        dropDownDataJS += (childLoopHandle==1?"'":", '") + dropDownProps.getString( childDropDown + "." + parentLoopHandle + "." + childLoopHandle ) + "'";
      }
      dropDownDataJS += ");\n";

    }
    dropDownDataJS += "  </script>";
    out.println( dropDownDataJS );
  }


  //now loop through all copies of children we are to render and draw them and generate onchange javascript
  String childDropDownDisbaledInsert = "";
  if( dropDownValue.equals( "none" ) )
  {
    childDropDownDisbaledInsert = "disabled=\"disabled\" ";
  }
  for( int i = 0 ; i<children.length && children[i]!=null && children[i].length()>0 ; i++ )
  {
    String childDropDownName = children[i];
    String childDropDownLabel = StringUtils.nullString( request.getParameter( "child" + (i+1) + "label" ) );
    String childDropDownValue = request.getParameter( "child" + (i+1) + "value" );
    if( childDropDownValue==null || childDropDownValue.equals( "" ) || childDropDownValue.equals( "-1" ) || childDropDownValue.equals( "none" ) )
    {
      childDropDownValue = null;
    }
%>  <tr>
    <td class="formLabel"><%= childDropDownLabel %></td>
    <td class="formElementCell">
      <select <%= childDropDownDisbaledInsert %>class="formElement" name="<%= childDropDownName %>" >
        <option><%= otherPleaseSelectAbove %></option>
      </select>
    </td>
  </tr>
<%
    onChangeScript += "      changeChildren( box, '" + dropDownGroup + "', '" + childDropDownName + "', '" + childPleaseChooseOne + "' );\n";
    if( childDropDownValue!=null && !dropDownValue.equals( "none" ) )
    {
      intialiseChildrenScript += "    document.forms[" + formName + "]." + childDropDownName + ".selectedIndex = " + childDropDownValue + ";\n";
    }
  }
}
//now generate javascript function and if necessary initialise sub arrays
%>  <script language="javascript">
    function <%= dropDownName %>OnChange( box )
    {
<%
out.print( onChangeScript );


//nextface specific code - rip this out if not for nextface
if( bespokespecialtreatment.equals( "countryukcheck" ) )
{
%>
      cr = box.form.countyref;
      rr = box.form.ukregionref

      if( box.selectedIndex==1 )
      {
        if( cr.options[cr.options.length-1].value == 'na' )
        {
          cr.options[cr.options.length-1] = null;
        }
        cr.disabled = true;
        if( rr.options[rr.options.length-1].value == 'na' )
        {
          rr.options[rr.options.length-1] = null;
        }
        rr.disabled = false;
      }
      else
      {
        defaultText = '<%= otherNotApplicable %>';
        if( box.selectedIndex==0 )
        {
          defaultText = '<%= otherPleaseSelectAbove %>';
        }
        if( cr.options[cr.options.length-1].value == 'na' )
        {
          cr.options[cr.options.length-1] = null;
        }
	      cr.options[cr.options.length] = new Option( defaultText, 'na' );
        cr.selectedIndex = cr.length-1;
        cr.disabled = true;
        if( rr.options[rr.options.length-1].value == 'na' )
        {
	        rr.options[rr.options.length-1] = null;
        }
	      rr.options[rr.options.length] = new Option( defaultText, 'na' );
        rr.selectedIndex = rr.options.length-1;
        rr.disabled = true;
      }
<%
}

%>
    }
<%
out.print( intialiseChildrenScript );
%>  </script>
