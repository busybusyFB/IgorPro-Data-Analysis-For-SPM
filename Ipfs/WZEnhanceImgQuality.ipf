#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//////////////////////////
//Created by Wenhan
//////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function Callimgenhance()		//This function is used to display this procedure file conveniencely
	DisplayProcedure/W=$"WZEnhanceImgQuality.ipf"
end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//---------------------The first approach-------------------//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//This function can effectively enhance the atomic corrugation by averaging the cropped
//images with the same phase. The phase is characterized by the correlation coefficient.

//Tips:
//If the result is not good enough, try the approaches:
//1. Change to another initial image (data_crop) as reference 
//2. Apply the function "EnhanceAtomResHistAnalysis()" to analyze the histogram of the
//filtered correlation matrix and find a specialized criteria.

function EnhanceAtomRes(data,NewTopoDim)	//version 1
	wave data;
	variable NewTopoDim;
	print "This function may take up to 10 minutes.";
	NewTopoDim=round(Dimsize(data,0)/8);
	//By default, the dimention of cropped image is 1/8 of large image.
	variable newDimX=128;
	variable newDimY=128;
	make/O/N=(newDimX,newDimY) $(nameofwave(data)+"_Enhance");
	wave data_crop=$(nameofwave(data)+"_Enhance")
	data_crop=data[p][q];
	duplicate/O data_crop, tempcrop;
	//Generate the correlation coefficient matrix
	make/O/N=(Dimsize(data,0)-newDimX+1,Dimsize(data,1)-newDimY+1) CroCor
	variable i,j
	for(i=0;i<Dimsize(CroCor,0);i+=1)
	for(j=0;j<Dimsize(CroCor,1);j+=1)
	tempcrop=data[i+p][j+q];
	CroCor[i][j]=CrossCor(tempcrop,data_crop);
	endfor
	endfor
	variable m,n;
	data_crop=0;
	duplicate/O CroCor,CroCor_filtered;
	CroCor_filtered=0;
	make/O/N=(5,5) CroCor_Crop;
	variable count=0
	//Filter the right cropped images which are applied to enhanced images
	for(m=2;m<Dimsize(CroCor,0)-2;m+=1)
	for(n=2;n<Dimsize(CroCor,1)-2;n+=1)
		CroCor_Crop=CroCor[m+p-2][n+q-2];
		if(CroCor_Crop[2][2]==wavemax(CroCor_Crop))
		//if the correlaiton coefficient is local max, then the cropped image is applied.
			CroCor_filtered[m][n]=1;
			if(CroCor[m][n]>0)
			//if correlation coefficient too small (<0), abandon
				tempcrop=data[p+m][q+n];
				data_crop+=tempcrop;
				count+=1;
			endif
		endif
	endfor
	endfor
	data_crop/=count; //data_crop is the enhanced image
	killwaves tempcrop;
	killwaves CroCor,CroCor_Crop,CroCor_filtered
End //end of EnhanceAtomRes()

//This function fine-tunes the criteria of selecting the cropped images.
//Decommentize in the funciton above: killwaves CroCor,CroCor_Crop,CroCor_filtered.
//The waves CroCor,CroCor_Crop,CroCor_filtered are required.
function EnhanceAtomResHistAnalysis()
	wave CroCor;
	wave CroCor_filtered;
	make/O/N=0 corlist;
	variable a,b;
	for(a=0;a<Dimsize(CroCor,0);a+=1)
	for(b=0;b<Dimsize(CroCor,1);b+=1)
		if(CroCor_filtered[a][b]==1)
			InsertPoints dimsize(Corlist,0),1, Corlist;
			Corlist[dimsize(Corlist,0)-1]=CroCor[a][b];
		endif
	endfor
	endfor
	Make/O/N=100 corlist_Hist;
	Histogram/B=1 corlist,corlist_Hist;
	Display corlist_Hist;
End //end of EnhanceAtomResHistAnalysis()
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////
//
//
/////////////*******************Image noise filter functions*******************///////////
//
//
//////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//These two functions are used to make circle masks to filter short-range noise in topographic images
Function Fermifunction(distance,EdgeWidth,flip)
	variable distance,EdgeWidth,flip
	variable y;
	y=1/(1+exp(-distance/EdgeWidth))
	if(flip==1)
		y=1-y;
	endif
	return y;
End //Fermifunction
//////////////////////////////////////////////////////////////////////////////////////////
Function MakecircleMask(AreaDimX, AreaDimY,MaskSize, EdgeWidth,MaskCenterX, MaskCenterY,flip)
	variable AreaDimX, AreaDimY, MaskSize, EdgeWidth, MaskCenterX, MaskCenterY, flip
//if flip=1, the selected area is 1; otherwise, the selected area is 0;
	variable distance;
	make/O/N=(AreaDimX, AreaDimY) $("CircleMask")
	wave mask=$("CircleMask")
	variable i,j;
	for(i=0;i<AreaDimX;i+=1)
		for(j=0;j<AreaDimY;j+=1)
			distance=sqrt((i-MaskcenterX)^2+(j-MaskcenterY)^2)-masksize
			mask[i][j]=Fermifunction(distance,EdgeWidth,flip);
		endfor
	endfor
	showtopograph(mask);
End //MakecircleMask
//////////////////////////////////////////////////////////////////////////////////////////
//used to crop a 3D FFT matrix with a circle mask
function CropFFT(data, mask)
wave/c data
wave mask
variable i,j,k;
data[][][]*=mask[p][q];
End //CropFFT
//////////////////////////////////////////////////////////////////////////////////////////
Function softTopoEdge(data)
	wave data;
	duplicate/O data, $(nameofwave(data)+"SoftEdge"), softedgeMask;
	wave newdata=$(nameofwave(data)+"SoftEdge");
	wave softedgemask;
	softedgemask=1;
	variable centerP=(dimsize(data,0)-1)/2;
	variable centerq=(dimsize(data,1)-1)/2;
//	print centerp,centerq;
	variable i,j;
	for(i=0;i<dimsize(data,0);i+=1)
		for(j=0;j<dimsize(data,1);j+=1)
			softedgemask[i][j]*=fermifunction(abs(i-centerp)-0.48*dimsize(data,0),6,1);
			softedgemask[i][j]*=fermifunction(abs(j-centerq)-0.48*dimsize(data,1),6,1);			
		endfor
	endfor
	newdata=data*softedgemask;
End //softTopoEdge
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
