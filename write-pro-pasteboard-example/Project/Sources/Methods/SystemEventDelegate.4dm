//%attributes = {"invisible":true,"preemptive":"incapable"}
C_LONGINT:C283($1; $vL_SystemEvent)

$vL_SystemEvent:=$1

C_BOOLEAN:C305($vB_DisableFeature)

$vB_DisableFeature:=False:C215  //switch to bring back default behaviour

If (Not:C34($vB_DisableFeature))
	
	C_BLOB:C604($vX_PBData)
	C_TEXT:C284($vT_PBData)
	C_TEXT:C284($vT_PBDataType; $vT_NativeType)
	
	ARRAY TEXT:C222($aT_Signature; 0)
	ARRAY TEXT:C222($aT_NativeType; 0)
	ARRAY TEXT:C222($aT_FormatName; 0)
	
	ARRAY BLOB:C1222($aX_PBData; 0)
	
	C_COLLECTION:C1488($vC_PBSnapshot; $vC_PBCopy)
	
	C_TEXT:C284($vT_SemaphoreName)
	$vT_SemaphoreName:="com.4d.private.pasteboard.snapshot"
	
	Case of 
		: ($vL_SystemEvent=On application background move:K74:1)
			
			GET PASTEBOARD DATA TYPE:C958($aT_Signature; $aT_NativeType; $aT_FormatName)
			
			$vC_PBSnapshot:=New shared collection:C1527
			$vC_PBCopy:=New collection:C1472
			
			For ($i; 1; Size of array:C274($aT_Signature))
				
				$vT_PBDataType:=$aT_Signature{$i}  ///signature is platform agnostic
				$vT_NativeType:=$aT_NativeType{$i}  //signature maybe "" so use native type
				
				GET PASTEBOARD DATA:C401($vT_NativeType; $vX_PBData)
				APPEND TO ARRAY:C911($aX_PBData; $vX_PBData)
				
				Case of 
					: ($vT_NativeType="Apple HTML pasteboard type")
						
						//filter this type (wipes out existing rich  text)
						
					: ($vT_NativeType="public.html") | ($vT_PBDataType="com.4d.private.text.html")
						
/*
						
RTF is generally suitable for pasting "as is" to external apps
HTML originating from Write Pro is not
so remove it from the pasteboard when 4D goes to the background
						
TODO: use 4D.Blob object in 19 R2
						
*/
						
						BASE64 ENCODE:C895($vX_PBData; $vT_PBData)
						$vC_PBSnapshot.push(New shared object:C1526("type"; $vT_NativeType; "signature"; $vT_PBDataType; "data"; $vT_PBData))
						
					Else 
						
						$vC_PBCopy.push(New object:C1471("type"; $vT_NativeType; "signature"; $vT_PBDataType))
						
				End case 
				
			End for 
			
/*
			
some types of data cancel existing data
it is important to append in the right order
			
*/
			
			C_OBJECT:C1216($vJ_PBCopy)
			
			For each ($vJ_PBCopy; $vC_PBCopy)
				Case of 
					: ($vJ_PBCopy.type="public.rtf")
						$vJ_PBCopy.weight:=6
					: ($vJ_PBCopy.type="NeXT Rich Text Format v1.0 pasteboard type")
						$vJ_PBCopy.weight:=5
					: ($vJ_PBCopy.type="public.utf16-external-plain-text")
						$vJ_PBCopy.weight:=4
					: ($vJ_PBCopy.type="public.utf8-plain-text")
						$vJ_PBCopy.weight:=4
					: ($vJ_PBCopy.type="Apple HTML pasteboard type")
						$vJ_PBCopy.weight:=3
					: ($vJ_PBCopy.type="NSStringPboardType")
						$vJ_PBCopy.weight:=2
					: ($vJ_PBCopy.type="dyn.@")
						$vJ_PBCopy.weight:=1
					: ($vJ_PBCopy.type="CorePasteboardFlavorType@")
						$vJ_PBCopy.weight:=0
					Else 
						$vJ_PBCopy.weight:=9
				End case 
			End for each 
			
/*
			
there are no commands to remove specific pasteboard data
one must clear and rebuild content
			
*/
			
			$vC_PBCopy:=$vC_PBCopy.orderBy("weight asc")
			
			CLEAR PASTEBOARD:C402
			
/*
			
the semaphore data type is used to detect external changes
			
*/
			
			C_BLOB:C604($vX_Signal)
			SET BLOB SIZE:C606($vX_Signal; 1)
			APPEND DATA TO PASTEBOARD:C403($vT_SemaphoreName; $vX_Signal)
			
			For each ($vJ_PBCopy; $vC_PBCopy)
				
				$vT_PBDataType:=$vJ_PBCopy.signature
				$vT_NativeType:=$vJ_PBCopy.type
				$vX_PBData:=$aX_PBData{Find in array:C230($aT_NativeType; $vT_NativeType)}
				
				$vT_PBDataType:=Choose:C955($vT_PBDataType#""; $vT_PBDataType; $vT_NativeType)
				APPEND DATA TO PASTEBOARD:C403($vT_PBDataType; $vX_PBData)
				
			End for each 
			
/*
			
put the removed flavours (html) in storage
			
*/
			
			Use (Storage:C1525)
				Storage:C1525[$vT_SemaphoreName]:=$vC_PBSnapshot
			End use 
			
		: ($vL_SystemEvent=On application foreground move:K74:2)
			
/*
			
if the semaphore data type is absent
the pasteboard has new content
the stored data is obsolete
otherwise bring back stored html
			
*/
			
			If (Pasteboard data size:C400($vT_SemaphoreName)>0)
				
				$vC_PBSnapshot:=Storage:C1525[$vT_SemaphoreName]
				
				C_OBJECT:C1216($vJ_PBSnapshot)
				
				For each ($vJ_PBSnapshot; $vC_PBSnapshot)
					
					$vT_PBData:=$vJ_PBSnapshot.data
					$vT_PBDataType:=$vJ_PBSnapshot.signature
					$vT_NativeType:=$vJ_PBSnapshot.type
					
					BASE64 DECODE:C896($vT_PBData; $vX_PBData)
					$vT_PBDataType:=Choose:C955($vT_PBDataType#""; $vT_PBDataType; $vT_NativeType)
					APPEND DATA TO PASTEBOARD:C403($vT_PBDataType; $vX_PBData)
					
				End for each 
				
			End if 
			
	End case 
	
End if 