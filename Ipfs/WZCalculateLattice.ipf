#pragma TextEncoding = "UTF-8"
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma moduleName=startup    // traditional for static functions
////////////////////////////////////////////////////////////////////////////////////////////////

menu "WZFunc"
	"WZLatticeCalculation", WZLatticCalculation()
end

Window WZLatticCalculation(): Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel/K=1 /W=(1130,484,1700,809) as "Lattic Calculation"
	SetDrawLayer UserBack
	SetDrawEnv fsize= 14
	DrawText 150,25,"Calculate Lattice Constant in FFT"
	DrawText 10,50,"\\f01Hexagonal"
	DrawText 80,65,"2×Δk\\BX"
	DrawText 150,65,"2×Δk\\By"
	DrawText 220,65,"2×Δk"
	DrawText 290,65,"Δk"
	DrawText 360,65,"a(nm)"
	DrawText 430,65,"Avg a(nm)"
	DrawText 500,65,"std"
	DrawText 18,170,"\\f01Square"
	SetDrawEnv fsize= 14
	DrawText 170,250,"Calculate Included Angle"
	DrawText 430,260,"θ(rad)"
	DrawText 500,260,"θ(°)"
	DrawLine 10,230,495,230
	InitializeLatticeCal()
	ValDisplay valdisp0,pos={70.00,70.00},size={60.00,17.00}
	ValDisplay valdisp0,value=root:WinGlobals:LatticeCal:Hex1x,format="%.3e"
	ValDisplay valdisp1,pos={140.00,70.00},size={60.00,17.00}
	ValDisplay valdisp1,value=root:WinGlobals:LatticeCal:Hex1y,format="%.3e"
	ValDisplay valdisp2,pos={210.00,70.00},size={60.00,17.00}
	ValDisplay valdisp2,value=root:WinGlobals:LatticeCal:Hex1k2,format="%.3e"
	ValDisplay valdisp3,pos={280.00,70.00},size={60.00,17.00}
	ValDisplay valdisp3,value=root:WinGlobals:LatticeCal:Hex1k,format="%.3e"
	ValDisplay valdisp4,pos={350.00,70.00},size={60.00,17.00}
	ValDisplay valdisp4,value=root:WinGlobals:LatticeCal:Hex1a,format="%.3e"
	ValDisplay valdisp5,pos={70.00,100.00},size={60.00,17.00}
	ValDisplay valdisp5,value=root:WinGlobals:LatticeCal:Hex2x,format="%.3e"
	ValDisplay valdisp6,pos={140.00,100.00},size={60.00,17.00}
	ValDisplay valdisp6,value=root:WinGlobals:LatticeCal:Hex2y,format="%.3e"
	ValDisplay valdisp7,pos={210.00,100.00},size={60.00,17.00}
	ValDisplay valdisp7,value=root:WinGlobals:LatticeCal:Hex2k2,format="%.3e"
	ValDisplay valdisp8,pos={280.00,100.00},size={60.00,17.00}
	ValDisplay valdisp8,value=root:WinGlobals:LatticeCal:Hex2k,format="%.3e"
	ValDisplay valdisp9,pos={350.00,100.00},size={60.00,17.00}
	ValDisplay valdisp9,value=root:WinGlobals:LatticeCal:Hex2a,format="%.3e"
	ValDisplay valdisp10,pos={70.00,130.00},size={60.00,17.00}
	ValDisplay valdisp10,value=root:WinGlobals:LatticeCal:Hex3x,format="%.3e"
	ValDisplay valdisp11,pos={140.00,130.00},size={60.00,17.00}
	ValDisplay valdisp11,value=root:WinGlobals:LatticeCal:Hex3y,format="%.3e"
	ValDisplay valdisp12,pos={210.00,130.00},size={60.00,17.00}
	ValDisplay valdisp12,value=root:WinGlobals:LatticeCal:Hex3k2,format="%.3e"
	ValDisplay valdisp13,pos={280.00,130.00},size={60.00,17.00}
	ValDisplay valdisp13,value=root:WinGlobals:LatticeCal:Hex3k,format="%.3e"
	ValDisplay valdisp14,pos={350.00,130.00},size={60.00,17.00}
	ValDisplay valdisp14,value=root:WinGlobals:LatticeCal:Hex3a,format="%.3e"
	ValDisplay valdisp15,pos={420.00,100.00},size={60.00,17.00}
	ValDisplay valdisp15,value=root:WinGlobals:LatticeCal:HexAvga,format="%.3e"
	ValDisplay valdisp16,pos={490.00,100.00},size={60.00,17.00}
	ValDisplay valdisp16,value=root:WinGlobals:LatticeCal:HexStd,format="%.3e"
	Button button0,pos={12.00,68.00},size={50.00,20.00},title="Get1",proc=HexGet1Proc
	Button button1,pos={12.00,98.00},size={50.00,20.00},title="Get2",proc=HexGet2Proc
	Button button2,pos={12.00,128.00},size={50.00,20.00},title="Get3",proc=HexGet3Proc
	ValDisplay valdisp17,pos={70.00,175.00},size={60.00,17.00}
	ValDisplay valdisp17,value=root:WinGlobals:LatticeCal:Sqr1x,format="%.3e"
	ValDisplay valdisp18,pos={140.00,175.00},size={60.00,17.00}
	ValDisplay valdisp18,value=root:WinGlobals:LatticeCal:Sqr1y,format="%.3e"
	ValDisplay valdisp19,pos={210.00,175.00},size={60.00,17.00}
	ValDisplay valdisp19,value=root:WinGlobals:LatticeCal:Sqr1k2,format="%.3e"
	ValDisplay valdisp20,pos={280.00,175.00},size={60.00,17.00}
	ValDisplay valdisp20,value=root:WinGlobals:LatticeCal:Sqr1k,format="%.3e"
	ValDisplay valdisp21,pos={350.00,175.00},size={60.00,17.00}
	ValDisplay valdisp21,value=root:WinGlobals:LatticeCal:Sqr1a,format="%.3e"
	ValDisplay valdisp22,pos={70.00,205.00},size={60.00,17.00}
	ValDisplay valdisp22,value=root:WinGlobals:LatticeCal:Sqr2x,format="%.3e"
	ValDisplay valdisp23,pos={140.00,205.00},size={60.00,17.00}
	ValDisplay valdisp23,value=root:WinGlobals:LatticeCal:Sqr2y,format="%.3e"
	ValDisplay valdisp24,pos={210.00,205.00},size={60.00,17.00}
	ValDisplay valdisp24,value=root:WinGlobals:LatticeCal:Sqr2k2,format="%.3e"
	ValDisplay valdisp25,pos={280.00,205.00},size={60.00,17.00}
	ValDisplay valdisp25,value=root:WinGlobals:LatticeCal:Sqr2k,format="%.3e"
	ValDisplay valdisp26,pos={350.00,205.00},size={60.00,17.00}
	ValDisplay valdisp26,value=root:WinGlobals:LatticeCal:Sqr2a,format="%.3e"
	ValDisplay valdisp27,pos={420.00,190.00},size={60.00,17.00}
	ValDisplay valdisp27,value=root:WinGlobals:LatticeCal:SqrAvga,format="%.3e"
	ValDisplay valdisp28,pos={490.00,190.00},size={60.00,17.00}
	ValDisplay valdisp28,value=root:WinGlobals:LatticeCal:SqrStd,format="%.3e"
	Button button3,pos={12.00,173.00},size={50.00,20.00},title="Get1",proc=SqrGet1Proc
	Button button4,pos={12.00,203.00},size={50.00,20.00},title="Get2",proc=SqrGet2Proc
	ValDisplay valdisp29,pos={70.00,260.00},size={60.00,17.00}
	ValDisplay valdisp29,value=root:WinGlobals:LatticeCal:L1x,format="%.3e"
	ValDisplay valdisp30,pos={140.00,260.00},size={60.00,17.00}
	ValDisplay valdisp30,value=root:WinGlobals:LatticeCal:L1y,format="%.3e"
	ValDisplay valdisp31,pos={70.00,290.00},size={60.00,17.00}
	ValDisplay valdisp31,value=root:WinGlobals:LatticeCal:L2x,format="%.3e"
	ValDisplay valdisp32,pos={140.00,290.00},size={60.00,17.00}
	ValDisplay valdisp32,value=root:WinGlobals:LatticeCal:L2y,format="%.3e"
	ValDisplay valdisp33,pos={420.00,275.00},size={60.00,17.00}
	ValDisplay valdisp33,value=root:WinGlobals:LatticeCal:ThetaRad,format="%.3f"
	ValDisplay valdisp34,pos={490.00,275.00},size={60.00,17.00}
	ValDisplay valdisp34,value=root:WinGlobals:LatticeCal:ThetaDeg,format="%.3f"		
	Button button5,pos={12.00,258.00},size={50.00,20.00},title="Get1",proc=AngleGet1Proc
	Button button6,pos={12.00,288.00},size={50.00,20.00},title="Get2",proc=AngleGet2Proc
