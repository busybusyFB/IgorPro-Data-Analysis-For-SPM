#pragma rtGlobals=1		// Use modern global access method.
#pragma IgorVersion=6.01		// AfterWindowCreatedHook requires 6.01
#pragma version = 1.4.0.0
#pragma IndependentModule=ACL_WindowDesktops

// ********************
//  LICENSE
// ********************
//	Copyright (c) 2007 by Adam Light
//	
//	Permission is hereby granted, free of charge, to any person
//	obtaining a copy of this software and associated documentation
//	files (the "Software"), to deal in the Software without
//	restriction, including without limitation the rights to use,
//	copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the
//	Software is furnished to do so, subject to the following
//	conditions:
//	
//	The above copyright notice and this permission notice shall be
//	included in all copies or substantial portions of the Software.
//	
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//	OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//	HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//	OTHER DEALINGS IN THE SOFTWARE.
//
// *************************
//  VERSION HISTORY
// *************************
// For a complete list of all changes made to this code, please view the Subversion
// commit message log for this project at:
//   http://www.igorexchange.com/project/cvs/59

// ********************
//  CONSTANTS
// ********************
static StrConstant kPackageName = "ACL_WindowDesktops"
static StrConstant kPreferencesFileName = "ACL_WindowDesktopsPrefs.bin"
static StrConstant kACLWindowDesktopsPnlName = "pnlDesktopControl"
static Constant kPreferencesRecordID = 0
static Constant K_CURRENTPREFSVERSION = 100
// Holds the default number of desktops to display to the user for selection
// in the  panel. There is no real limit to the actual number of desktops
// that could be used, however to keep the panel simple we only allow
// the user to control a small number of desktops. Other packages
// could however use the API functions in this package to provide access
// to additional desktops.
static Constant kDefaultNumDesktopsInPanel = 4

// This is to keep the calculation of button size reasonably
// simple and to keep the panel width small enough to fit
// on most monitors.
static Constant kMaximumNumDesktopsInPanel = 20

// ********************
//  STRUCTURES
// ********************
Structure ACL_WindowDesktopsStr
	// version 100
	uint32 version
	double panelCoords[4]		// left, top, right, bottom
	int32 numDesktopsInPanel		// Introduced with version 1.4 of package.
	uint32 reserved[99]		// reserved for future use
EndStructure

// ********************
//  MENUS
// ********************
Menu "Misc", hideable
	"Desktop Control Panel",/Q,Initialize_pnlDesktopControl()
End

Menu "WindowDesktopsOptionsMenu", contextualmenu
	"Set # of Desktops Available", /Q, PromptSetNumDesktopButtons()
End

