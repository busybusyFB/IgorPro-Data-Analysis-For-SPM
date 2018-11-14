#pragma TextEncoding = "UTF-8"
//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma rtGlobals=3		// Use modern global access method
#include <All IP Procedures>
#include <Image Saver>
#include <PopupWaveSelector>
#pragma moduleName=startup    // traditional for static functions
//////////////////////////////////////////////////////////////////////////////////////////////////


menu "WZFunc"
	"WZImagePanel", WZImagePanel()
end

Window WZImagePanel() : Panel
	PauseUpdate; Silent 1		// building window...
	InitializeImagePanel()
	NewPanel /K=1 /W=(5,610,280,975)
	SetDrawLayer UserBack
	DrawText 141,321,"nm"
	DrawText 231,349,"nm"
	SetDrawEnv linefgc= (34952,34952,34952)
	DrawLine 13,423,260,423
	DrawLine 13,147,264,147
	SetDrawEnv fsize= 16
	DrawText 15,174,"AddAnnotation"
	SetDrawEnv fsize= 16
	DrawText 15,50,"ModifyGraphSize"
	DrawLine 13,149,264,149
	DrawLine 13,466,264,466
	DrawLine 13,468,264,468
	SetDrawEnv fsize= 16
	DrawText 15,492,"AddScaleBar"
	TabControl Tab0,pos={5.00,5.00},size={315.00,614.00},proc=Tab1Proc
	TabControl Tab0,labelBack=(61166,61166,61166),tabLabel(0)="Graph"
	TabControl Tab0,tabLabel(1)="Image",tabLabel(2)="dIdVMap"
	TabControl Tab0,tabLabel(3)="Operation",value= 0
	Button button0,pos={25.00,57.00},size={100.00,20.00},proc=WZDefaultWinSizeProc,title="DefaultSize"
	Button button3,pos={129.00,57.00},size={100.00,20.00},proc=WZMaxWinSizeProc,title="MaxSize"
	Slider slider0,pos={19.00,88.00},size={242.00,56.00},proc=WZCostomizeWinSize
	Slider slider0,limits={0,3,0.1},value= 1,vert= 0,ticks= 14
	PopupMenu popup0,pos={16.00,183.00},size={94.00,19.00},proc=setDirection,title="Direction"
	PopupMenu popup0,mode=1,popvalue="ZFU",value= #"\"ZFU;ZFD;ZBU;ZBD\""
	SetVariable setvar2,pos={16.00,213.00},size={120.00,18.00},proc=setImageNum,title="Image # "
	SetVariable setvar2,limits={1,inf,1},value= root:Packages:annotations:ImageNum
	SetVariable setvar0,pos={16.00,243.00},size={120.00,18.00},proc=setBias,title="Bias V    "
	SetVariable setvar0,limits={-10,10,0.1},value= root:Packages:annotations:BiasVoltage
	SetVariable setvar1,pos={16.00,273.00},size={120.00,18.00},proc=setCurrent,title="Current  "
	SetVariable setvar1,limits={-inf,inf,10},value= root:Packages:annotations:Current
	PopupMenu popup1,pos={146.00,272.00},size={37.00,19.00},proc=setCurrentUnit
	PopupMenu popup1,mode=1,popvalue="pA",value= #"\"pA;nA\""
	SetVariable setvar3,pos={16.00,303.00},size={120.00,18.00},proc=setWidth,title="Width     "
	SetVariable setvar3,limits={-inf,inf,10},value= root:Packages:annotations:width
	CheckBox check0,pos={22.00,335.00},size={74.00,15.00},proc=setNoSquare,title="Not Square"
	CheckBox check0,value= 0,side= 1
	SetVariable setvar4,pos={106.00,333.00},size={120.00,18.00},proc=setHeight,title="Height"
	SetVariable setvar4,limits={-inf,inf,10},value= root:Packages:annotations:height
	CheckBox check1,pos={22.00,365.00},size={74.00,15.00},proc=setCustomize,title="Customize "
	CheckBox check1,value= 0,side= 1
	SetVariable setvar5,pos={106.00,363.00},size={120.00,18.00},proc=setCustomStr,title=" "
	SetVariable setvar5,limits={-inf,inf,0},value= root:Packages:annotations:CustomStr
	PopupMenu popup2,pos={16.00,393.00},size={112.00,19.00},proc=setFontColor,title="Font Color"
	PopupMenu popup2,mode=1,popvalue="White",value= #"\"White;Black;Red\""
	PopupMenu popup3,pos={146.00,393.00},size={57.00,19.00},proc=setFontSize,title="Size"
	PopupMenu popup3,mode=1,popvalue="18",value= #"\"12;14;16;18;20;22;24;36\""
	Button button1,pos={186.00,183.00},size={70.00,40.00},proc=ApplyAddo,title="Apply"
	Button button2,pos={186.00,228.00},size={70.00,30.00},proc=killAddo,title="Delete"
	TitleBox title0,pos={16.00,433.00},size={235.00,25.00}
	TitleBox title0,labelBack=(52224,52224,52224),fSize=12
	TitleBox title0,variable= root:Packages:annotations:finalAnnotation,fixedSize=1
	Slider slider1,pos={18.00,550.00},size={242.00,56.00},proc=WZScaleBarChangeRatio
	Slider slider1,limits={0,0.8,0.1},value= 0.2,vert= 0,ticks= 10
	Button button5,pos={170.00,504.00},size={50.00,30.00},proc=WZDeleteScaleBarProc,title="Delete"
	Button button6,pos={120.00,504.00},size={50.00,30.00},proc=WZAddScaleBarProc,title="Apply"
	CheckBox check2,pos={10.00,514.00},size={64.00,15.00},proc=WZScaleBarTextProc,title="WithText "
	CheckBox check2,value= 0,side= 1
	Button button7,pos={20.00,40.00},size={100.00,20.00},disable=1,proc=WZOptimize2DFFTProc,title="Good2DFFT"
	Button button8,pos={120.00,40.00},size={100.00,20.00},disable=1,proc=WZ200ZoomProc,title="200%Zoom-in"
	Button button9,pos={120.00,65.00},size={100.00,20.00},disable=1,proc=WZ300ZoomProc,title="300%Zoom-in"
	Button button10,pos={20.00,90.00},size={100.00,20.00},disable=1,proc=WZGrabBigImageProc,title="GrabImage  Big"
	Button button11,pos={20.00,115.00},size={100.00,20.00},disable=1,proc=WZGrabSmallImageProc,title="GrabImageSmall"
	Button button12,pos={20.00,140.00},size={100.00,20.00},disable=1,proc=WZPlaneFit1Proc,title=" PlaneFit_1"
	Button button13,pos={20.00,165.00},size={100.00,20.00},disable=1,proc=WZPlaneFit2Proc,title=" PlaneFit_2"
	Button button14,pos={20.00,190.00},size={100.00,20.00},disable=1,proc=WZPlaneFit3Proc,title=" PlaneFit_3"
	Button button15,pos={20.00,40.00},size={100.00,20.00},disable=1,proc=Show3DwaveProc,title=" ShowGridMap"
	Button button16,pos={20.00,650.00},size={100.00,20.00},disable=1,proc=Show3DwaveProc,title="GiveUnit"
	Button removeSplikePt,pos={20.00,215.00},size={100.00,20.00},disable=1,proc=RemoveSpikeProc,title="RmSpike"
	Button removeSplikePtLbyL,pos={20.00,240.00},size={100.00,20.00},disable=1,proc=RemoveSplikePtLbyLProc,title="RmSplikeLbyL"
	Button removeSplikeLine,pos={20.00,265.00},size={100.00,20.00},disable=1,proc=RemoveSplikeLineProc,title="RmSplikeLine"
	Button button18,pos={20.00,65.00},size={100.00,20.00},disable=1,proc=dIdVandFTsliderProc,title="ShowdIdVFTMap"
	Button showtopo,pos={20.00,40.00},size={100.00,20.00},disable=1,proc=ShowTopoProc,title="ShowTopo"
	Button showcode,pos={95.00,205.00},size={85.00,20.00},disable=1,proc=ShowCodeProc,title="PanelCode"
	Button callImgEnhance,pos={10.00,205.00},size={85.00,20.00},disable=1,proc=WZcallImgEnhance,title="ImgEnhCode"
	Button callsetColor,pos={180.00,205.00},size={85.00,20.00},disable=1,proc=WZcallsetColorScale,title="setColorCode"
	Button callLatCalculation,pos={10.00,230.00},size={80.00,20.00},disable=1,proc=WZcallLatticeCalculation,title="LattCalCode"
	Button callOpenMultiFiles,pos={90.00,230.00},size={90.00,20.00},disable=1,proc=WZcallcallOpenMultiFiles,title="LoadDataCode"
	Button callVisImage,pos={180.00,230.00},size={85.00,20.00},disable=1,proc=WZcallVisImage,title="VisImgCode"
	Button callDataAnalysis,pos={10.00,255.00},size={80.00,20.00},disable=1,proc=WZcallDataAnalysis,title="AnalysisCode"
	Button callRecAtomLoc,pos={90.00,255.00},size={105.00,20.00},disable=1,proc=WZcallRecAtomLoc,title="RecAtomLocCode"
	Button Linecut3DH,pos={10.00,70.00},size={90.00,20.00},disable=1,proc=LineCut3DHProc,title="Linecut_3DHor"
	Button Linecut3DV,pos={100.00,70.00},size={90.00,20.00},disable=1,proc=LineCut3DVProc,title="Linecut_3DVer"
	Button Get3Dlayer,pos={190.00,70.00},size={80.00,20.00},disable=1,proc=Get3DlayerProc,title="Get3Dlayer"
	Button Linecut2DH,pos={10.00,95.00},size={90.00,20.00},disable=1,proc=LineCut2DHProc,title="Linecut_2DHor"
	Button Linecut2DV,pos={100.00,95.00},size={90.00,20.00},disable=1,proc=LineCut2DVProc,title="Linecut_2DVer"
	Button GetdIdVspec,pos={190.00,95.00},size={80.00,20.00},disable=1,proc=GetdIdVspecProc,title="Get1dI/dV"
	SetWindow kwTopWin,hook=updataTopImageAnnoInfo