EndMacro

Function InitializeLatticeCal()
	newdatafolder/O root:WinGlobals
	newdatafolder/O root:WinGlobals:LatticeCal
	String dfSav= GetDataFolder(1)
	SetDataFolder root:WinGlobals:LatticeCal
	Variable/G Hex1x,Hex1y; Hex1x=0;Hex1y=0;	// The first line of hex
	Variable/G Hex1k2,Hex1k,Hex1a; Hex1k2=0;Hex1k=0;Hex1a=0;
	Variable/G Hex2x,Hex2y; Hex2x=0;Hex2y=0;	// The second line of hex
	Variable/G Hex2k2,Hex2k,Hex2a; Hex2k2=0;Hex2k=0;Hex2a=0;
	Variable/G Hex3x,Hex3y; Hex3x=0;Hex3y=0;	// The third line of hex
	Variable/G Hex3k2,Hex3k,Hex3a; Hex3k2=0;Hex3k=0;Hex3a=0;
	Variable/G HexAvga,HexStd; HexAvga=0;HexStd=0;
	Variable/G Sqr1x,Sqr1y; Sqr1x=0;Sqr1y=0;	// The first line of square
	Variable/G Sqr1k2,Sqr1k,Sqr1a; Sqr1k2=0;Sqr1k=0;Sqr1a=0;
	Variable/G Sqr2x,Sqr2y; Sqr2x=0;Sqr2y=0;	// The second line of square
	Variable/G Sqr2k2,Sqr2k,Sqr2a; Sqr2k2=0;Sqr2k=0;Sqr2a=0;
	Variable/G SqrAvga,SqrStd; SqrAvga=0;SqrStd=0;
	Variable/G L1x,L1y; L1x=0;L1y=0;				//Line 1 for the angle
	Variable/G L2x,L2y; L2x=0;L2y=0;				//Line 2 for the angle
	Variable/G ThetaRad,ThetaDeg; ThetaRad=0;ThetaDeg=0;
	SetDataFolder dfSav
