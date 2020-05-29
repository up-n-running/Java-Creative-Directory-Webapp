//			  Name     Menu Orient		width	table class	style per cell?

var menu2 = new mainMenu( "menu2", menuTypeVert,	120,	"mainMenu",	1 );

//       Menu Object    ID              Text                    URI                     On Class        Off Class      Size Fade% Table Class

addItem( menu2,		"about",	"About Us",		"/?c=/about/",		"mainMenuOn",	"mainMenuOff", 100, null, "subMenu" );
addItem( menu2,		"clients",	"Client Portfolio",	"/?c=/clients/",	"mainMenuOn",	"mainMenuOff", 100, null, "subMenu" );
addItem( menu2,		"invest",	"Investor Information",	"/?c=/invest/",		"mainMenuOn",	"mainMenuOff", 100, null, "subMenu" );

aboutMenu2 = findItem( menu2, "about" );

addItem( aboutMenu2,	"me",		"Me",		"/?c=/about/team/me/",		"subMenuOn",	"subMenuOff", 50, 70, "subMenu" );
addItem( aboutMenu2,	"him",		"Him",		"/?c=/about/team/him/",		"subMenuOn",	"subMenuOff", 50, 70, "subMenu" );
addItem( aboutMenu2,	"them",		"Them",		"/?c=/about/team/them/",	"subMenuOn",	"subMenuOff", 50, 70, "subMenu" );
