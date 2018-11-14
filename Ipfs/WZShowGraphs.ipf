#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//These functions display 1D traces or 2D images
//***showSpectroscopy()
//***show2DdI/dV()
//***ShowTopograph()




function showSpectroscopy()
	string dataName = GetBrowserSelection(0);
	if (strlen(dataName) == 0)
		return 0;
	endif
	display/K=1 $(dataName)
	variable i;
	for (i = 1; strlen(GetBrowserSelection(i)) != 0; i+=1)
		AppendToGraph $(GetBrowserSelection(i))
	endfor
	ClassicSPS();
	ModifyGraph font="Times New Roman", axThick=1, lsize=1.5 
end


function show2DdIdV()
	wave data=$GetBrowserSelection(0)
	if(wavedims(data)!=2)
		print "Wrong dimensions";
		return 0;
	endif
	Display/W=(330,4,660,241) as NameofWave(data)+"|"+GetWavesDataFolder(data, 1)
	AppendImage data
	ModifyImage $(NameOfWave(data)) ctab= {*,*,Grays,0} //cannot use data directly, weird
	ModifyGraph margin(left)=36,margin(bottom)=36,margin(top)=7,margin(right)=7
	ModifyGraph tick=2
	ModifyGraph mirror=1
	ModifyGraph nticks(left)=6
	ModifyGraph font="Times New Roman"
	ModifyGraph sep(left)=2,sep(bottom)=3
	ModifyGraph fSize=12
	ModifyGraph lblMargin(bottom)=3
	ModifyGraph standoff=0
	Label left "\\f02E\\f00 (e\\U)"
	Label bottom "\\f02x\\f00 (\\U)"
end


Function ShowTopograph(data)
	Wave data
	Variable lower_lim, upper_lim, sigma
	lower_lim = AVG(data)
	sigma = STD(data)	
	upper_lim = lower_lim
	
	lower_lim -= 3*sigma
	upper_lim += 3*sigma
	lower_lim = round(lower_lim*1E12)*1E-12
	upper_lim = round(upper_lim*1E12)*1E-12
	Variable width = DimSize(data, 0)*72/ScreenResolution
	Variable height = DimSize(data, 1)*72/ScreenResolution
	Variable ratio = round(0.5+96/width)/round(0.5+width/768)
	width = width*ratio
	height = height*ratio
	if(width<128)
		width*=2;
		height*=2;
	endif
	
	NewImage/K=0  data
	DoWindow/T kwTopWin, NameofWave(data)+"|"+GetWavesDataFolder(data, 1)
	ModifyGraph tick=3, noLabel=2, margin=1, axthick=0
	ModifyGraph width=width,height=height
	ModifyImage $(NameOfWave(data)) ctab={lower_lim, upper_lim, Grays, 0}
	SetAxis/A left
End //ShowTopograph


//********************************************************************************//
//********************************************************************************//
//********************************************************************************//
function ClassicSPS()
	StylishAxis()
	SetTraceColor()
	SetdIdVaxis()
	SetAxis left 0,*
	ModifyGraph width=216,height=216
	ModifyGraph margin(left)=50,margin(bottom)=45,margin(top)=10,margin(right)=15
	legend/B=1
end

Function StylishAxis()
	ModifyGraph tick=2,fSize=16,axThick=2, mirror=1, lsize=2, btLen=4
End //StylishAxis

Function SetdIdVaxis()
	Label bottom "Sample bias(\\U)"; 
	Label left "\f02dI/dV\f00(a.u.)"; 
	ModifyGraph standoff=0, lblPosMode=3, lblPos=50, tickUnit=1
End //SetdIdVaxis

Function SetTraceColor()
	String TraceList = TraceNameList("",";",1), item
	Variable numTrace = ItemsinList(TraceList), i
	Variable ink = 256/(numTrace-1)
	ColorTab2Wave rainbow256
	Wave/I/U M_colors
	For(i=0; i<numTrace; i+=1)
		item=StringFromList(i,TraceList, ";")
		ModifyGraph rgb($item)=(M_colors[i*ink][0], M_colors[i*ink][1], M_colors[i*ink][2])
	Endfor
	KillWaves/z M_colors
End //SetTraceColor
//********************************************************************************//
//********************************************************************************//
//********************************************************************************//