End

Function UpdateHexAvg()
	String dfSav= GetDataFolder(1);
	SetDataFolder root:WinGlobals:LatticeCal;
	Variable/G Hex1a,Hex2a,Hex3a;
	Variable/G HexAvga=(Hex1a+Hex2a+Hex3a)/3;
	Variable/G HexStd=sqrt((Hex1a-HexAvga)^2+(Hex2a-HexAvga)^2+(Hex3a-HexAvga)^2)/sqrt(3);
	SetDataFolder dfSav;
End

Function HexGet1Proc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			String dfSav= GetDataFolder(1);
			SetDataFolder root:WinGlobals:LatticeCal;
			Variable/G Hex1x=hcsr(B)-hcsr(A);
			Variable/G Hex1y=vcsr(B)-vcsr(A);
			Variable/G Hex1k2=sqrt(Hex1x^2+Hex1y^2);
			Variable/G Hex1k=Hex1k2/2;
			Variable/G Hex1a=2*pi*2/sqrt(3)/Hex1k;
			SetDataFolder dfSav;
			UpdateHexAvg();
			break;
		case -1:
			break;
	endswitch
End

Function HexGet2Proc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			String dfSav= GetDataFolder(1);
			SetDataFolder root:WinGlobals:LatticeCal;
			Variable/G Hex2x=hcsr(B)-hcsr(A);
			Variable/G Hex2y=vcsr(B)-vcsr(A);
			Variable/G Hex2k2=sqrt(Hex2x^2+Hex2y^2);
			Variable/G Hex2k=Hex2k2/2;
			Variable/G Hex2a=2*pi*2/sqrt(3)/Hex2k;
			SetDataFolder dfSav;
			UpdateHexAvg();
			break;
		case -1:
			break;
	endswitch
End