EndMacro



Function Tab1Proc(tca) : TabControl
	STRUCT WMTabControlAction &tca
	switch( tca.eventCode )
		case 2: // mouse up
			Variable tab = tca.tab
			setDrawLayer/K UserBack;
			switch(tab)
				case 0:
					DrawingTab1();
					break;
				case 1:
					break;
				case 2:
					break;
				case 3:
					DrawingTab4();
					break;
			endswitch
			variable isTab0= tab==0
			variable isTab1= tab==1
			variable isTab2= tab==2
			variable isTab3= tab==3
			modifyControl button0 disable=!isTab0;
			modifyControl button1 disable=!isTab0;
			modifyControl button2 disable=!isTab0;
			modifyControl button3 disable=!isTab0;
			modifyControl button5 disable=!isTab0;
			modifyControl button6 disable=!isTab0;
			modifyControl Slider0 disable=!isTab0;
			modifyControl Slider1 disable=!isTab0;
			modifyControl popup0 disable=!isTab0;
			modifyControl popup1 disable=!isTab0;
			modifyControl popup2 disable=!isTab0;
			modifyControl popup3 disable=!isTab0;
			modifyControl setvar0 disable=!isTab0;
			modifyControl setvar1 disable=!isTab0;
			modifyControl setvar2 disable=!isTab0;
			modifyControl setvar3 disable=!isTab0;
			modifyControl setvar4 disable=!isTab0;
			modifyControl setvar5 disable=!isTab0;
			modifyControl check0 disable=!isTab0;
			modifyControl check1 disable=!isTab0;
			modifyControl check2 disable=!isTab0;
			modifyControl title0 disable=!isTab0;
			modifyControl button7 disable=!isTab1;
			modifyControl button8 disable=!isTab1;
			modifyControl button9 disable=!isTab1;
			modifyControl button10 disable=!isTab1;
			modifyControl button11 disable=!isTab1;
			modifyControl button12 disable=!isTab1;
			modifyControl button13 disable=!isTab1;
			modifyControl button14 disable=!isTab1;
			modifyControl button15 disable=!isTab2;
			modifyControl button16 disable=!isTab2;
			modifyControl removeSplikePt disable=!isTab1;
			modifyControl removeSplikePtLbyL disable=!isTab1;
			modifyControl removeSplikeLine disable=!isTab1;
			modifyControl button18 disable=!isTab2;
			modifyControl showtopo disable=!isTab3;
			modifyControl showcode disable=!isTab3;
			modifyControl Linecut3DH disable=!isTab3;
			modifyControl Linecut3DV disable=!isTab3;
			modifyControl Get3Dlayer disable=!isTab3;
			modifyControl Linecut2DH disable=!isTab3;
			modifyControl Linecut2DV disable=!isTab3;
			modifyControl GetdIdVspec disable=!isTab3;
			modifyControl callImgEnhance disable=!isTab3;
			modifyControl callsetColor disable=!isTab3;
			modifyControl callLatCalculation disable=!isTab3;
			modifyControl callOpenMultiFiles disable=!isTab3;
			modifyControl callVisImage disable=!isTab3;
			modifyControl callDataAnalysis disable=!isTab3;
			modifyControl callRecAtomLoc disable=!isTab3;
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function DrawingTab1()
	SetDrawLayer UserBack
	DrawText 141,321,"nm"
	DrawText 231,349,"nm"
	SetDrawEnv linefgc= (34952,34952,34952)
	DrawLine 13,423,260,423
	DrawLine 13,147,264,147
	SetDrawEnv fsize= 16
	DrawText 15,174,"AddAnnotation"
	SetDrawEnv fsize= 16
	DrawText 15,50,"ModifyGraphSize"
	DrawLine 13,149,264,149
	DrawLine 13,466,264,466
	DrawLine 13,468,264,468
	SetDrawEnv fsize= 16
	DrawText 15,492,"AddScaleBar"
