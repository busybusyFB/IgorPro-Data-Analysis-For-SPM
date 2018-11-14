#pragma rtGlobals=3		// Use modern global access method and strict wave access.
//#include <Image Common>
//#include <Image Threshold Panel>
#include <All IP Procedures>


// These functions display 3D waves (dIdV map or FFT map)
// 3 function:
// WZAppend3DImageSlider()
//		showsdf
// WZdIdVandFTslider()
// SpectraViewPanel(data)





//**********************************dI/dV grid map**************************************
//**************************************************************************************
//**************************************************************************************
Function WZAppend3DImageSlider()
	String grfName= WinName(0, 1);
	variable kImageSliderLMargin=80;
	DoWindow/F $grfName		// Garuantee that the image is the top window, because sometimes the top window is not the dI/dV map
								// It may be a panel that calles functions to work on the dI/dV map.
	
// Controling part	
	if( V_Flag==0 )
		return 0;			// No top graph window, exit
	endif
	if( V_Flag==2 )	
		return 0;			// No active graph window, exit
	endif
	
	String iName= WMTopImageGraph()		// find one top image in the top graph window
	if( strlen(iName) == 0 )
		DoAlert 0,"No image plot found"
		return 0
	endif
	
	Wave w= $WMGetImageWave(iName)	// get the wave associated with the top image.	
	if(DimSize(w,2)<=0)
		DoAlert 0,"Need a 3D image"
		return 0
	endif

	ControlInfo WM3DAxis
	if( V_Flag != 0 )
		return 0			// already installed, do nothing
	endif
// End of controling part
	
	String dfSav= GetDataFolder(1);
	NewDataFolder/S/O root:Packages;
	NewDataFolder/S/O WZ3DImageSlider;
	NewDataFolder/S/O $grfName;
	
	Variable/G gLeftLim=0,gRightLim,gLayer=0,gELayer=dimoffset(w,2);
	if((DimSize(w,3)>0 && (dimSize(w,2)==3 || dimSize(w,2)==4)))		// 09JUN10; will also support stacks with alpha channel.
		gRightLim=DimSize(w,3)-1					//image is 4D with RGB as 3rd dim
	else
		gRightLim=DimSize(w,2)-1					//image is 3D grayscale
	endif
	
	String/G imageName=nameOfWave(w)
	ControlInfo kwControlBar
	Variable/G gOriginalHeight= V_Height		// we append below original controls (if any)
	ControlBar gOriginalHeight+30
	
	GetWindow kwTopWin,gsize
	
	Slider WM3DAxis,pos={V_left+10,gOriginalHeight+9},size={V_right-V_left-kImageSliderLMargin,16},proc=WZ3DImageSliderProc
	Slider WM3DAxis,limits={0,gRightLim,1},value= 0,vert= 0,ticks=0,side=0,variable=gLayer	
	
	SetVariable WM3DVal,pos={V_right-kImageSliderLMargin+15,gOriginalHeight+9},size={40,14}
	SetVariable WM3DVal,limits={0,dimSize(w,2),1},value=gLayer,title=" ",proc=WZ3DImageSliderSetLayerProc
	
	SetVariable WM3DVall,pos={V_right-kImageSliderLMargin+60,gOriginalHeight+9},size={53,14},format="%.3f"
	SetVariable WM3DVall,limits={dimoffset(w,2),dimoffset(w,2)+dimdelta(w,2)*(dimSize(w,2)-1),dimdelta(w,2)},value=gELayer,title=" ",proc=WZ3DImageSliderSetEProc
	
	ModifyImage $imageName plane=0				//Initialize the dI/dV map with the layer 0.
	
	WaveStats/Q w
	ModifyImage $imageName ctab= {*,*,,0}
	ModifyImage $imageName ctabAutoscale=3

	SetDataFolder dfSav
End
//**************************************************************************************

//**************************************************************************************
Function WZ3DImageSliderProc(sa) : SliderControl
	STRUCT WMSliderAction &sa
	switch( sa.eventCode )
		case -1: // control being killed
			break
		default:
			if( sa.eventCode & 1 ) // value set
				WZupdategdIdVimage(0);
			endif
			break
	endswitch	
	return 0				// other return values reserved
End

Function WZ3DImageSliderSetLayerProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva
	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			WZupdategdIdVimage(0);
			break;
	endswitch

	return 0
End

Function WZ3DImageSliderSetEProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva
	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			WZupdategdIdVimage(1);
			break;
	endswitch

	return 0