// ********************
//  PANEL
// ********************
//**
// Builds the control panel.
//
// @param numDesktopsInPanel
//	[OPTIONAL] Controls how many numbered desktop buttons to
//	display in the panel. Pass 0 to use the package's default
//	number of buttons. The maximum number of numbered buttons
// 	that will be displayed is kMaximumNumDesktopsInPanel
//*
Function BuildpnlDesktopControl([numDesktopsInPanel])
	Variable numDesktopsInPanel
	
	if (ParamIsDefault(numDesktopsInPanel))
		numDesktopsInPanel = kDefaultNumDesktopsInPanel
	elseif (numtype(numDesktopsInPanel) != 0)
		numDesktopsInPanel = kDefaultNumDesktopsInPanel
	elseif (numDesktopsInPanel <= 0)
		// We don't support having 0 numbered buttons in the panel.
		numDesktopsInPanel = kDefaultNumDesktopsInPanel
	elseif (numDesktopsInPanel > kMaximumNumDesktopsInPanel)
		numDesktopsInPanel = kMaximumNumDesktopsInPanel
	endif

	// Variables that control the panel and button spacing.
	Variable panelMargin = 2					// Pixels between edge of panel and any controls.
	Variable verticalSpacing = 4				// Pixels between rows of controls.
	if (cmpstr(IgorInfo(2), "Macintosh") == 0)
		// Controls need to be spaced further apart on the Macintosh.
		verticalSpacing = 5
	endif
	Variable horizontalSpacing = 4		// Minimum pixels between rows of controls.
	if (cmpstr(IgorInfo(2), "Macintosh") == 0)
		// Controls need to be spaced further apart on the Macintosh.
		horizontalSpacing = 6
	endif


	// Variables that control the panel and button sizing and spacing.
	Variable buttonHeight = 20					// All buttons are the same height
	// Numbered buttons are square (or squarish on the Mac) when the
	// total number of desktops with buttons displayed is <= 9, but they are
	// much wider if the user wants a ton of buttons.
	Variable numButtonWidth
	if (numDesktopsInPanel < 10)
		numButtonWidth = buttonHeight	
	else
		numButtonWidth = 1.5 * buttonHeight
	endif
	
	Variable defaultButtonWidth = 70			// Width of the "Default" buttons
	Variable textLabelWidth = 41				// Maximum width of the "Assign:" or "Show:" text labels.
	Variable allButtonWidth = max(30, (2 * numButtonWidth) + horizontalSpacing)				// Width of the "All" button. Typically this will be just over twice the width of two number buttons so things line up correctly.
	
	
	// Calculate the total size of the panel.
	Variable panelHeight = (2 * buttonHeight) + verticalSpacing + (2 * panelMargin)
	
	// Calculate the width of everything on the panel except the numbered buttons.
	// Note: The max(allButtonWidth, numButtonWidth) gives the width of the larger of
	// the All button or the "?" and options button.
	Variable panelWidth = textLabelWidth + defaultButtonWidth + max(allButtonWidth, numButtonWidth) + (2 * panelMargin)
	// Add the width of the # buttons and spacing to panelWidth
	panelWidth += (numDesktopsInPanel * numButtonWidth) + ((numDesktopsInPanel+ 1) * horizontalSpacing)
	
	Variable originX = 100
	Variable originY = 100
	
	Variable currentX
	Variable currentY
	Variable buttonCount
	
	String thisButtonName
	
	// Note: If panelWidth is > the width of the screen, the panel width will be clipped.
	// There's not much we can do about that so we accept it.
	NewPanel /W=(originX,originY,originX + panelWidth, originY + panelHeight)/FLT=1/K=1/N=$(kACLWindowDesktopsPnlName) as "Desktop Control"
	
	// Store as userdata the number of desktop (numbered) buttons in the panel.
	SetWindow $(kACLWindowDesktopsPnlName), userdata(numDesktopsInPanel)=num2str(numDesktopsInPanel)
	
	// First row: Assign row.
	currentX = 0
	currentY = 0
	currentX += panelMargin
	currentY += panelMargin
	TitleBox titleAssign,pos={currentX,currentY},size={textLabelWidth,buttonHeight},title="Assign:",frame=0,fStyle=1
	currentX += textLabelWidth 
	Button buttonAssignDefault,pos={currentX,currentY},size={defaultButtonWidth,buttonHeight},proc=ButtonAssignDesktop,title="Default"
	Button buttonAssignDefault,userdata(desktop)=  "0"
	currentX += defaultButtonWidth + horizontalSpacing
	
	buttonCount = 1		// Our button count is 1 based here since we don't want a button with text of 0.
	For (buttonCount = 1; buttonCount <= numDesktopsInPanel; buttonCount += 1)
		thisButtonName = "buttonAssign" + num2istr(buttonCount)
		Button $(thisButtonName),pos={currentX,currentY},size={numButtonWidth,buttonHeight},proc=ButtonAssignDesktop,title=num2istr(buttonCount)
		Button $(thisButtonName),userdata(desktop)=  num2istr(buttonCount)
		currentX += numButtonWidth + horizontalSpacing
	EndFor
	
	// Options button.
	// We want the options button to be right aligned, so that's why we don't use currentX as the left position below.
	Variable optionsButtonXPosition = panelWidth - panelMargin - numButtonWidth
	Button buttonOptions,pos={optionsButtonXPosition,currentY},size={numButtonWidth,buttonHeight},proc=ButtonOptions,fSize=14,title=""
	Button buttonOptions,fStyle=1,picture=SettingsIcon
	
	// Help button.
	// We want the help button position to be relative to the options button, so that's why we don't use currentX as the left position below.
	Button buttonHelp,pos={optionsButtonXPosition - horizontalSpacing - numButtonWidth,currentY},size={numButtonWidth,buttonHeight},proc=ButtonHelp,title="?",fSize=14
	Button buttonHelp,fStyle=1
	
	
	// Second row: Show row.
	currentX = 0
	currentY = 0
	currentX += panelMargin
	currentY += panelMargin + buttonHeight + verticalSpacing

	TitleBox titleShow,pos={currentX,currentY},size={textLabelWidth,buttonHeight},title="Show:",frame=0,fStyle=1
	currentX += textLabelWidth 
	Button buttonShowDefault,pos={currentX,currentY},size={defaultButtonWidth,buttonHeight},proc=ButtonShowDesktop,title="Default"
	Button buttonShowDefault,userdata(desktop)=  "0"
	currentX += defaultButtonWidth + horizontalSpacing
	
	buttonCount = 1		// Our button count is 1 based here since we don't want a button with text of 0.
	For (buttonCount = 1; buttonCount <= numDesktopsInPanel; buttonCount += 1)
		thisButtonName = "buttonShow" + num2istr(buttonCount)
		Button $(thisButtonName),pos={currentX,currentY},size={numButtonWidth,buttonHeight},proc=ButtonShowDesktop,title=num2istr(buttonCount)
		Button $(thisButtonName),userdata(desktop)=  num2istr(buttonCount)
		currentX += numButtonWidth + horizontalSpacing
	EndFor
	
	// Show all button
	// We want the help button to be right aligned, so that's why we don't use currentX as the left position below.
	Button buttonShowAll,pos={panelWidth - panelMargin - allButtonWidth,currentY},size={allButtonWidth,buttonHeight},proc=ButtonShowDesktop,title="All"
	Button buttonShowAll,userdata(desktop)=  "-1"
	
	SetActiveSubwindow _endfloat_
