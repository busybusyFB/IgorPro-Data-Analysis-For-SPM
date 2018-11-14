#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=1		// Use modern global access method and strict wave access.

#include <All IP Procedures>
#include <Image Saver>
#include <PopupWaveSelector>
#pragma moduleName=startup    // traditional for static functions

function CallClick()		
	DisplayProcedure/W=$"RecordAtomLoc.ipf"
end

menu "WZFunc"
	"RecordStiesByMouse", RecordAtomLocation()
end

Function RecordAtomLocation()
	string topoName, coorName
	Prompt topoName, "Enter the name of topographic image"
	Prompt coorName, "Enter the name of waves recording the coordinates"
	Doprompt "Enter Names:", topoName, coorName
	if(cmpstr(topoName, "")==0)
		return 0;
	endif
	string/G Coordinate=coorname;
	string/G imageName=topoName;
	make/O/N=0 $(coorName+"_x"), $(coorName+"_y")
	wave xcoor=$(coorName+"_x")
	wave ycoor=$(coorName+"_y")
	wave data=$(topoName)
	variable/G width=Dimsize(data,0)/96*72;
	variable/G height=Dimsize(data,1)/96*72;
	variable/G Flag_shrink=0;
	if(Dimsize(data,1)>800)
		width=648;
		height=648;
//		width=width*0.75;
//		height=height*0.75;
		Flag_shrink=1;
	endif
	NewImage/K=1  data
	DoWindow/T kwTopWin, NameofWave(data)+"|"+GetWavesDataFolder(data, 1)
	ModifyGraph tick=3, noLabel=2, margin=3, axthick=0
	ModifyGraph width=width,height=height
	ModifyImage $(NameOfWave(data)) ctab={*, *, VioletOrangeYellow, 0}
	SetAxis/A left
	controlbar 35
	variable/G CurrentAtomNum=0
	ValDisplay valdisp0,pos={10.00,10.00},size={130,17.00},title="Num of selection"
	ValDisplay valdisp0,limits={0,0,0},barmisc={0,1000},value= #(GetDataFolder(1)+"CurrentAtomNum")
	Button Button1,pos={160,9},size={100,20},proc=ResetProc,title="StartOver"
	setwindow kwTopWin, hook(MyHook)=ClickonAtomHook

End


Function ClickonAtomHook(s)
	STRUCT WMWinHookStruct &s
	string/G Coordinate,imagename
	wave data=$(imagename)
	variable/G width,height,CurrentAtomNum,Flag_shrink;
	wave xcoor=$(Coordinate+"_x")
	wave ycoor=$(Coordinate+"_y")
	Variable hookResult = 0 // 0 if we do not handle event, 1 if we handle it.
	switch(s.eventCode)
		case 3:
//			print s.mouseLoc.h,s.mouseLoc.v
			if(s.mouseLoc.v<4)
				break;
			endif
			InsertPoints dimsize(xcoor,0), 1, xcoor
			InsertPoints dimsize(ycoor,0), 1, ycoor
			xcoor[dimsize(xcoor,0)-1]=(s.mouseLoc.h-4)*dimdelta(data,0)*(Flag_shrink*4/3+1)
			ycoor[dimsize(ycoor,0)-1]=(height/3*4-s.mouseLoc.v+4)*dimdelta(data,1)*(Flag_shrink*4/3+1)
			variable circleleft=s.mouseLoc.h/width*0.75
			variable circletop=s.mouseLoc.v/height*0.75
			SetDrawEnv linethick= 0,fillfgc= (0,0,65535)
			DrawOval circleleft-0.013, circletop-0.013, circleleft-0.003, circletop-0.003
			CurrentAtomNum+=1;
			break
		case 2:
			Killstrings Coordinate,Imagename
			Killvariables height, width,CurrentAtomNum	,Flag_shrink		
			break;
	endswitch
	return hookResult // If non-zero, we handled event and Igor will ignore it.
End

Function ResetProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			resetRecording();
			break;
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function resetRecording()
	string/G Coordinate
	wave xwave=$(Coordinate+"_x"),ywave=$(Coordinate+"_y")
	Redimension/N=0 xwave, ywave
	variable/G CurrentAtomNum=0;
	SetDrawLayer/K UserFront
End