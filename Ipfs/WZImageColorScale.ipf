//////////////////////////////////////////////////////////////////////////////////////////////////

// Created by Wenhan Zhang

// This file is mainly used for mapping images with different customized color scales,
// which is not included in original Igor program.
//
//Claim:
//If new custom colorbar is added, the following functions should be updated:
//	1. colorbar{x}() should be defined to assign values to cindex wave. See colorbar1() for the example format.
//	2. CreateExampleColorBar() needs updating, the format is seen inside the function
//	3. UpdateColorTable(): new case should be added in the "switch" structure
//	4. In the main window "Window setColorScale() : Panel"
//		DrawPICT 410,95,1,1,ExamplePic_{n}
//		DrawText 341,110,"Colorbar {n}"
//		PopupMenu value: needs new values
//
//
//

//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma rtGlobals=3		// Use modern global access method
#include <All IP Procedures>
#include <Image Saver>
#include <PopupWaveSelector>
#pragma moduleName=startup    // traditional for static functions
//////////////////////////////////////////////////////////////////////////////////////////////////

//This function is used to display this procedure file conveniencely
function CallColor()		
	DisplayProcedure/W=$"ImageColorScale.ipf"
end

menu "WZFunc"
	"setColorScale", setColorScale()
end

Window setColorScale() : Panel
	PauseUpdate; Silent 1		// building window...
	CreateExampleColorBar();
	NewPanel/K=1 /W=(662,727,1154,961)
	SetDrawLayer UserBack
	DrawText 10,28,"Top Image"
	DrawText 341,30,"Colorbar 1"
	DrawText 341,50,"Colorbar 2"
	DrawText 341,70,"Colorbar 3"
	DrawText 341,90,"Colorbar 4"
	DrawText 341,110,"Colorbar 5"
	DrawText 341,130,"Colorbar 6"
	DrawText 341,150,"Colorbar 7"
	DrawText 341,170,"Colorbar 8"
	DrawPICT 410,15,1,1,ExamplePic_1
	DrawPICT 410,35,1,1,ExamplePic_2
	DrawPICT 410,55,1,1,ExamplePic_3
	DrawPICT 410,75,1,1,ExamplePic_4
	DrawPICT 410,95,1,1,ExamplePic_5
	DrawPICT 410,115,1,1,ExamplePic_6
	DrawPICT 410,135,1,1,ExamplePic_7
	DrawPICT 410,155,1,1,ExamplePic_8
	InitializePara();
	Button Button0,pos={177,44},size={136,20},proc=UpdateColorTableProc,title="Update ColorTable"
	Button Button1,pos={177,12},size={136,20},proc=AddColorBarProc,title="Add ColorBar"
	Button Button2,pos={340,190},size={136,20},proc=setColorTableHelp,title="Get Help"
	TitleBox title0,pos={74,10},size={97,23},labelBack=(52224,52224,52224)
	TitleBox title0,variable= root:Packages:customColorTable:topImageName,anchor= LC,fixedSize=1
	PopupMenu popup0,pos={8,44},size={164,21},proc=chooseColorTable,title="ColorTable"
	PopupMenu popup0,mode=3,popvalue="Custom Color 1",value= #"\"Custom Color 1;Custom Color 2;Custom Color 3;Custom Color 4;Custom Color 5;Custom Color 6;Custom Color 7;Custom Color 8\""
	Slider slider0,pos={13,142},size={300,19},proc=setLowerLimit
	Slider slider0,limits={ root:Packages:customColorTable:zMin, root:Packages:customColorTable:zMax,0},variable= root:Packages:customColorTable:LowerLimit,vert= 0,ticks= 0
	Slider slider1,pos={14,201},size={300,19},proc=setUpperLimit
	Slider slider1,limits={root:Packages:customColorTable:zMin, root:Packages:customColorTable:zMax,0},variable= root:Packages:customColorTable:UpperLimit,vert= 0,ticks= 0
	GroupBox group0,pos={-1,100},size={328,4},frame=0,fStyle=1
	SetVariable setvar0,pos={13,174},size={160,18},proc=SetLimitProc
	SetVariable setvar0,limits={-inf,inf,5e-12},value= root:Packages:customColorTable:UpperLimit,live= 1
	SetVariable setvar1,pos={12,108},size={160,18},proc=SetLimitProc
	SetVariable setvar1,limits={-inf,inf,5e-12},value= root:Packages:customColorTable:LowerLimit,live= 1
	GroupBox group1,pos={327,10},size={4,226},frame=0
	CheckBox check0,pos={10,77},size={130,15},proc=SetLogScaleProc, variable= root:Packages:customColorTable:imageInlogscale,title="Display In Log Scale"
	CheckBox check0,value= 0,side= 1
	SetWindow kwTopWin,hook=updataTopImageProc