End

// ********************
//  INITIALIZATION
// ********************
//**
// Initializes the package.
//
// @param numDesktopsInPanel
//	[OPTIONAL] Controls how many numbered desktop buttons to
//	display in the panel. Pass 0 to use the package's default
//	number of buttons. The maximum number of numbered buttons
// 	that will be displayed is kMaximumNumDesktopsInPanel.
//*
Function Initialize_pnlDesktopControl([numDesktopsInPanel])
	Variable numDesktopsInPanel
	
	if (ParamIsDefault(numDesktopsInPanel))
		numDesktopsInPanel = 0
	endif
	
	String panelName = "pnlDesktopControl"
	DoWindow $(panelName)
	Variable numDesktops
	if (!V_flag)
		String curDataFolder = GetDataFolder(1)
		if (!DataFolderExists("root:Packages:ACL_WindowDesktops"))
			NewDataFolder/O/S root:Packages
			NewDataFolder/O/S root:Packages:ACL_WindowDesktops
		else
			SetDataFolder root:Packages:ACL_WindowDesktops
		endif
		
		Variable displayedDesktop = GetDisplayedDesktop()
		if (numtype(displayedDesktop) != 0)
			// Create the variable and set to display the default desktop.
			SetDisplayedDesktop(0)
			displayedDesktop = GetDisplayedDesktop()
		endif
		
		BuildpnlDesktopControl(numDesktopsInPanel = numDesktopsInPanel)
		SetWindow pnlDesktopControl hook(ACL_DesktopControlHook)=ACL_DesktopControlHook
		STRUCT ACL_WindowDesktopsStr prefs
		// We can't load the preferences until the window is created since if the
		// preferences don't already exist, we use the current properties
		// of the panel and store new preferences. So the panel has to exist.
		LoadDesktopControlPrefs(prefs)
		
		// Check the preferences to see if the stored number of desktop
		// buttons is different than what is currently displayed. If it is,
		// then we will need to recreate the panel so we can
		// just quit here.
		numDesktops = GetNumDesktopButtonsInPanel()
		// Note: We only use the numDesktopsInPanel value loaded from preferences
		// if that parameter hasn't been set in this function call. Otherwise, we
		// use the value passed in as a parameter.
		if (ParamIsDefault(numDesktopsInPanel))
			if ((numtype(numDesktops) == 0) && numtype(prefs.numDesktopsInPanel) == 0 && prefs.numDesktopsInPanel > 0 && prefs.numDesktopsInPanel != numDesktops)
				SetNumDesktopButtonsInPanel(prefs.numDesktopsInPanel)
				SetDataFolder curDataFolder	
				return 0
			endif
		endif
		
		// AL 08Jul2011: We now only use the origin stored in the preferences and we don't
		// change the size of the panel.
		GetWindow pnlDesktopControl wsize
		Variable width = V_right - V_left
		Variable height = V_bottom - V_top
		MoveWindow/W=pnlDesktopControl prefs.panelCoords[0], prefs.panelCoords[1], prefs.panelCoords[0] + width, prefs.panelCoords[1] + height 	
		Variable errorNum = ChangeDisplayedDesktop(displayedDesktop)
		if (errorNum != 0)
			printf "Error %d in Initialize_pnlDesktopControl.\r", errorNum
		endif	
		SetDataFolder curDataFolder	
		
		// Save the panel's current information to the settings.
		SaveDesktopControlPrefs(prefs)
	else
		// If the panel already exists, check to see that it has the same number of numbered
		// desktops as the optional numDesktopsInPanel parameter, if it was used. If not
		// then rebuild the panel so that it has the correct number of buttons.
		numDesktops = GetNumDesktopButtonsInPanel()
		// Note: We only use the numDesktopsInPanel value loaded from preferences
		// if that parameter hasn't been set in this function call. Otherwise, we
		// use the value passed in as a parameter.
		if (!ParamIsDefault(numDesktopsInPanel))
			if ((numtype(numDesktops) == 0) && numDesktops != numDesktopsInPanel)
				SetNumDesktopButtonsInPanel(numDesktopsInPanel)
				return 0
			endif
		endif
	endif
	
	// Register a function provided by this module that responds to creation of any window
	// and assigns that window to the currently selected desktop.
	RegisterWindowCreatedHook()