end

Function DrawingTab4()
	SetDrawLayer UserBack
	SetDrawEnv fsize= 14
	DrawText 10,200,"ShowSourceCodes"
End

Function InitializeImagePanel()
	InitializeAnno()
	newdatafolder/O root:Packages
	newdatafolder/O root:Packages:annotations
	newdatafolder/O root:WinGlobals
	newdatafolder/O root:WinGlobals:ScaleBars
	String dfSav= GetDataFolder(1)
	SetDataFolder root:WinGlobals:ScaleBars	
	Variable/G WithText=0;
	Variable/G Ratio=0.2;
	SetDataFolder dfSav
end


Function WZSetWinSize(ratio)
	variable ratio;
	variable effectiveWidth,effectiveHeight;
	string topGraphWave=WMGetImageWave("");
	wave data=$topGraphWave;
	variable RowNum=Dimsize(data,0), ColNum=DimSize(data,1);
	if(ratio==-1)
		effectiveWidth=648;
		effectiveHeight=648/ColNum*RowNum;
	elseif(ratio==0)
		effectiveWidth=ColNum*72/screenresolution;
		effectiveHeight=RowNum*72/screenresolution;
	else
		effectiveWidth=ColNum*72/screenresolution*ratio;
		effectiveHeight=RowNum*72/screenresolution*ratio;
	endif
	
	modifygraph width=effectiveHeight;
	modifygraph height=effectiveWidth;