Function HexGet3Proc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			String dfSav= GetDataFolder(1);
			SetDataFolder root:WinGlobals:LatticeCal;
			Variable/G Hex3x=hcsr(B)-hcsr(A);
			Variable/G Hex3y=vcsr(B)-vcsr(A);
			Variable/G Hex3k2=sqrt(Hex3x^2+Hex3y^2);
			Variable/G Hex3k=Hex3k2/2;
			Variable/G Hex3a=2*pi*2/sqrt(3)/Hex3k;
			SetDataFolder dfSav;
			UpdateHexAvg();
			break;
		case -1:
			break;
	endswitch
End

Function UpdateSqrAvg()
	String dfSav= GetDataFolder(1);
	SetDataFolder root:WinGlobals:LatticeCal;
	Variable/G Sqr1a,Sqr2a,Sqr3a;
	Variable/G SqrAvga=(Sqr1a+Sqr2a+Sqr3a)/3;
	Variable/G SqrStd=sqrt((Sqr1a-SqrAvga)^2+(Sqr2a-SqrAvga)^2+(Sqr3a-SqrAvga)^2)/sqrt(3);
	SetDataFolder dfSav;
End

Function SqrGet1Proc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			String dfSav= GetDataFolder(1);
			SetDataFolder root:WinGlobals:LatticeCal;
			Variable/G Sqr1x=hcsr(B)-hcsr(A);
			Variable/G Sqr1y=vcsr(B)-vcsr(A);
			Variable/G Sqr1k2=sqrt(Sqr1x^2+Sqr1y^2);
			Variable/G Sqr1k=Sqr1k2/2;
			Variable/G Sqr1a=2*pi*2/sqrt(3)/Sqr1k;
			SetDataFolder dfSav;
			UpdateSqrAvg();
			break;
		case -1:
			break;
	endswitch
End

Function SqrGet2Proc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			String dfSav= GetDataFolder(1);
			SetDataFolder root:WinGlobals:LatticeCal;
			Variable/G Sqr2x=hcsr(B)-hcsr(A);
			Variable/G Sqr2y=vcsr(B)-vcsr(A);
			Variable/G Sqr2k2=sqrt(Sqr2x^2+Sqr2y^2);
			Variable/G Sqr2k=Sqr2k2/2;
			Variable/G Sqr2a=2*pi*2/sqrt(3)/Sqr2k;
			SetDataFolder dfSav;
			UpdateSqrAvg();
			break;
		case -1:
			break;
	endswitch
End

Function SqrGet3Proc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			String dfSav= GetDataFolder(1);
			SetDataFolder root:WinGlobals:LatticeCal;
			Variable/G Sqr1x=hcsr(B)-hcsr(A);
			Variable/G Sqr1y=vcsr(B)-vcsr(A);
			Variable/G Sqr1k2=sqrt(Sqr1x^2+Sqr1y^2);
			Variable/G Sqr1k=Sqr1k2/2;
			Variable/G Sqr1a=2*pi*2/sqrt(3)/Sqr1k;
			SetDataFolder dfSav;
			UpdateSqrAvg();
			break;
		case -1:
			break;
	endswitch
End

Function UpdateAngle()
	String dfSav= GetDataFolder(1);
	SetDataFolder root:WinGlobals:LatticeCal;
	Variable/G L1x,L1y,L2x,L2y;
	variable costheta=(L1x*L2x+L1y*L2y)/sqrt(L1x^2+L1y^2)/sqrt(L2x^2+L2y^2)
	Variable/G ThetaRad=acos(costheta);
	Variable/G ThetaDeg=ThetaRad/pi*180
	SetDataFolder dfSav;
End

Function AngleGet1Proc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			String dfSav= GetDataFolder(1);
			SetDataFolder root:WinGlobals:LatticeCal;
			Variable/G L1x=hcsr(B)-hcsr(A);
			Variable/G L1y=vcsr(B)-vcsr(A);
			SetDataFolder dfSav;
			UpdateAngle();
			break;
		case -1:
			break;
	endswitch
End

Function AngleGet2Proc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			String dfSav= GetDataFolder(1);
			SetDataFolder root:WinGlobals:LatticeCal;
			Variable/G L2x=hcsr(B)-hcsr(A);
			Variable/G L2y=vcsr(B)-vcsr(A);
			SetDataFolder dfSav;
			UpdateAngle();
			break;
		case -1:
			break;
	endswitch
End