End
//**************************************************************************************

//**************************************************************************************
function WZupdategdIdVimage(flag)
	variable flag;
	String dfSav= GetDataFolder(1)
	String grfName= WinName(0, 1)
	SetDataFolder root:Packages:WZ3DImageSlider:$(grfName)
	Variable/G gLayer;
	wave w= $WMGetImageWave("");
	Variable/G gELayer;
	if(flag==0)
		gELayer=Dimoffset(w,2)+gLayer*Dimdelta(w,2);
	elseif(flag==1)
		gLayer=(gELayer-Dimoffset(w,2))/Dimdelta(w,2);
	endif
	ModifyImage $nameofwave(w) plane=(gLayer);
	ModifyImage $nameofwave(w) ctabAutoscale=3;
	SetDataFolder dfSav;
end
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************





//***************************dI/dV grid map and FFT map visualization*******************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
function WZdIdVandFTslider()

//	string data1name, data2name
//	Prompt data1name, "Enter the name of dI/dV image"
//	Prompt data2name, "Enter the name of FFT image"
//	Doprompt "Enter Names:", data1name, data2name

	string data1name = GetBrowserSelection(0)
	string data2name = GetBrowserSelection(1)

	if (strlen(data1name) == 0 || strlen(data2name) == 0)
		print "Need 2 waves";
		return 0;
	endif

	wave data1=$data1name;
	wave data2=$data2name;
	
	Display/K=1/W=(100,100,700,400) as NameOfWave(data1)
	String dfSav= GetDataFolder(1);
	NewDataFolder/S/O root:Packages;
	NewDataFolder/S/O WZdIdVandFTslider;
	NewDataFolder/S/O $(nameofwave(data1)+"FT");
	
	Variable/G gLeftLim=0,gRightLim,gLayer=0,gELayer=dimoffset(data1,2);
	gRightLim=DimSize(data1,2)-1;
	ControlInfo kwControlBar
	Variable/G gOriginalHeight= V_Height		// we append below original controls (if any)
	ControlBar gOriginalHeight+30
	GetWindow kwTopWin,gsize
	Slider WM3DAxis,pos={V_left+10,gOriginalHeight+9},size={V_right-V_left-kImageSliderLMargin,16},proc=WZdIdVFTSliderProc
	Slider WM3DAxis,limits={0,gRightLim,1},value= 0,vert= 0,ticks=0,side=0,variable=gLayer
	SetVariable WM3DVal,pos={V_right-kImageSliderLMargin+15,gOriginalHeight+9},size={40,14},proc=WZdIdVFTSetLayerProc
	SetVariable WM3DVal,limits={0,dimSize(data1,2),1},value=gLayer,title=" "
	SetVariable WM3DVall,pos={V_right-kImageSliderLMargin+60,gOriginalHeight+9},size={53,14},format="%.3f",proc=WZdIdVFTSetEProc
	SetVariable WM3DVall,limits={dimoffset(data1,2),dimoffset(data1,2)+dimdelta(data1,2)*(dimSize(data1,2)-1),dimdelta(data1,2)},value=gELayer,title=" "
	
	Display/W=(0,0,300,400)/HOST=#
	AppendImage data1
	ModifyGraph standoff=0
	ModifyImage $(nameofwave(data1)) plane=0
	ModifyImage $(nameofwave(data1)) ctab= {*,*,,0}
	ModifyImage $(nameofwave(data1)) ctabAutoscale=3
	RenameWindow #,G0
	SetActiveSubwindow ##
	
	Display/W=(300,0,600,400)/HOST=#
	AppendImage data2
	ModifyImage $(nameofwave(data2)) plane=0
	ModifyImage $(nameofwave(data2)) ctab= {0,100,VioletOrangeYellow,0}
	ModifyGraph standoff=0
	RenameWindow #,G1
	SetActiveSubwindow ##
	
	SetDataFolder dfSav
end
//*************************************************************************************

//*************************************************************************************
Function WZdIdVFTSliderProc(sa) : SliderControl
	STRUCT WMSliderAction &sa
	switch( sa.eventCode )
		case -1: // control being killed
			break
		default:
			if( sa.eventCode & 1 ) // value set
				WZupdategdIdVFT(0);
			endif
			break
	endswitch	
	return 0				// other return values reserved
End

Function WZdIdVFTSetLayerProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva
	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			WZupdategdIdVFT(0);
			break;
	endswitch
	return 0
End