EndMacro

//This function operates every time the setColorScale window is activated (brought to top)
Function updataTopImageProc(infoStr)
	String infoStr;
	Variable status= 0;
	String eventName= StringByKey("EVENT",infoStr);
	strswitch(eventName)
		case "activate":
			UpdateTopImagePara();
			UpdataSliders();
			status= 1
			break
		case "kill":
			//killPICTs ExamplePic_1,ExamplePic_2,ExamplePic_3,ExamplePic_4,ExamplePic_5
			break
	endswitch
	
	return status
end


//This function initializes all the necessary global parameters
Function InitializePara()
	newdatafolder/O root:Packages
	newdatafolder/O root:Packages:customColorTable
	String dfSav= GetDataFolder(1)
	SetDataFolder root:Packages:customColorTable
	string/G topImageName=WMTopImageName();
	string/G topGraphName=WMTopImageGraph();
	string/G WavePath=WMGetImageWave("");
	wave data=$(wavepath);
	variable zMi=wavemin(data);
	variable zMa=wavemax(data);
	variable/G zMin =zMi-(zMa-zMi)*0.1;
	variable/G zMax=zMa+(zMa-zMi)*0.1;
	variable/G LowerLimit=zMin;
	variable/G UpperLimit=zMax;
	variable/G colorTableIndex;
	variable/G imageInlogscale=0;
	if(colorTableIndex==0)
		colorTableIndex=1;
	endif
	SetDataFolder dfSav
End


//When the top image is changed, this function updates all relevant global variables,
//making suring the operation is always on the top image.
Function UpdateTopImagePara()
	String dfSav= GetDataFolder(1);
	SetDataFolder root:Packages:customColorTable;
	string newTopGraph=WMTopImageGraph();
	string/G topGraphName;
	string/G topImageName;
	if(cmpstr(newTopGraph,topGraphName)!=0)
		InitializePara();
	endif
	SetDataFolder dfSav;
End


