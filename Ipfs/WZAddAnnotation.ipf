//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma rtGlobals=1		// Use modern global access method
#include <All IP Procedures>
#include <Image Saver>
#include <PopupWaveSelector>
#pragma moduleName=startup    // traditional for static functions
//////////////////////////////////////////////////////////////////////////////////////////////////

menu "WZFunc"
	"AddAnnotation", AddAnno()
end

Window AddAnno() : Panel
	PauseUpdate; Silent 1		// building window...
	InitializeAnno()
	NewPanel/K=1 /W=(150,385,410,680)
	SetDrawLayer UserBack
	DrawText 135,148,"nm"
	DrawText 225,176,"nm"
	PopupMenu popup0,pos={10,10},size={140,20},proc=setDirection,title="Direction"
	PopupMenu popup0,mode=1,popvalue=root:Packages:annotations:direction,value= #"\"ZFU;ZFD;ZBU;ZBD\""
	SetVariable setvar2,pos={10,40},size={120,20},proc=setImageNum,value=root:Packages:annotations:ImageNum,title="Image # ",limits={1,inf,1}
	SetVariable setvar0,pos={10,70},size={120,20},proc=setBias,value=root:Packages:annotations:BiasVoltage,title="Bias V    ",limits={-10,10,0.1}
	SetVariable setvar1,pos={10,100},size={120,20},proc=setCurrent,value=root:Packages:annotations:Current,title="Current  ",limits={-inf,inf,10}
	PopupMenu popup1,pos={140,99},size={50,2},mode=1,popvalue="pA",value= #"\"pA;nA\"",proc=setCurrentUnit
	SetVariable setvar3,pos={10,130},size={120,20},title="Width     ",limits={-inf,inf,10},proc=setWidth,value=root:Packages:annotations:width
	CheckBox check0,pos={10,162},size={80,15},title="Not Square",value=root:Packages:annotations:NoSquare_Flag,proc=setNoSquare,side=1
	SetVariable setvar4,pos={100,160},size={120,20},title="Height",value=root:Packages:annotations:height,limits={-inf,inf,10},proc=setHeight
	CheckBox check1,pos={10,192},size={80,20},title="Customize ",value=root:Packages:annotations:Customize_Flag,proc=setCustomize,side=1
	SetVariable setvar5,pos={100,190},size={120,20},limits={-inf,inf,0},value=root:Packages:annotations:CustomStr,title=" ",proc=setCustomStr
	PopupMenu popup2,pos={10,220},size={120,20},title="Font Color",proc=setFontColor
	PopupMenu popup2,mode=1,popvalue="White",value= #"\"White;Black;Red\""
	PopupMenu popup3,pos={140,220},size={120,20},title="Size",proc=setFontSize
	PopupMenu popup3,mode=1,popvalue="18",value= #"\"12;14;16;18;20;22;24;36\""
	Button button0,pos={180,10},size={70,40},proc=ApplyAddo,title="Apply"
	Button button1,pos={180,55},size={70,30},proc=killAddo,title="Delete"
	DrawLine 7,250,251,250
	TitleBox title0,pos={10,260},size={235,25},labelBack=(52224,52224,52224)
	TitleBox title0,fSize=12,variable= root:Packages:annotations:finalAnnotation,fixedSize=1,title=" "
	SetWindow kwTopWin,hook=updataTopImageAnnoInfo
EndMacro

Function updataTopImageAnnoInfo(infoStr)
	String infoStr;
	Variable status= 0;
	String eventName= StringByKey("EVENT",infoStr);
	strswitch(eventName)
		case "activate":
			InitializeAnno();
			break
		case "kill":
			//killPICTs ExamplePic_1,ExamplePic_2,ExamplePic_3,ExamplePic_4,ExamplePic_5
			break
	endswitch
	
	return status
end


Function InitializeAnno()
	newdatafolder/O root:Packages
	newdatafolder/O root:Packages:annotations
	string TopGraphName=WMGetImageWave("")
	variable tempwidth=DimSize($(TopgraphName),0)*DimDelta($(TopgraphName),0)*10^9;
	variable tempheight=DimSize($(TopgraphName),1)*DimDelta($(TopgraphName),1)*10^9;
	string expstr="([[:alpha:]]+)([[:digit:]]+)"
	string tempdirection,tempimagenum;
	splitstring/E=(expstr) nameofwave($(TopGraphName)),tempdirection,tempimagenum;
	String dfSav= GetDataFolder(1)
	SetDataFolder root:Packages:annotations
	string/G direction=tempdirection;
	variable/G ImageNum=str2num(tempimagenum);
	variable/G BiasVoltage=-1
	variable/G Current=100
	string/G currentunit="pA"
	variable/G width=tempwidth
	variable/G height=tempheight
	string/G customStr=""
	variable/G fontColor=1
	string/G fontSize="18"
	variable/G NoSquare_Flag=0
	if(tempwidth!=tempheight)
		NoSquare_Flag=1
	endif
	variable/G Customize_Flag=0
	string/G finalAnnotation
	SetDataFolder dfSav
	updatFinalAnno();