End


Function WZDefaultWinSizeProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			WZSetWinSize(0);
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End


Function WZMaxWinSizeProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			WZSetWinSize(-1);
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End


Function WZCostomizeWinSize(sa) : SliderControl
	STRUCT WMSliderAction &sa
	switch( sa.eventCode )
		case -1: // control being killed
			break
		default:
			if( sa.eventCode & 1 ) // value set
				Variable curval = sa.curval
				if(curval !=0)
					WZSetWinSize(curval);
				endif;
			endif
			break
	endswitch
	return 0
End


Function WZDeleteScaleBarProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			dowindow/F $winname(0,1);
			setDrawlayer/K userfront
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function WZAddScaleBarProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			String dfSav= GetDataFolder(1)
			SetDataFolder root:WinGlobals:ScaleBars
			variable/G ratio, withtext;
			dowindow/F $winname(0,1);
			scalebar(Ratio,WithText);
			SetDataFolder dfSav
			break;
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function WZScaleBarTextProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba
	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			String dfSav= GetDataFolder(1)
			SetDataFolder root:WinGlobals:ScaleBars
			variable/G WithText=checked;
			SetDataFolder dfSav
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End


Function WZScaleBarChangeRatio(sa) : SliderControl
	STRUCT WMSliderAction &sa
	switch( sa.eventCode )
		case -1: // control being killed
			break
		default:
			if( sa.eventCode & 1 ) // value set
				Variable curval = sa.curval;
				String dfSav= GetDataFolder(1)
				SetDataFolder root:WinGlobals:ScaleBars;
				variable/G ratio=curval;
				SetDataFolder dfSav
			endif
			break
	endswitch
	return 0
