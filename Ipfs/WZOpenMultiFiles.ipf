#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

#include <All IP Procedures>
#include <Image Saver>
#include <PopupWaveSelector>

Menu "JD@%$"
	"LoadMatrixData", LoadMatrixData()
End

Function/S LoadMatrixData()
	Variable refNum
	String message = "Select one or more files"
	String outputPaths
	String fileFilters = "Data Files:.ibw;"
	Open /D /R /MULT=1 /F=fileFilters /M=message refNum
	outputPaths = S_fileName
	//print S_fileName
	if (strlen(outputPaths) == 0)
		Print "Cancelled"
	else
		Variable numFilesSelected = ItemsInList(outputPaths, "\r")
		Variable i
		for(i=0; i<numFilesSelected; i+=1)
			String path = StringFromList(i, outputPaths, "\r")
			LoadWave/Q/D/O/H path
			renamematrixdata($(StringFromList(0, S_waveNames, ";")))
			//Printf "%d: %s\r", i, path
		endfor
	endif
	
	return outputPaths // Will be empty if user canceled
End


function RenameMatrixData(data)
	wave data
	
	String expr, run, scan, direction, channel
	
	if (StringMatch(NameOfWave(data), "Z*")==1)

		expr="Z ([[:digit:]]+)-([[:digit:]]+) ([[:ascii:]]+)"
		
		SplitString/E=(expr) NameOfWave(data), run, scan, direction
	
		if (strlen(run)==1)
			run = "0"+run
		endif
	
		if (!cmpstr(scan, "1"))
			scan = ""
		else
			scan = "_"+scan
		endif
	
		strswitch(direction)	
			case "Forward Up":
				direction = "FU"
				break
			case "Forward Down":	
				direction = "FD"
				break
			case "Backward Up":
				direction = "BU"
				break
			case "Backward Down":	
				direction = "BD"
				break	
			default:
				direction = ""
		endswitch
	
		string newName = "Z"+direction+run+scan	
	
	elseif (StringMatch(NameOfWave(data), "SPS*")==1)
	
		expr="SPS ([[:ascii:]]+) ([[:digit:]]+)-([[:digit:]]+) ([[:ascii:]]+)"
		SplitString/E=(expr) NameOfWave(data), channel, run, scan,direction
		if(StringMatch(channel,"Aux1(V)")==1)
			channel="dIdV";
		elseif(StringMatch(channel,"Aux2(V)")==1)
			channel="Aux2";
		elseif(StringMatch(channel,"I(V)")==1)
			channel="IV";
		endif
		if (strlen(run)==1)
			run = "0"+run
		endif
		
		if (!cmpstr(scan, "1"))
			scan = "_1"
		else
			scan = "_"+scan
		endif
		
		if(!cmpstr(direction,"Trace"))
			direction="T"
		else
			direction="R"
		endif
		newName = channel+run+scan+direction
		
	elseif ((StringMatch(NameOfWave(data), "Aux1(V)*")==1))
		expr="Aux1\(V\) ([[:digit:]]+)-([[:digit:]]+) ([[:ascii:]]+)"
		SplitString/E=(expr) NameOfWave(data), run, scan, direction
		
		newName = "Aux1_"+run
		
	endif
	
	rename data, $(newName)
end