End

Function updatFinalAnno()
	String dfSav= GetDataFolder(1)
	SetDataFolder root:Packages:annotations
	string/G direction
	variable/G ImageNum
	variable/G BiasVoltage
	variable/G Current
	string/G currentunit
	variable/G width
	variable/G height
	string/G customStr
	variable/G fontColor
	string/G fontSize
	variable/G NoSquare_Flag
	variable/G Customize_Flag
	string/G finalAnnotation
	if(Customize_Flag==1)
		finalAnnotation=CustomStr
	else
		if(NoSquare_Flag==0)
			finalAnnotation=direction+num2str(ImageNum)+", "+num2str(BiasVoltage)+"V, "+num2str(current)+currentunit+", "+ num2str(width)+"nm"
		else
			finalAnnotation=direction+num2str(ImageNum)+", "+num2str(BiasVoltage)+"V, "+num2str(current)+currentunit+", "+ num2str(width)+"nm"+" x "+num2str(height)+"nm"
		endif
	endif
	SetDataFolder dfSav
End


Function finalApply()
	String dfSav= GetDataFolder(1)
	SetDataFolder root:Packages:annotations
	variable/G fontColor
	string/G fontSize
	string/G finalAnnotation
	variable red,green,blue
	switch(fontColor)
		case 1:
			red=65535;green=65535;blue=65535;
			break;
		case 2:
			red=0; green=0;blue=0;
			break;
		case 3:
			red=65535; green=0;blue=0;
			break;
	endswitch
	TextBox/C/N=text0/F=0/B=1/G=(red,green,blue)/A=LT "\\Z"+fontSize+finalAnnotation
	SetDataFolder dfSav
End

Function setDirection(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa
	switch( pa.eventCode )
		case 2: // mouse up
			String dfSav= GetDataFolder(1)
			SetDataFolder root:Packages:annotations
			string/G direction=pa.popStr;
			SetDataFolder dfSav
			updatFinalAnno()
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function SetImageNum(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva
	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			String dfSav= GetDataFolder(1)
			SetDataFolder root:Packages:annotations
			variable/G ImageNum=dval
			SetDataFolder dfSav
			updatFinalAnno()
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function SetBias(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva
	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			String dfSav= GetDataFolder(1)
			SetDataFolder root:Packages:annotations
			variable/G BiasVoltage=dval
			SetDataFolder dfSav
			updatFinalAnno()
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function SetCurrent(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva
	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			String dfSav= GetDataFolder(1)
			SetDataFolder root:Packages:annotations
			variable/G Current=dval
			SetDataFolder dfSav
			updatFinalAnno()
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function setCurrentUnit(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa
	switch( pa.eventCode )
		case 2: // mouse up
			String dfSav= GetDataFolder(1)
			SetDataFolder root:Packages:annotations
			string/G CurrentUnit=pa.popStr;
			SetDataFolder dfSav
			updatFinalAnno()
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function SetWidth(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva
	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			String dfSav= GetDataFolder(1)
			SetDataFolder root:Packages:annotations
			variable/G Width=dval
			SetDataFolder dfSav
			updatFinalAnno()
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function SetHeight(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva
	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			String dfSav= GetDataFolder(1)
			SetDataFolder root:Packages:annotations
			variable/G Height=dval
			SetDataFolder dfSav
			updatFinalAnno()
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function setFontSize(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa
	switch( pa.eventCode )
		case 2: // mouse up
			String dfSav= GetDataFolder(1)
			SetDataFolder root:Packages:annotations
			string/G fontSize=pa.popStr;
			SetDataFolder dfSav
			updatFinalAnno()
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function setFontColor(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa
	switch( pa.eventCode )
		case 2: // mouse up
			String dfSav= GetDataFolder(1)
			SetDataFolder root:Packages:annotations
			variable/G fontColor=pa.popNum;
			SetDataFolder dfSav
			updatFinalAnno()
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function setNoSquare(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba
	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			String dfSav= GetDataFolder(1)
			SetDataFolder root:Packages:annotations
			variable/G noSquare_Flag=checked;
			SetDataFolder dfSav
			updatFinalAnno()
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function setCustomize(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba
	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			String dfSav= GetDataFolder(1)
			SetDataFolder root:Packages:annotations
			variable/G Customize_Flag=checked;
			SetDataFolder dfSav
			updatFinalAnno()
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function SetCustomStr(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva
	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			String dfSav= GetDataFolder(1)
			SetDataFolder root:Packages:annotations
			string/G CustomStr=sval;
			SetDataFolder dfSav
			updatFinalAnno()
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End


Function ApplyAddo(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			finalApply()
			// click code here
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End


Function killAddo(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			TextBox/K/N=text0
			// click code here
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End