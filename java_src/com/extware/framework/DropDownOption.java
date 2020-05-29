package com.extware.framework;

/**
 * Simple object for holding options for a select statement - an arroylist of these is sufficient to pass to a jsp in order to render a drop down box
 *
 * @author   John Milner
 */
public class DropDownOption
{

  public String  id;
  public String  desc;
  public boolean selected;

/**
 * Default Constructor for the DropDownOption object
 */
  public DropDownOption()
  {
    id = "";
    desc = "";
    selected = false;
  }

/**
 * Constructor for the DropDownOption object
 *
 * @param id    the id, used in the name field of the option tag
 * @param desc  the description to go between open and close option tags
 */
  public DropDownOption( String id, String desc )
  {
    this();
    this.id = id;
    this.desc = desc;
  }

/**
 * Full Constructor for the DropDownOption object
 *
 * @param id    the id, used in the name field of the option tag
 * @param desc  the description to go between open and close option tags
 * @param selected  set whether this is the default selected option in the list
 */
  public DropDownOption( String id, String desc, boolean selected )
  {
    this.selected = selected;
    this.id = id;
    this.desc = desc;
  }

}