End


// ********************
//  ACTION FUNCTIONS
// ********************
Function ButtonAssignDesktop(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	
	switch( ba.eventCode )
		case 2: // mouse up
			Variable currentVisibleDesktop = GetDisplayedDesktop()
			
			Variable desktopNum = str2num(GetUserData(ba.win, ba.ctrlName, "desktop"))
			
			// If the user holds down the shift key when pressing one of the assignment buttons,
			// all currently visibile windows that are not assigned to the Default desktop will be
			// assigned to the specified desktop. However, if the current visible desktop is the default
			// desktop, then all visible windows will be assigned to the specified desktop regardless of
			// the window's current assignment. Note that if the current visibile desktop isn't defined
			// (this usually is because the panel hasn't been initialized), the state of the Shift key
			// is ignored and only the top visible window is assigned.
			Variable assignToAllVisibleWindows = (ba.eventMod & 0x2) && (numtype(currentVisibleDesktop) == 0)
			Variable index = 0
			Variable thisWindowsCurrentDesktop
			String thisWindowName
			String listOfWindowsToAssign = ""
			// We need to make a list of all windows to assign before we actually
			// make assignments because when we assign windows they might be
			// hidden, which messes up getting all windows using WinName and index.
			do
				// Get the name (or title in the case of procedure windows) of the index'th window,
				// excluding windows that are not visible (hidden).
				thisWindowName = WinName(index, 4311, 1)
				
				if (cmpstr(thisWindowName, "") == 0)
					// No more windows
					break
				endif
					
				// Because WinName will return procedure windows, but those cannot be
				// operated on by SetWindow, which is later used to assign the window
				// to a virtual desktop, we need to make sure that the window name
				// returned from WinName is a type that can be operated on.
				if (WinType(thisWindowName) != 0)
					// Window can be assigned to a desktop.
					// Check that topWindowName isn't on the default desktop
					// unless the current visibile desktop is the default desktop,
					// in which case we go ahead and do the assignment.
					thisWindowsCurrentDesktop = GetWindowDesktop(thisWindowName)
					
					// Note that if assignToAllVisibleWindows is false, then we don't care what
					// the current visible desktop or the current window's desktop is, we just
					// do what we're told.
					if ((currentVisibleDesktop == 0 || thisWindowsCurrentDesktop != 0) || assignToAllVisibleWindows == 0)
						listOfWindowsToAssign = AddListItem(thisWindowName, listOfWindowsToAssign, ";", inf)
					endif
				else
					// Window cannot be assigned to a desktop.
					printf "Window %s cannot be assigned to a desktop.\r", thisWindowName
				endif
				
				index += 1
			while (assignToAllVisibleWindows)
			
			// Now do the actual assignments.
			Variable numWindows = ItemsInList(listOfWindowsToAssign, ";")
			Variable n
			For (n = 0; n < numWindows; n += 1)
				SetWindowDesktop(StringFromList(n, listOfWindowsToAssign, ";"), desktopNum)
			EndFor

			break
	endswitch

	return 0
End

Function ButtonShowDesktop(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			Variable desktopNum = str2num(GetUserData(ba.win, ba.ctrlName, "desktop"))
			Variable errorNum = ChangeDisplayedDesktop(desktopNum)
			if (errorNum != 0)
				printf "Error %d in ButtonShowDesktop().\r", errorNum
			endif
			break
	endswitch

	return 0
End

Function ButtonHelp(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			DisplayHelpTopic/Z "Window Desktops"
			if (V_Flag != 0)	// help topic not found
				DoAlert 0, "The ACL_WindowDesktops.ihf help file could not be found.  It should be in the same directory as the ACL_WindowDesktops.ipf procedure file."
			endif
			break
	endswitch

	return 0
End

Function ButtonOptions(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			PopupContextualMenu/N "WindowDesktopsOptionsMenu"
			break
	endswitch

	return 0
End

// ********************
//  AUXILLARY FUNCTIONS
// ********************
//**
// Determine what virtual desktop a window is currently assigned to.
//
// @param windowName
// 	Name of window to check.
//
// @return
// 	The number of the desktop that windowName is assigned
// 	to or -1 if the window does not exist.
//*
Function GetWindowDesktop(windowName)
	String windowName
	Variable desktopNum
	
	// check to see if window exists
	Variable type = WinType(windowName)
	if (type && type != 13)		// exclude XOP target windows
		desktopNum = str2num(GetUserData(windowName, "", "ACL_desktopNum"))
		if (numtype(desktopNum) != 0)		// value is undefined
			desktopNum = 0		// show on all desktops
		else
			desktopNum = round(desktopNum)
		endif
	else
		desktopNum = -1		// window doesn't exist
	endif
	
	return desktopNum
End

//**
// Assign a window to a virtual desktop.
//
// @param windowName
// 	Name of window.
// @param desktopNum
// 	Number of desktop to assign window to.  If 0, window will be
// 	displayed on all desktops.  If >= 1, window will be displayed
// 	only on a specific desktop.
//
// @return
// 	Zero if the function is completed successfully or a negative
// 	value indicating an error code.
//*
Function SetWindowDesktop(windowName, desktopNum)
	String windowName
	Variable desktopNum
	Variable errorValue
	
	// make sure desktopNum parameter is valid
	if (numtype(desktopNum) == 0)		// value is a real number
		if (desktopNum >= 0)
			desktopNum = round(desktopNum)		// desktopNum must be an integer
		endif
	else
		errorValue = -1
		return errorValue
	endif
	
	// check to see if window exists
	Variable type = WinType(windowName)
	if (type)	
		if (type == 13)	// exclude XOP target windows
			printf "Can't assign a target window of an XOP to a desktop.\r"
			return 0
		else
			SetWindow $(windowName) userdata(ACL_desktopNum)=num2istr(desktopNum)
		endif
	else
		errorValue = -1		// window doesn't exist
	endif	
	
	if (errorValue == 0)		// If there is no error, call ChangeDisplayedDesktop so the window just set is hidden or visible as appropriate.
		UpdateWindowShowHide(windowName)
	endif
	
	return errorValue		// 0 if successful
End

//**
// Update a window's show/hide status as approrpiate.
//
// @param windowName
//*
Function UpdateWindowShowHide(windowName)
	String windowName
	
	Variable currentDesktop = GetDisplayedDesktop()
	Variable windowsDesktop = GetWindowDesktop(windowName)
	Variable hide
	if (numtype(currentDesktop) == 0 && windowsDesktop >= 0)	// no error
		if (currentDesktop == -1)		// show ALL windows
			hide = 0
		elseif (windowsDesktop == 0 || windowsDesktop == currentDesktop)
			hide = 2		// show this window
		else
			hide = 1		// hide this window
		endif
		SetWindow $(windowName) hide=hide, needUpdate=1
	endif
End

//**
// Get the number of the desktop that is currently displayed.
//
// @param globalOutputVarPathStr
// 	[OPTIONAL] A string containing the full path to a global
// 	(numeric) variable.  See code comment below for an
// 	explanation of why this parameter might be useful.  This
// 	variable needs to exist at the time this function is called
// 	to be used but will not produce an error if it does not exist.
// @return
// 	A number indicating the currently displayed desktop.
// 	If the currentDisplayedDesktop variable does not exist,
// 	NaN will be returned.
//*
Function GetDisplayedDesktop([globalOutputVarPathStr])
	String globalOutputVarPathStr
	
	Variable currentDesktop = NaN
	
	NVAR/Z currentDisplayedDesktop = root:Packages:ACL_WindowDesktops:currentDisplayedDesktop
	if (NVAR_Exists(currentDisplayedDesktop))
		currentDesktop = currentDisplayedDesktop		
	endif
	
	// If the globalOutputVarPathStr parameter was provided,
	// try to put the value of the currently displayed desktop
	// into the global variable represented by the parameter.
	// This functionality is included so that another package
	// implemented as an independent module can call
	// this function via Execute and still get the information
	// it needs.
	if (!ParamIsDefault(globalOutputVarPathStr))
		NVAR/Z globalOutputVar = $(globalOutputVarPathStr)
		if (NVAR_Exists(globalOutputVar))
			globalOutputVar = currentDesktop
		endif
	endif
	
	return currentDesktop
End

//**
// Set the number of the currently displayed desktop.
// Instead of changing the value directly, other functions should
// call this function to set the value.
//
// @param desktopNum
// 	The value of the currently displayed desktop.  A value
// 	of -1 means "All", 0 means "Default", and a positive
//	integer represents that desktop.
//*
Function SetDisplayedDesktop(desktopNum)
	Variable desktopNum
	
	NVAR/Z currentDisplayedDesktop = root:Packages:ACL_WindowDesktops:currentDisplayedDesktop
	if (!NVAR_Exists(currentDisplayedDesktop))
		// Make sure the data folder where this variable will go exists.
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:ACL_WindowDesktops
		Variable/G root:Packages:ACL_WindowDesktops:currentDisplayedDesktop
		NVAR currentDisplayedDesktop = root:Packages:ACL_WindowDesktops:currentDisplayedDesktop
	endif
	currentDisplayedDesktop = desktopNum
End

//**
// Chang the virtual desktop that is currently displayed.
//
// @param newDesktopNum
// 	Number of desktop to switch to (if >= 1).  Additionally,
// 	there are a few special cases for this parameter:
// 	0	Show all windows that are present on any desktop, including
//		windows that have not yet been assigned to a desktop.
// 	-1	Show all windows, regardless of the desktop they are assigned to.
// @param forceUpdate
// 	[OPTIONAL]  If set to 1, the desktop will be "changed" even if
// 	newDesktopNum is the same as the current desktop.  This can be
// 	used to force a refresh of the windows currently being displayed.
//
// @return
// 	Zero if there was no error or a negative number representing the error code.
//*
Function ChangeDisplayedDesktop(newDesktopNum, [forceUpdate])
	Variable newDesktopNum
	Variable forceUpdate		// set to 1 if the desktop should be changed even if currentDesktop = newDesktopNum

	if (ParamIsDefault(forceUpdate))
		forceUpdate = 0
	endif
	
	// Only force an update of the windows if the displayed desktop is changing.
	Variable currentDesktop = GetDisplayedDesktop()
	if ((numtype(currentDesktop) != 0) || (currentDesktop != newDesktopNum))
		forceUpdate = 1
	endif
	
	Variable errorValue
	// make sure newDesktopNum is valid
	if (numtype(newDesktopNum) != 0)		// newDesktopNum is invalid
		errorValue = -1
		return errorValue		// error: invalid newDesktopNum
	elseif (newDesktopNum < -1)
		errorValue = -1
		return errorValue		// error: invalid newDesktopNum
	else
		newDesktopNum = round(newDesktopNum)
	endif

	// Sets the global variable that keeps track of which desktop
	// is currently displayed.
	SetDisplayedDesktop(newDesktopNum)

	if (forceUpdate == 1)
		// get a list of all windows that GetWindow/SetWindow can be used with
		String windowList = WinList("*", ";", "WIN:87")	// include all window types EXCEPT procedure windows, since they don't have names
		Variable numWindows = ItemsInList(windowList, ";")
		Variable n, winDesktopNum, hide
		String currentWinName
		For (n=0; n<numWindows; n+=1)
			currentWinName = StringFromList(n, windowList, ";")
			UpdateWindowShowHide(currentWinName)
		EndFor
	Endif
	
	if (errorValue == 0)
		SetShowButtonColors(newDesktopNum, "pnlDesktopControl")
		
		// If the Wavemetrics GraphBrowserPanel is visible, then force it to update
		// so that if the user has unchecked the "Are invisible" checkbox on that 
		// panel the graphs displayed on the panel will be updated when desktops are changed.
		//
		// This is sort of a hack, because independent modules cannot call functions
		// in other independent modules other than by using Execute.  Ideally we'd just
		// create a WMWinHookStruct here, set the window name and event code, and
		// pass that to the GraphBrowser's window hook function.  Alas, global structures
		// do not (yet) exist in Igor Pro, so that won't work either.  We at least check
		// that the target function exists and that it takes the parameter we're prepared
		// to use in the call to the function in an attempt to avoid errors if WM changes
		// either of the functions GrfBrowserPanelWinProc() or UpdateGraphList().
		if (WinType("GraphBrowserPanel") == 7)		// The window is a panel.
			String updateFxInfo = FunctionInfo("WM_GrfBrowser#UpdateGraphList")
			if (strlen(updateFxInfo) > 0)
				Variable numParams = NumberByKey("N_PARAMS", updateFxInfo, ":", ";")
				Variable param0Type = NumberByKey("PARAM_0_TYPE", updateFxInfo, ":", ";")
				if (numParams == 1 && param0Type == 8192)		// param0Type is a string
					Execute "WM_GrfBrowser#UpdateGraphList(\"GraphBrowserPanel\")"
				endif
			endif
		endif
	endif	
	return errorValue
End

//**
// Set the colors of the buttons on the Desktop Control panel.
//
// @param desktopNum
// 	The number of the desktop that is currently displayed.
// @param windowName
// 	The name of the Desktop Control panel.
//*
Function SetShowButtonColors(desktopNum, windowName)
	Variable desktopNum
	String windowName
	
	Variable errorNum
	DoWindow pnlDesktopControl
	if (V_Flag)
		String buttonList, currentCtrlName
		Variable n, numButtons
		Variable desktopControlled		// the number of the desktop controlled by the button
		buttonList = ControlNameList(windowName, ";", "ButtonShow*")
		numButtons = ItemsInList(buttonList, ";")
		For (n=0; n<numButtons; n+=1)
			currentCtrlName = StringFromList(n, buttonList, ";")
			ControlInfo/W=$(windowName) $(currentCtrlName)
			if (abs(V_flag) == 1)	// control is a button
				desktopControlled = str2num(GetUserData(windowName, currentCtrlName, "desktop"))
				if (numtype(desktopControlled) == 0)
					if (desktopControlled == desktopNum)
						Button $(currentCtrlName) win=$(windowName), fColor=(0,43520,65280)		// blue button
					else
						Button $(currentCtrlName) win=$(windowName), fColor=(0,0,0)				// normal colored button
					endif
				endif
			endif			
		EndFor
	endif
End

//**
// Set a hook function for the Igor AfterWindowCreatedHook hook type.
//*
Function RegisterWindowCreatedHook()
	SetIgorHook AfterWindowCreatedHook = Hook_WindowCreated
End
 
// ********************
//  HOOK FUNCTIONS
// ********************
Function ACL_DesktopControlHook(str)
	STRUCT WMWinHookStruct &str
	Variable statusCode = 0
	Switch (str.eventCode)
		Case 12:	// window was moved: store new coordinates
			STRUCT ACL_WindowDesktopsStr prefs
			SaveDesktopControlPrefs(prefs)
			break
		default:			
	EndSwitch
	return statusCode
End

Function Hook_WindowCreated(windowNameStr, type)
	String windowNameStr
	Variable type

	Variable currentDesktop = GetDisplayedDesktop()
	if (numtype(currentDesktop) == 0 && currentDesktop > 0)
		SetWindowDesktop(windowNameStr, currentDesktop)
	endif
	return 0
End

// ********************
//  PACKAGE PREFS LOADING/SAVING
// ********************
Function LoadDesktopControlPrefs(s)
	STRUCT ACL_WindowDesktopsStr &s
	
	// This loads preferences from disk if they exist on disk.
	LoadPackagePreferences kPackageName, kPreferencesFileName, kPreferencesRecordID, s

	// If error, prefs not found or not compatible, initialize them.
	if (V_flag!=0 || V_bytesRead==0 || s.version!=K_CURRENTPREFSVERSION)
		SaveDesktopControlPrefs(s)	// Create default prefs file.
	endif
End

Function SaveDesktopControlPrefs(s)
	STRUCT ACL_WindowDesktopsStr &s
	
	// fill in structure with current values
	s.version = K_CURRENTPREFSVERSION
	GetWindow pnlDesktopControl wsize			// get current window coordinates
	s.panelCoords[0] = V_left		// Left
	s.panelCoords[1] = V_top		// Top
	
	// The right and bottom coordinates are no longer used by this package
	// but we still save them in case they need to be used in a later version.
	s.panelCoords[2] = V_right		// Right
	s.panelCoords[3] = V_bottom	// Bottom
	
	Variable numDesktops = GetNumDesktopButtonsInPanel()
	if ((numtype(numDesktops) != 0) || numDesktops < 0)
		s.numDesktopsInPanel = 0
	else
		s.numDesktopsInPanel = numDesktops
	endif
	
	Variable i
	for(i=0; i<99; i+=1)
		s.reserved[i] = 0
	endfor

	SavePackagePreferences kPackageName, kPreferencesFileName, kPreferencesRecordID, s
	return 0	
End

// ************************
// STATIC FUNCTIONS
// ************************
//**
// Private function that returns the number of numbered desktops with
// buttons in the panel. If the number cannot be determined, NaN will
// be returned.
//*
static Function GetNumDesktopButtonsInPanel()
	if (WinType(kACLWindowDesktopsPnlName) != 0)
		String numAsString = GetUserData(kACLWindowDesktopsPnlName, "", "numDesktopsInPanel")
		return (str2num(numAsString))
	endif
	
	return NaN
End

//**
// Private function that sets the number of numbered desktops with
// buttons in the panel. If num is different than the current
// number of buttons, the panel will be killed and recreated.
//*
 static Function SetNumDesktopButtonsInPanel(num)
	Variable num
	
	Variable currentNum = GetNumDesktopButtonsInPanel()
	if ((numtype(currentNum) != 0) || (currentNum != num))
		Execute/Q/P/Z "KillWindow " + kACLWindowDesktopsPnlName
		Execute/Q/P/Z "ACL_WindowDesktops#Initialize_pnlDesktopControl(numDesktopsInPanel = " + num2istr(num) + ")"
	endif
End

//**
// Prompts the user to set the number of numbered desktop buttons to show in the panel.
//*
Function PromptSetNumDesktopButtons()
	Variable originalNumAvailable = GetNumDesktopButtonsInPanel()
	if (numtype(originalNumAvailable) != 0)
		originalNumAvailable = kDefaultNumDesktopsInPanel
	endif
	
	Variable numAvailable
	String promptString
	sprintf promptString, "Number of desktops that can be controlled from the panel (1-%d):", kMaximumNumDesktopsInPanel
	Prompt numAvailable, promptString
	
	do	
		numAvailable = originalNumAvailable
		DoPrompt "Settings", numAvailable
		
		if (V_flag == 1)
			// User hit cancel button
			return 0
		endif
		
		// Validate user input.
		if (numtype(numAvailable) != 0 || numAvailable < 1 || numAvailable > kMaximumNumDesktopsInPanel)
			// Do nothing so that user is prompted again.
		else
			break
		endif
		
	while (1)
	
	SetNumDesktopButtonsInPanel(numAvailable)
End

// This Picture was created from the Tango Icon Library file categories/applications-system.png
// The Tango icons are licensed under the public domain.
// http://tango.freedesktop.org/Tango_Icon_Library
// PNG: width= 48, height= 16
Picture SettingsIcon
	ASCII85Begin
	M,6r;%14!\!!!!.8Ou6I!!!!Q!!!!1#R18/!)TirYlFb,SOl48<(Ml5Q=!<aB,JX<3%`e2ItC2i$kZ
	7866cn:R6i*cREN[;?>NcKnRfQ?],%`+X(Amtfcp1&O_'B@OkpZ_'=X'2>,$[<0iea#XfaGGO[B'g7
	gk&W*-uF:+kbCTZKLM#hg:qJkP<utIGY/,j1e%9DS`Nrk-f<VSr6md^0:p\Y<CD1@i&>K2?37/b8Pk
	PFL3<CDuSa[Dgj`c52%Lf,Sk%J!$coO>e0C++L[K$Tc\_HD\eln5;_g5)!n6\Wp`ABCaUr)6UU$R2O
	ag\$jPMf/shL<aiT-:^6es&k+fW<87*TcT-fu'=)+`fkP=C(:"A?Yl'9Q&=QqeS!p6p`M(ji_Bs=Li
	a3+gr32Hh[%QUp_K2i/N;sJ6YEkKs'f,egp&n/-",aZ\C-kl`E"@4.GM]i?-JE1Z/&4I1=.jneEnKE
	+K-95bfdJr/KD6HU>cm?D_mtSm+$3r&'I,7o#mBnkiBlA50h[Q8U#`HYg:J[%[B=HX#g[/0,++*PpM
	8^A,oV48Dr`o8gM;(\G*tMgSgg3mEiu%io+0B8N.RkU=n"+rj!oU9W3`?EliX<\m>*,#7A/9^K-Rm;
	H`<Z[#DSP'>J1Slg]jBgW]mG";?=e8%'`c#+YLs<SME"\A:"A?IM&%FU0.F)'9/fem@?98mn;P*L=T
	=^8l`G6%38kTP9YQL,"l!G8dGA8AC-blYe+1a_1u^6WX3Tp_,Q47+&?H8%'Tk7Q9YQL,"Y0i[G.Scu
	f;g0\ad^[ke718%cICFrp31_)>6BEVZ7H)m/JM`'Up#n5d/lR5AVD;8*;9=0o=*/K`62BIr=r@0m53
	8C=R#r*m&?\l_$GQkY;;uK&^U5r?V=!8G0=!]Z[uqi_4I*YI$`$Q=f&F0dL_C-4lbS_;DOZQV:Y%8T
	\@NLEbV%q)RshJR?iDGAg>d[G5BXti?'f*[g^=*lO%$e$cSODP:?;.=+)a/%&>g?1X.KlQNk2("`pe
	oGjSL3!=\cA.)t?/Um?R*-Bi.ZCV)DW0L1&7rGXfg<WGK0&A[K#BcJ],Sr6lcM8^?VGU:9)#:eqR1m
	]_rFUk\Jj6Q.OWgo]0E6&"j?HJ:2S8f?hTs5!-AVndH40k/@0^dsh?"J;-CTjN/`9HT7oHr`k`srpd
	,&:<oTm:j%(E+;7/IMc8DHW:)WiDemWMt8dF48Oad;`Hqf/l&U3t7k67PG[$Qg@'$UM?iW^:MVKlMV
	^*hI!u;1?@:PgL=`_?4$D/p]f!tX\qo2:hQc#c;O0J^Ur1?/C'E+S'<9?*"K)n$A.a_hr/MSB`($4L
	NFLjnM6MDi_G`K:`KJc2Gmd-ZeKP/B,n*4YaWimF[*l47.!MQOVCagA#uQ6l5\F[U*pY8a78tQ"9JT
	(EjghFj1.1CTcaH;/_"[&=IaAdl'8tB=i&#seMbnK9%/jPG+?K\(L##7mRE&[]Go6ISSR&Zfk)"t2#
	AQ+j!<Ki`>3-N=?:Ti'L&-b>PnBuJk>mcrsQO3p]mco*u^>tJ_pG-!!#SZ:.26O@"J
	ASCII85End
End