Function WZdIdVFTSetEProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva
	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			WZupdategdIdVFT(1);
			break;
	endswitch
	return 0
End
//*************************************************************************************

//*************************************************************************************
function WZupdategdIdVFT(flag)
	variable flag;
	String dfSav= GetDataFolder(1)
	SetActiveSubwindow #G0
	string flagStr="root:Packages:WZdIdVandFTslider:"+nameofwave($WMGetImageWave(""))+"FT";
	SetDataFolder flagStr;
	SetActiveSubwindow ##
	Variable/G gLayer;
	Variable/G gELayer;
	SetActiveSubwindow #G0
	if(flag==0)
		gELayer=Dimoffset($WMGetImageWave(""),2)+gLayer*Dimdelta($WMGetImageWave(""),2);
	elseif(flag==1)
		gLayer=(gELayer-Dimoffset($WMGetImageWave(""),2))/Dimdelta($WMGetImageWave(""),2);
	endif
	SetActiveSubwindow ##
	SetActiveSubwindow #G0
	ModifyImage $nameofwave($WMGetImageWave("")) plane=(gLayer);
	ModifyImage $nameofwave($WMGetImageWave("")) ctabAutoscale=3;
	SetActiveSubwindow ##
	SetActiveSubwindow #G1
	ModifyImage $nameofwave($WMGetImageWave("")) plane=(gLayer);
	SetActiveSubwindow ##
	SetDataFolder dfSav;
end
//*************************************************************************************

//**************************************************************************************
//**************************************************************************************
//**************************************************************************************