End


Function WZOptimize2DFFTProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			ModifyImage $WMTopImageName() log= 0
			ModifyImage $WMTopImageName() ctab= {1e-12,1e-8,VioletOrangeYellow,0}
			ModifyGraph width=192,height=192
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function WZ200ZoomProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			wave data=$WMGetImageWave("");
			variable range0=dimdelta(data,0)*dimsize(data,0)
			variable range1=dimdelta(data,1)*dimsize(data,1)
			SetAxis top dimoffset(data,0)+range0/4,dimoffset(data,0)+3*range0/4;
			SetAxis left dimoffset(data,1)+range1/4,dimoffset(data,1)+3*range1/4;
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function WZ300ZoomProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			wave data=$WMGetImageWave("");
			variable range0=dimdelta(data,0)*dimsize(data,0);
			variable range1=dimdelta(data,1)*dimsize(data,1);
			SetAxis top dimoffset(data,0)+range0/3,dimoffset(data,0)+2*range0/3;
			SetAxis left dimoffset(data,1)+range1/3,dimoffset(data,1)+2*range1/3;
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function WZGrabBigImageProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			SavePICT/E=-5/TRAN=1/B=2400/WIN=$WinName(0,1) as "Clipboard"
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function WZGrabSmallImageProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			SavePICT/E=-5/TRAN=1/B=72/WIN=$WinName(0,1) as "Clipboard"
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End