Function UpdateColorTableProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			UpdateColorTable();
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function setColorTableHelp(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			DisplayHelpTopic "SetColorScale"
			break;
		case -1:
			break;
	endswitch
End

Function UpdateColorTable()
	String dfSav= GetDataFolder(1)
	SetDataFolder root:Packages:customColorTable
	variable/G LowerLimit, UpperLimit
	string/G topGraphName;
	variable/G colorTableIndex;
	variable/G imageInlogscale;
	string/G topImageName;
	string colortablename=topGraphName+"_CT"+num2str(colorTableIndex);
	if( !WaveExists($colortablename))
		make/O/N=(1000,3) $colortablename;
	endif
	wave colortable=$colortablename;
	switch(colorTableIndex)
		case 1:
			colorbar1(colortable);
			break;
		case 2:
			colorbar2(colortable);
			break;
		case 3:
			colorbar3(colortable);
			break;
		case 4:
			colorbar4(colortable);
			break;
		case 5:
			colorbar5(colortable);
			break;
		case 6:
			colorbar6(colortable);
			break;
		case 7:
			colorbar7(colortable);
			break;
		case 8:
			colorbar8(colortable);
			break;
	endswitch
	if(imageInlogscale==1)
		variable/G zMin=-12;
		variable/G zMax=-6;
	else
		string/G wavepath;
		variable/G zMin=wavemin($(wavepath))-0.1*(wavemax($(wavepath))-wavemin($(wavepath)))
		variable/G zMax=wavemax($(wavepath))+0.1*(wavemax($(wavepath))-wavemin($(wavepath)))
	endif
	UpdataSliders();
	setScale/I x LowerLimit, UpperLimit,"",colortable;
	string CTpath="root:Packages:customColorTable:"+colortablename;
	SetDataFolder dfSav
	ModifyImage $topImageName cindex= $CTpath; 
	if(imageInlogscale==1)
		ModifyImage $topImageName log=1;
	else
		ModifyImage $topImageName log=0;
	endif
End



Function AddColorBarProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			ModifyGraph margin(right)=72;
			String dfSav= GetDataFolder(1)
			SetDataFolder root:Packages:customColorTable
			variable/G zMin;
			variable/G zMax;
			//ColorScale/C/N=text0/F=0/B=1/A=RC/X=0.00/Y=0.00/E image=Topo,nticks=8, axisRange={zMin,zMax}
			ColorScale/C/N=text0/F=0/B=1/A=RC/X=0.00/Y=0.00/E image=Topo,nticks=8
			SetDataFolder dfSav;
			break;
		case -1: // control being killed
			break
	endswitch
	return 0
End


Function chooseColorTable(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa
	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			Variable/G root:Packages:customColorTable:colorTableIndex=pa.popNum
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End


Function changeColorTableScaling()
	String dfSav= GetDataFolder(1)
	SetDataFolder root:Packages:customColorTable
	variable/G LowerLimit, UpperLimit
	variable/G imageInlogscale;
	string/G topGraphName;
	variable/G colorTableIndex;
	string colortablename=topGraphName+"_CT"+num2str(colorTableIndex);
	wave colortable=$colortablename;
	if(imageInlogscale==0)
		setScale/I x LowerLimit, UpperLimit,"",colortable;
	else
		setScale/I x 10^(LowerLimit), 10^(UpperLimit),"",colortable;
	endif
	SetDataFolder dfSav
End


Function UpdataSliders()
	String dfSav= GetDataFolder(1)
	SetDataFolder root:Packages:customColorTable
	variable/G zMin;
	variable/G zMax;
	variable/G LowerLimit=zMin;
	variable/G UpperLimit=zMax;
	variable/G imageInlogscale;
	killcontrol slider0
	killcontrol slider1
	Slider slider0,pos={13,142},size={300,19},proc=setLowerLimit
	Slider slider0,limits={zMin,zMax,0},variable= LowerLimit,vert= 0,ticks= 0
	Slider slider1,pos={14,201},size={300,19},proc=setUpperLimit
	Slider slider1,limits={zMin,zMax,0},variable= root:Packages:customColorTable:UpperLimit,vert= 0,ticks= 0
	SetDataFolder dfSav;
End

Function setLowerLimit(sa) : SliderControl
	STRUCT WMSliderAction &sa
	switch( sa.eventCode )
		case -1: // control being killed
			break
		default:
			if( sa.eventCode & 1 ) // value set
				Variable curval = sa.curval
				variable/G root:Packages:customColorTable:LowerLimit=sa.curval;
				changeColorTableScaling();
			endif
			break
	endswitch

	return 0
End

Function setUpperLimit(sa) : SliderControl
	STRUCT WMSliderAction &sa
	switch( sa.eventCode )
		case -1: // control being killed
			break
		default:
			if( sa.eventCode & 1 ) // value set
				Variable curval = sa.curval
				variable/G root:Packages:customColorTable:UpperLimit=sa.curval;
				changeColorTableScaling();
			endif
			break
	endswitch

	return 0
End


Function SetLimitProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
			changeColorTableScaling()
		case 2: // Enter key
			changeColorTableScaling()
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			changeColorTableScaling()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function CreateExampleColorBar()
	make/N=(100,10) $("ExampleColorBarImage")
	wave CB= $("ExampleColorBarImage")
	CB=p;
	make/O/N=(1000,3) $("ExampleCindex");
	wave CT=$("ExampleCindex");
	setScale/I x -1, 100,"",CT;
	ShowTopograph(CB);
	ModifyGraph width=60,height=12
	ModifyGraph margin=1
	ModifyGraph axThick=1
	modifyimage $(WMTopImageName()), cindex= CT;
	colorbar1(CT);
	SavePICT/E=-8/B=100 as "Clipboard"
	LoadPICT/O/Q "ClipBoard", ExamplePic_1
	colorbar2(CT);
	SavePICT/E=-8/B=100 as "Clipboard"
	LoadPICT/O/Q "ClipBoard", ExamplePic_2
	colorbar3(CT);
	SavePICT/E=-8/B=100 as "Clipboard"
	LoadPICT/O/Q "ClipBoard", ExamplePic_3
	colorbar4(CT);
	SavePICT/E=-8/B=100 as "Clipboard"
	LoadPICT/O/Q "ClipBoard", ExamplePic_4
	colorbar5(CT);
	SavePICT/E=-8/B=100 as "Clipboard"
	LoadPICT/O/Q "ClipBoard", ExamplePic_5
	colorbar6(CT);
	SavePICT/E=-8/B=100 as "Clipboard"
	LoadPICT/O/Q "ClipBoard", ExamplePic_6
	colorbar7(CT);
	SavePICT/E=-8/B=100 as "Clipboard"
	LoadPICT/O/Q "ClipBoard", ExamplePic_7
	colorbar8(CT);
	SavePICT/E=-8/B=100 as "Clipboard"
	LoadPICT/O/Q "ClipBoard", ExamplePic_8
	killWindow $winName(0,1);
	killwaves CT,CB;
end

Function SetLogScaleProc(cba):CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			Variable/G root:Packages:customColorTable:imageInlogscale=checked;
			break;
		case -1: // control being killed
			break
	endswitch
	return 0
End


///////////////////////////////////////////////////////////////////////////////////////////////////////

//The following functions generate the index waves of custom colorscale tables. When adding new colorscale,
//just writing a new function with higher index with the same frame. Easy to expand.
function colorbar1(data)
	wave data
	variable i
	for(i=0;i<51;i+=1)
		data[999-i][2]=(36-i*0.64)*256;
	endfor
	for(i=50;i<176;i+=1)
		data[999-i][2]=(4+0.208*(i-50))*256
	endfor
	for(i=175;i<451;i+=1)
		data[999-i][2]=(30+10/275*(i-175))*256
	endfor	
	for(i=450;i<751;i+=1)
		data[999-i][2]=(40+19/30*(i-450))*256
	endfor	
	for(i=750;i<1000;i+=1)
		data[999-i][2]=(230-23/25*(i-750))*256
	endfor
	for(i=0;i<420;i+=1)
		data[999-i][1]=(235-0.5*i)*256
	endfor
	for(i=420;i<500;i+=1)
		data[999-i][1]=(25+0.1*(i-420))*256
	endfor
	for(i=500;i<750;i+=1)
		data[999-i][1]=(33+0.6*(i-500))*256
	endfor
	for(i=750;i<1000;i+=1)
		data[999-i][1]=(183-183/250*(i-750))*256
	endfor

	for(i=0;i<270;i+=1)
		data[999-i][0]=(243-8/27*(i))*256
	endfor
	for(i=270;i<445;i+=1)
		data[999-i][0]=(163+74/175*(i-270))*256
	endfor
	for(i=445;i<610;i+=1)
		data[999-i][0]=(237-63/55*(i-445))*256
	endfor
	for(i=610;i<795;i+=1)
		data[999-i][0]=(48+52/185*(i-610))*256
	endfor
	for(i=795;i<1000;i+=1)
		data[999-i][0]=(100-100/205*(i-795))*256
	endfor
end


function colorbar2(data)
	wave data
	variable i
	
	for(i=0;i<220;i+=1)
		data[i][2]=(130 + 7/22*i)*256;
	endfor
	for(i=220;i<494;i+=1)
		data[i][2]=(200+16/274*(i-220))*256
	endfor
	for(i=494;i<1000;i+=1)
		data[i][2]=(216-68/253*(i-494))*256
	endfor
	
	for(i=0;i<210;i+=1)
		data[i][1]=(80 + 83/210*i)*256;
	endfor
	for(i=210;i<350;i+=1)
		data[i][1]=(163+37/140*(i-210))*256
	endfor
	for(i=350;i<510;i+=1)
		data[i][1]=(200+45/160*(i-350))*256
	endfor	
	for(i=510;i<1000;i+=1)
		data[i][1]=(245 - 165/490*(i-510))*256;
	endfor
	
	for(i=0;i<205;i+=1)
		data[i][0]=(80 + 38/205*i)*256;
	endfor
	for(i=205;i<510;i+=1)
		data[i][0]=(118+130/305*(i-205))*256
	endfor
	for(i=510;i<1000;i+=1)
		data[i][0]=(248 - 77/490*(i-510))*256;
	endfor	
end


function colorbar3(data)
	wave data
	variable i
	
	for(i=0;i<142;i+=1)
		data[999-i][0]=(256 - 25/142*i)*256-1;
	endfor
	for(i=142;i<270;i+=1)
		data[999-i][0]=(231+20/128*(i-142))*256;
	endfor
	for(i=270;i<575;i+=1)
		data[999-i][0]=(251-174/305*(i-270))*256
	endfor
	for(i=575;i<1000;i+=1)
		data[999-i][0]=(77-77/425*(i-575))*256
	endfor
	
	for(i=0;i<1000;i+=1)
		data[999-i][1]=(256-i*256/1000)*256-1
	endfor
	for(i=0;i<265;i+=1)
		data[999-i][2]=(256 - 236/265*i)*256-1;
	endfor
	for(i=265;i<575;i+=1)
		data[999-i][2]=(20+134/310*(i-265))*256-1;
	endfor
	for(i=575;i<1000;i+=1)
		data[999-i][2]=(154-154/425*(i-575))*256
	endfor
end


function colorbar4(data)
	wave data
	variable i
	for(i=0;i<1000;i+=1)
		data[i][0]=(28+0.18*i)*256
		data[i][1]=i*256*0.2
		data[i][2]=(96+i*0.16)*256
	endfor
end

function colorbar5(data)
	wave data
	variable i
	for(i=0;i<500;i+=1)
		data[i][0]=257*(97/500*i)
		data[i][1]=257*(i*5/500)
		data[i][2]=257*(250/500*i)
	endfor
	for(i=500;i<1000;i+=1)
		data[i][0]=257*(97+(i-500)*158/500)
		data[i][1]=257*(5+(i-500)*250/500)
		data[i][2]=257*(250+(i-500)*5/500)
	endfor
end

function colorbar5_nonlinear(data)
	wave data
	variable i
	for(i=0;i<500;i+=1)
		data[i][0]=97/250000*i^2*256
		data[i][1]=5/250000*i^2*256
		data[i][2]=250/250000*i^2*256
	endfor
	for(i=500;i<970;i+=1)
		data[i][0]=(-159/220900*(i-970)^2+256)*256-1
		data[i][1]=(-251/220900*(i-970)^2+256)*256-1
		data[i][2]=(-6/220900*(i-970)^2+256)*256-1
	endfor
	for(i=970;i<1000;i+=1)
		data[i][0]=255*257
		data[i][1]=(1000-i)/50*257*255;
		data[i][2]=(1000-i)/50*257*255;
	endfor
	
end

function colorbar6(data)
	wave data
	variable i,color1_R, color1_G, color1_B, color2_R, color2_G, color2_B
	variable color0_R, color0_G, color0_B, color_end_R, color_end_G, color_end_B
	variable color1_pos,color2_pos
	color1_R=76; color1_G=21; color1_B=105;
	color2_R=239; color2_G=175; color2_B=43; 
	color0_R=0; color0_G=0; color0_B=0;
	color_end_R=255; color_end_G=255; color_end_B=255; 
	color1_pos=333; color2_pos=750;
	for(i=0;i<color1_pos;i+=1)
		data[i][0]=(color0_R+i/color1_pos*(color1_R-color0_R))*256
		data[i][1]=(color0_G+i/color1_pos*(color1_G-color0_G))*256
		data[i][2]=(color0_B+i/color1_pos*(color1_B-color0_B))*256
	endfor
	for(i=color1_pos;i<color2_pos;i+=1)
		data[i][0]=((color1_R+(i-color1_pos)*(color2_R-color1_R)/(color2_pos-color1_pos)))*256
		data[i][1]=((color1_G+(i-color1_pos)*(color2_G-color1_G)/(color2_pos-color1_pos)))*256
		data[i][2]=((color1_B+(i-color1_pos)*(color2_B-color1_B)/(color2_pos-color1_pos)))*256
	endfor
	for(i=color2_pos;i<1000;i+=1)
		data[i][0]=((color2_R+(i-color2_pos)*(color_end_R-color2_R)/(1000-color2_pos)))*256
		data[i][1]=((color2_G+(i-color2_pos)*(color_end_G-color2_G)/(1000-color2_pos)))*256
		data[i][2]=((color2_B+(i-color2_pos)*(color_end_B-color2_B)/(1000-color2_pos)))*256
	endfor
end

function colorbar7(data)
	wave data
	variable i
	
	for(i=0;i<142;i+=1)
		data[999-i][0]=(256 - 25/142*i)*256-1;
	endfor
	for(i=142;i<270;i+=1)
		data[999-i][0]=(231+20/128*(i-142))*256;
	endfor
	for(i=270;i<575;i+=1)
		data[999-i][0]=(251-174/305*(i-270))*256
	endfor
	for(i=575;i<900;i+=1)
		data[999-i][0]=(77-77/425*(i-575))*256
	endfor
	
	for(i=0;i<900;i+=1)
		data[999-i][1]=(256-i*256/1000)*256-1
	endfor
	for(i=0;i<265;i+=1)
		data[999-i][2]=(256 - 236/265*i)*256-1;
	endfor
	for(i=265;i<575;i+=1)
		data[999-i][2]=(20+134/310*(i-265))*256-1;
	endfor
	for(i=575;i<900;i+=1)
		data[999-i][2]=(154-154/425*(i-575))*256
	endfor
	
	for(i=900;i<1000;i+=1)
		data[999-i][0]=(98+158/99*(i-900))*256-1
		data[999-i][1]=(25+231/99*(i-900))*256-1
		data[999-i][2]=(36+220/99*(i-900))*256-1
	endfor
	
end

function colorbar8_1(data)
	wave data
	variable i
	for(i=0;i<250;i+=1)
		data[i][0]=(127+i*(204-127)/250)*256-1
		data[i][1]=(127+i*(102-127)/250)*256-1
		data[i][2]=(127+i*(0-127)/250)*256-1
	endfor

	for(i=250;i<500;i+=1)
		data[i][0]=(204+(i-250)*(256-204)/250)*256-1
		data[i][1]=(102+(i-250)*(217-102)/250)*256-1
		data[i][2]=(0+(i-250)*(102-0)/500)*256-1
	endfor
	
	for(i=500;i<1000;i+=1)
		data[i][0]=(256+(i-500)*(256-256)/499)*256-1
		data[i][1]=(217+(i-500)*(256-217)/499)*256-1
		data[i][2]=(102+(i-500)*(256-102)/499)*256-1
	endfor	
end

function colorbar8_2(data)
	wave data;
	variable i;
	
	for(i=0;i<500;i+=1)
		data[i][0]=(256+i*(127-256)/499)*256-1
		data[i][1]=(256+i*(127-256)/499)*256-1
		data[i][2]=(256+i*(127-256)/499)*256-1
	endfor		
	
	for(i=500;i<750;i+=1)
		data[i][0]=(127+(i-500)*(204-127)/250)*256-1
		data[i][1]=(127+(i-500)*(102-127)/250)*256-1
		data[i][2]=(127+(i-500)*(0-127)/250)*256-1
	endfor

	for(i=750;i<1000;i+=1)
		data[i][0]=(204+(i-750)*(256-204)/250)*256-1
		data[i][1]=(102+(i-750)*(217-102)/250)*256-1
		data[i][2]=(0+(i-750)*(102-0)/500)*256-1
	endfor
	
end

function colorbar8(data)
	wave data;
	variable i;
	
	for(i=0;i<200;i+=1)
		data[i][0]=(256+i*(128-256)/200)*256-1
		data[i][1]=(256+i*(128-256)/200)*256-1
		data[i][2]=(256+i*(128-256)/200)*256-1
	endfor		
	
	for(i=200;i<400;i+=1)
		data[i][0]=(128+(i-200)*(204-128)/200)*256-1
		data[i][1]=(128+(i-200)*(102-128)/200)*256-1
		data[i][2]=(128+(i-200)*(0-128)/200)*256-1
	endfor

	for(i=400;i<600;i+=1)
		data[i][0]=(204+(i-400)*(256-204)/200)*256-1
		data[i][1]=(102+(i-400)*(217-102)/200)*256-1
		data[i][2]=(0+(i-400)*(102-0)/200)*256-1
	endfor

	for(i=600;i<800;i+=1)
		data[i][0]=(256+(i-600)*(204-256)/200)*256-1
		data[i][1]=(217+(i-600)*(102-217)/200)*256-1
		data[i][2]=(102+(i-600)*(0-102)/200)*256-1
	endfor
	
		for(i=800;i<1000;i+=1)
		data[i][0]=(204+(i-800)*(256-204)/200)*256-1
		data[i][1]=(102+(i-800)*(256-102)/200)*256-1
		data[i][2]=(0+(i-800)*(256-0)/200)*256-1
	endfor
	
end



function colorbar9(data)
	wave data
	variable i
	for(i=0;i<500;i+=1)
		data[i][0]=(127+i*(204-127)/500)*256-1
		data[i][1]=(127+i*(102-127)/500)*256-1
		data[i][2]=(127+i*(0-127)/500)*256-1
	endfor

	for(i=500;i<1000;i+=1)
		data[i][0]=(204+(i-500)*(256-204)/499)*256-1
		data[i][1]=(102+(i-500)*(217-102)/499)*256-1
		data[i][2]=(0+(i-500)*(102-0)/499)*256-1
	endfor
end