//******************************SpectraView Panal***************************************
//Show 3D dI/dV grid map and observe single-point spectroscopy
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
Function SpectraViewPanel(data)
	Wave data
	
	if(WaveDims(Data)!=3) 
		Print "Not a 3D wave"; 
		return -1; 
	endif

	String oldDataFolder = GetDataFolder(1)
	SetDataFolder GetWavesDataFolderDFR(data)

	PauseUpdate; Silent 1		// building window...

	DoWindow/K SpectraView
	NewPanel/K=1/N=SpectraView/W=(186,115,1248,670) as "SpectraView"
	ModifyPanel cbRGB=(30464,30464,30464)	
	
	Variable/G SV_layer=0
	Variable/G SV_layer_energy
	Variable/G checked_D,checked_E,checked_F,checked_G,checked_H

	Slider SV_slider,pos={25,510},size={400,19},proc=SV_SliderProc
	Slider SV_slider,limits={0,DimSize(data, 2)-1,1},variable= SV_layer,vert= 0,ticks= 0

	ValDisplay SVlayerDisp,pos={443,510},size={50,30},fsize=14,limits={0,0,0},barmisc={0,1000}, value= #(GetDataFolder(1)+"SV_layer")
	ValDisplay SVlayerEnergyDisp, pos={500,510},size={50,30},fsize=14,limits={0,0,0},barmisc={0,1000}
	ValDisplay SVlayerEnergyDisp, value=  #(GetDataFolder(1)+"SV_layer_energy"),format="%.2f"
	SetDrawEnv fsize= 14
	DrawText 554,527,"eV"
	
	print (GetDataFolder(1)+"SV_layer")

	Display/W=(15,15,515,494)/HOST=#
	AppendImage $(NameOfWave(data))
	ModifyImage $(NameOfWave(data)) ctab= {*,*,VioletOrangeYellow,0}, plane=(SV_layer)
	ModifyImage $(NameOfWave(data))	ctabAutoscale=3
	ModifyGraph height={Aspect,1}, mirror=2
	
	//Deal with the dI/dV map where height != width
	variable h = DimDelta(data,0) * DimSize(data,0)
	variable v = DimDelta(data,1) * DimSize(data,1)
	variable dalta;
	if (v > h)
		dalta = (v - h) / 2;
		SetAxis bottom DimOffset(data,0) - dalta, DimOffset(data,0) + h + dalta;
	else
		if (h > v)
		dalta = (h - v) / 2;
		SetAxis left DimOffset(data,1) - dalta, Dimoffset(data,1) + v + dalta;
		endif
	endif
	//end of this part

	Cursor/P/I/S=1/C=(65535,0,65535) D $(NameOfWave(data)) DimSize(data, 0)/2-10, DimSize(data, 1)/2-10
	Cursor/P/I/S=1/C=(65535,0,65535) E $(NameOfWave(data)) DimSize(data, 0)/2+5, DimSize(data, 1)/2-5
	Cursor/P/I/S=1/C=(65535,0,65535) F $(NameOfWave(data)) DimSize(data, 0)/2, DimSize(data, 1)/2
	Cursor/P/I/S=1/C=(65535,0,65535) G $(NameOfWave(data)) DimSize(data, 0)/2+5, DimSize(data, 1)/2+5
	Cursor/P/I/S=1/C=(65535,0,65535) H $(NameOfWave(data)) DimSize(data, 0)/2+10, DimSize(data, 1)/2+10
	
	Make/O/N=(DimSize(data, 2))  '_PointSpectra_d',  '_PointSpectra_e', '_PointSpectra_f',  '_PointSpectra_g',  '_PointSpectra_h'
	Wave W_d='_PointSpectra_d', W_e='_PointSpectra_e', W_f='_PointSpectra_f', W_g='_PointSpectra_g', W_h='_PointSpectra_h'
	SetScale/P x, DimOffset(Data, 2), DimDelta(Data, 2), "V", W_d, W_e, W_f, W_g, W_h
	W_d[] = Data[pcsr(D)][qcsr(D)][p]
	W_e[] = Data[pcsr(E)][qcsr(E)][p]
	W_f[] = Data[pcsr(F)][qcsr(F)][p]
	W_g[] = Data[pcsr(G)][qcsr(G)][p]
	W_h[] = Data[pcsr(H)][qcsr(H)][p]

	RenameWindow #,G0
	SetActiveSubwindow ##

	Display/W=(530,15,1030,495)/HOST=#  '_PointSpectra_f','_PointSpectra_e','_PointSpectra_d',  '_PointSpectra_g',  '_PointSpectra_h'
	ModifyGraph rgb('_PointSpectra_d')=(65535,0,0), rgb('_PointSpectra_e')=(0,65535,0), rgb('_PointSpectra_f')=(0,0,65535)
	ModifyGraph rgb('_PointSpectra_g')=(65535,0,65535), rgb('_PointSpectra_h')=(0,65535,65535)
	ModifyGraph lsize=2
	Legend/C/N=text0/J/D=2 "\\s('_PointSpectra_d') D\r\\s('_PointSpectra_e') E\r\\s('_PointSpectra_f') F\r\\s('_PointSpectra_g') G\r\\s('_PointSpectra_h') H"
	RenameWindow #,G1
	SetActiveSubwindow ##
	
	Button ResetCursor title="Reset Cursor",pos={580,510},size={100,30},fSize=14,proc=SVCsrResetProc
	Button SaveSpectra title="Save spectra",pos={860,510},size={100,30},fSize=14,proc=RecorddIdVProc
	checkbox checkD title=" D",pos={690,517},value=0,proc=CheckCursorDProc
	checkbox checkE title=" E",pos={725,517},value=0,proc=CheckCursorEProc
	checkbox checkF title=" F",pos={760,517},value=0,proc=CheckCursorFProc
	checkbox checkG title=" G",pos={795,517},value=0,proc=CheckCursorGProc
	checkbox checkH title=" H",pos={830,517},value=0,proc=CheckCursorHProc
	
	SetWindow SpectraView, hook(h1)=SVWindowHook
	
	SetDataFolder oldDataFolder	
	return 1
End //SpectraViewPanel

Function SV_SliderProc(sa) : SliderControl
	STRUCT WMSliderAction &sa

	switch( sa.eventCode )
		case -1: // control being killed
			break
		default:
			if( sa.eventCode & 1 ) // value set
				Wave data = ImageNameToWaveRef("SpectraView#G0", StringFromList(0, ImageNameList("SpectraView#G0", ";"))) 
				DFREF dfr = GetWavesDataFolderDFR(data)
				NVAR/SDFR=dfr SV_layer
				changeEnergy(data)
				ModifyImage/W=SpectraView#G0 $(NameOfWave(data)) plane=(SV_layer)
			endif
			break
	endswitch

	return 0
End //SV_SliderProc

Function changeEnergy(data)
	wave data
	String oldDataFolder = GetDataFolder(1)
	SetDataFolder GetWavesDataFolderDFR(data)
	variable/G SV_layer
	variable/G SV_layer_energy=SV_layer*DimDelta(data,2)+DimOffset(data,2)
	SetDataFolder oldDataFolder	
end