Function WZPlaneFit1Proc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			planefit($WMTopImageName(),1)
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function WZPlaneFit2Proc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			planefit($WMTopImageName(),2)
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function WZPlaneFit3Proc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			planefit($WMTopImageName(),3)
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function Show3DwaveProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			string dataname=GetBrowserSelection(0);
			if(cmpstr(dataname,"")==0)
				print "No selected wave";
				return 0;
			endif;
			showtopograph($dataname);
			WZAppend3DImageSlider();
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function ConvertUnit(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here		
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function RemoveSpikeProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			RemoveSpikePoint();	
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End


Function RemoveSplikePtLbyLProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			removeSpikePoint_LbyL();
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function RemoveSplikeLineProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			removeSpikeLine();
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function dIdVandFTsliderProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			WZdIdVandFTslider();
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function ShowTopoProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			string toponame=GetBrowserSelection(0);
			if(cmpstr(toponame,"")==0)
				print "No selected wave";
			else
				showtopograph($toponame);
			endif
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function ShowCodeProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			DisplayProcedure/W=$"WZComprehensivePanel.ipf"
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function WZcallImgEnhance(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			DisplayProcedure/W=$"WZEnhanceImgQuality.ipf"
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function WZcallsetColorScale(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			DisplayProcedure/W=$"WZImageColorScale.ipf"
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function WZcallLatticeCalculation(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			DisplayProcedure/W=$"WZCalculateLattice.ipf"
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function WZcallRecAtomLoc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			DisplayProcedure/W=$"WZRecordAtomLoc.ipf"
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function WZcallVisImage(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			DisplayProcedure/W=$"WZShowImageSlider.ipf"
			DisplayProcedure/W=$"WZShowGraphs.ipf"
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End




Function Linecut3DHProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			string dataname=GetBrowserSelection(0);
			if(cmpstr(dataname,"")==0)
				print "No selected wave";
				return 0;
			endif;		
			string targetQ,startP,endP,linewidth
			Prompt targetQ, "Enter targetQ"
			Prompt startP, "Enter startP"
			Prompt endP, "Enter endP"
			Prompt linewidth, "linewidth"
			Doprompt "Enter valuess:", targetQ,startP,endP,linewidth
			Lineprofile_3D_hor($dataname, str2num(targetQ),str2num(startP), str2num(endP),str2num(linewidth));
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function LineCut3DVProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			string dataname=GetBrowserSelection(0);
			if(cmpstr(dataname,"")==0)
				print "No selected wave";
				return 0;
			endif;		
			string targetP,startQ,endQ,linewidth
			Prompt targetP, "Enter targetP"
			Prompt startQ, "Enter startQ"
			Prompt endQ, "Enter endQ"
			Prompt linewidth, "linewidth"
			Doprompt "Enter valuess:", targetP,startQ,endQ,linewidth
			Lineprofile_3D_ver($dataname, str2num(targetP),str2num(startQ), str2num(endQ),str2num(linewidth));
			break;
		case -1: // control being killed
			break
	endswitch;
	return 0
End

Function Get3DlayerProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			string dataname=GetBrowserSelection(0);
			if(cmpstr(dataname,"")==0)
				print "No selected wave";
				return 0;
			endif;		
			string layer
			Prompt layer, "Enter Layer:"
			Doprompt "Enter values:", layer
			GetdIdVLayer($dataname, str2num(layer))
			break;
		case -1: // control being killed
			break
	endswitch;
	return 0
End


Function Linecut2DHProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			string dataname=GetBrowserSelection(0);
			if(cmpstr(dataname,"")==0)
				print "No selected wave";
				return 0;
			endif;		
			string targetQ,startP,endP,linewidth
			Prompt targetQ, "Enter targetQ"
			Prompt startP, "Enter startP"
			Prompt endP, "Enter endP"
			Prompt linewidth, "linewidth"
			Doprompt "Enter values:", targetQ,startP,endP,linewidth
			Lineprofile_2D_hor($dataname, str2num(targetQ),str2num(startP), str2num(endP),str2num(linewidth));
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function LineCut2DVProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			string dataname=GetBrowserSelection(0);
			if(cmpstr(dataname,"")==0)
				print "No selected wave";
				return 0;
			endif;		
			string targetP,startQ,endQ,linewidth
			Prompt targetP, "Enter targetP"
			Prompt startQ, "Enter startQ"
			Prompt endQ, "Enter endQ"
			Prompt linewidth, "linewidth"
			Doprompt "Enter values:", targetP,startQ,endQ,linewidth
			Lineprofile_2D_ver($dataname, str2num(targetP),str2num(startQ), str2num(endQ),str2num(linewidth));
			break;
		case -1: // control being killed
			break
	endswitch;
	return 0
End