Function SVWindowHook(s)
	STRUCT WMWinHookStruct &s

	Variable hookResult = 0
	Wave data = ImageNameToWaveRef("SpectraView#G0", StringFromList(0, ImageNameList("SpectraView#G0", ";"))) 
	DFREF dfr = GetWavesDataFolderDFR(data)
	Wave/SDFR=dfr W_d='_PointSpectra_d', W_e='_PointSpectra_e', W_f='_PointSpectra_f', W_g='_PointSpectra_g', W_h='_PointSpectra_h'	
	NVAR/SDFR=dfr SV_layer
	switch(s.eventCode)
		case 2:
			KillWindow SpectraView#G1
			KillWaves W_d, W_e, W_f,W_g,W_h
			KillVariables SV_layer,SV_layer_energy
			killvariables checked_D,checked_E,checked_F,checked_G,checked_H
			break
		case 7:
			W_d[] = Data[pcsr(D, "SpectraView#G0")][qcsr(D,"SpectraView#G0")][p]					
			W_e[] = Data[pcsr(E,"SpectraView#G0")][qcsr(E,"SpectraView#G0")][p]
			W_f[] = Data[pcsr(F,"SpectraView#G0")][qcsr(F,"SpectraView#G0")][p]				
			W_g[] = Data[pcsr(G,"SpectraView#G0")][qcsr(G,"SpectraView#G0")][p]
			W_h[] = Data[pcsr(H,"SpectraView#G0")][qcsr(H,"SpectraView#G0")][p]
			break
	endswitch

	return hookResult
End //SVWindowHook


Function SVCsrResetProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	if(ba.eventCode==2)
		Wave data = ImageNameToWaveRef("SpectraView#G0", StringFromList(0, ImageNameList("SpectraView#G0", ";"))) 
		Cursor/W=SpectraView#G0/P/I/S=1/C=(65535,0,65535) D $(NameOfWave(data)) DimSize(data, 0)/2-10, DimSize(data, 1)/2-10
		Cursor/W=SpectraView#G0/P/I/S=1/C=(65535,0,65535) E $(NameOfWave(data)) DimSize(data, 0)/2-5, DimSize(data, 1)/2-5
		Cursor/W=SpectraView#G0/P/I/S=1/C=(65535,0,65535) F $(NameOfWave(data)) DimSize(data, 0)/2, DimSize(data, 1)/2
		Cursor/W=SpectraView#G0/P/I/S=1/C=(65535,0,65535) G $(NameOfWave(data)) DimSize(data, 0)/2+5, DimSize(data, 1)/2+5
		Cursor/W=SpectraView#G0/P/I/S=1/C=(65535,0,65535) H $(NameOfWave(data)) DimSize(data, 0)/2+10, DimSize(data, 1)/2+10
	endif
	return 0
End //SVCsrResetProc


Function RecorddIdVProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	if(ba.eventCode==2)
		Wave data = ImageNameToWaveRef("SpectraView#G0", StringFromList(0, ImageNameList("SpectraView#G0", ";"))) 
		variable/G checked_D,checked_E,checked_F,checked_G,checked_H
		wave '_PointSpectra_d',  '_PointSpectra_e', '_PointSpectra_f',  '_PointSpectra_g',  '_PointSpectra_h'
		if(checked_D==1)
			duplicate/O '_PointSpectra_d', $(nameofwave(data)+"_SPS_D")
		endif
		if(checked_E==1)
			duplicate/O '_PointSpectra_e', $(nameofwave(data)+"_SPS_E")
		endif
		if(checked_F==1)
			duplicate/O '_PointSpectra_f', $(nameofwave(data)+"_SPS_F")
		endif
		if(checked_G==1)
			duplicate/O '_PointSpectra_g', $(nameofwave(data)+"_SPS_G")
		endif
		if(checked_H==1)
			duplicate/O '_PointSpectra_h', $(nameofwave(data)+"_SPS_H")
		endif
	endif
	return 0
End //SVCsrResetProc


Function CheckCursorDProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba
	switch( cba.eventCode )
		case 2: // mouse up
			Variable/G checked_D = cba.checked
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function CheckCursorEProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba
	switch( cba.eventCode )
		case 2: // mouse up
			Variable/G checked_E = cba.checked
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function CheckCursorFProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba
	switch( cba.eventCode )
		case 2: // mouse up
			Variable/G checked_F = cba.checked
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function CheckCursorGProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba
	switch( cba.eventCode )
		case 2: // mouse up
			Variable/G checked_G = cba.checked
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function CheckCursorHProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba
	switch( cba.eventCode )
		case 2: // mouse up
			Variable/G checked_H = cba.checked
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End