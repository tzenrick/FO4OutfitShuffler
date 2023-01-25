Scriptname OutfitShufflerMaintainer extends ActiveMagicEffect
{Attempts to maintain outfits assigned by the OutfitShuffler Main Script.}
;got higher than giraffe tits again. Came through and prettied the logging, and made it more consistent, with what I'm trying to achieve, with the main script.
;Imported Properties from ESP

Float NPCVersionToSet = 8.0
Import OutfitShuffler
Import LL_FourPlay
Import Game
Import Utility
Import MCM
Import Math

Actor Property PlayerRef Auto Const

ActorValue Property OSMaintTime Auto
ActorValue Property OSBodyDone Auto
ActorValue Property OSMaintWait Auto
ActorValue Property OSNPCVersion Auto

Formlist Property FactionsToIgnore Auto
Formlist Property GoodOutfits Auto Const
Formlist Property NewOutfits Auto Const

Formlist Property OSActorRaces Auto
Formlist Property OSAllItems Auto
Formlist Property WeaponsList Auto
FormList Property XXSafeItems Auto
FormList Property XYSafeItems Auto

Formlist Property XXAccessory Auto
Formlist Property XXArmAddon Auto
Formlist Property XXBack Auto
Formlist Property XXBackpack Auto
Formlist Property XXBeard Auto
Formlist Property XXBelt Auto
Formlist Property XXBottom Auto
Formlist Property XXEarrings Auto
Formlist Property XXFront Auto
Formlist Property XXFullBody Auto
Formlist Property XXGlasses Auto
Formlist Property XXHair Auto
Formlist Property XXJacket Auto
Formlist Property XXLeftArmArmor Auto
Formlist Property XXLeftLegArmor Auto
Formlist Property XXLegs Auto
Formlist Property XXLongHair Auto
Formlist Property XXMouth Auto
Formlist Property XXNeck Auto
Formlist Property XXRightArmArmor Auto
Formlist Property XXRightLegArmor Auto
Formlist Property XXRing Auto
Formlist Property XXShoes Auto
Formlist Property XXShoulder Auto
Formlist Property XXTop Auto
Formlist Property XXTorsoArmor Auto

Formlist Property XYAccessory Auto
Formlist Property XYArmAddon Auto
Formlist Property XYBack Auto
Formlist Property XYBackpack Auto
Formlist Property XYBeard Auto
Formlist Property XYBelt Auto
Formlist Property XYBottom Auto
Formlist Property XYEarrings Auto
Formlist Property XYFront Auto
Formlist Property XYFullBody Auto
Formlist Property XYGlasses Auto
Formlist Property XYHair Auto
Formlist Property XYJacket Auto
Formlist Property XYLeftArmArmor Auto
Formlist Property XYLeftLegArmor Auto
Formlist Property XYLegs Auto
Formlist Property XYLongHair Auto
Formlist Property XYMouth Auto
Formlist Property XYNeck Auto
Formlist Property XYRightArmArmor Auto
Formlist Property XYRightLegArmor Auto
Formlist Property XYRing Auto
Formlist Property XYShoes Auto
Formlist Property XYShoulder Auto
Formlist Property XYTop Auto
Formlist Property XYTorsoArmor Auto

GlobalVariable Property OSSuspend Auto
GlobalVariable Property OSUseAAF Auto
GlobalVariable Property OSUseDD Auto
GlobalVariable Property OSVersion auto

MiscObject Property OSDontChangeItem Auto Const
MiscObject Property OSAlwaysChangeItem Auto Const
MiscObject Property OSDontBodyGenItem Auto Const
MiscObject Property OSAlwaysBodyGenItem Auto Const
MiscObject Property OSDontScaleItem Auto Const
MiscObject Property OSAlwaysScaleItem Auto Const

Outfit Property EmptyOutfit Auto Const

Quest Property OutfitShufflerQuest Auto Const
Quest Property pMQ101 Auto Const mandatory

Spell Property ContainersSpell Auto Const
Spell Property Maintainer Auto Const

;Local variables
Actor NPC

int MultCounter
int RaceCounter
string OSLogName = "OutfitShuffler"
String MasterINI = "OutfitShuffler.ini"
String INIpath = "OutfitShuffler\\" 
string OSData = "OutfitShuffler\\OSNPCData.ini"
String DebugHead="[Maintainer]"
String DebugHeadShort="[OSm]"

;Imported Variables
FormList AAF_ActiveActors
ActorBase AAF_Doppelganger
Outfit AAF_EmptyOutfit
Keyword AAFBusyKeyword
Keyword DDRendered
Keyword DDInventory
Spell EBCC_DirtTier01
Spell EBCC_DirtTier02
Spell EBCC_DirtTier03

;Arrays
ObjectReference[] kActorArray

int tid=5309
bool localhold
String DebugLogString

Event OnInit()
	Self.StartTimer(1.0,tID)
	localhold=false
EndEvent

Event OnTimer(int TimerID)
	If NPC.GetValue(OSNPCVersion)!=OSVersion.GetValue()
		if NPC.HasSpell(Maintainer)
			NPC.RemoveSpell(Maintainer)
		endif
	endif
	If TimerID==tID
		While LocalHold
			wait(1.0)
		endwhile
		if ((GetModSettingBool("OutfitShuffler", "bIsEnabled:General") as Bool==0) || NPC == PlayerRef || NPC.IsDead() || NPC.IsChild() || PowerArmorCheck(NPC) || NPC.IsDeleted() ||  NPC.IsDisabled()) && PlayerRef.GetDistance(NPC)<(GetModSettingFloat("OutfitShuffler", "fScanRange:General") as Float) || NPC.GetLeveledActorBase()==AAF_Doppelganger
			dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" Removing Maintenance Spell")
			NPC.RemoveSpell(Maintainer)
			return
		endif
		localhold=true
		NPC.RemoveInventoryEventFilter(None)

		Debug.OpenUserLog(OSLogName)

		if NPC.GetValue(OSMaintWait)==3
;			ScriptObject OSMain = GetFormFromFile(0x800,"OutfitShuffler.esl").CastAs("OutfitShufflerQuest")
			Var[] Temp=New Var[1]
			Temp[0]=NPC as Actor
;			OSMain.CallGlobalFunction("BuildOutfitFromParts",Temp)
			CallGlobalFunction("OutfitShuffler", "BuildOutfitFromParts", Temp)
		endif

		Bool LoadNotShuffle
		Var[] TempVal = New Var[0]
		TempVal = GetCustomConfigOptions(OSData, IntToHexString(NPC.GetFormID()))
		dlog(1,"OnTimer()"+NPC+NPC.GetLeveledActorBase().GetName()+" Checking for NPC Data. GetCustomConfigOptions Item Count="+TempVal.Length)
		if TempVal!=None
			Var[] TempVal2=New Var[0]
			TempVal2=VarToVarArray(TempVal[0])
			if Tempval2.Length>1
				dlog(1,"OnTimer()"+NPC+NPC.GetLeveledActorBase().GetName()+" Loading NPC Data")
				LoadNotShuffle=True
				LoadNPC(NPC)
			endif
		endif

		If !LoadNotShuffle
			If NPC.GetValue(OSMaintWait)==1 && (NPC.GetValue(OSMaintTime)+(GetModSettingInt("OutfitShuffler", "iLongMult:General") as Int)*(GetModSettingFloat("OutfitShuffler", "fShortTime:General") as Float)*0.00069)>GetCurrentGameTime()
				NPC.SetValue(OSMaintWait,0)
			else
				While !NPC.Is3DLoaded() || NPC.GetValue(OSMaintWait)>0 || OSSuspend.GetValueInt() == 1 || NPC.GetFurnitureReference()!=None || !CheckAAFSafe(NPC)
					Wait(1.0)
				endwhile
				dlog(1,"OnTimer()"+NPC+NPC.GetLeveledActorBase().GetName()+" is being maintained")
				EveryDayImShufflin()
			endif
		endif
		NPC.AddInventoryEventFilter(None)
		NPC.SetValue(OSMaintTime, GetCurrentGameTime())
		NPC.SetValue(OSMaintWait,0)
		dlog(1,DebugLogString)
		localhold=false
		NPC.StartTimer(5.0,tID)
	endif
endevent

Event OnEffectStart(Actor akTarget, Actor akCaster)
	NPC=akTarget
	if NPC
		NPC.SetValue(OSNPCVersion, NPCVersionToSet)
		NPC.StartTimer(5.0,tID)
	endif
endevent

Event OnItemUnequipped(Form akBaseObject, ObjectReference akReference)
	if (akBaseObject!=None||akReference!=None)&&NPC!=None
		if NPC.GetValue(OSMaintWait)==0 && CheckAAFSafe(NPC) && !PowerArmorCheck(NPC) && OSSuspend.GetValueInt()==0
			NPC.SetValue(OSMaintWait,1)
			CleanCaptive(NPC)
			NPC.RemoveInventoryEventFilter(None)
			Form akItem = akBaseObject
			If (akItem as Armor)
				If akItem.getformid()<0x07000000 && !(GetModSettingBool("OutfitShuffler", "bAllowDLC:General") as Bool)
					if OSAllItems.HasForm(akItem as ObjectReference) || SafeForm(NPC).HasForm(akItem as ObjectReference) || IsDeviousDevice(akItem)
						NPC.equipitem(akItem)
						return
					else
						NPC.removeitem(akItem,-1)
						return
					endif
				endif
				If akItem.getformid()>0x06ffffff || (akItem.getformid()<0x07000000 && (GetModSettingBool("OutfitShuffler", "bAllowDLC:General") as Bool)) || OSAllItems.HasForm(akItem as ObjectReference) || SafeForm(NPC).HasForm(akItem as ObjectReference)
					NPC.equipitem(akItem)
					return
				endif
			endif
			if SafeForm(NPC).HasForm(akItem as ObjectReference)
				NPC.EquipItem(akItem)
				return
			endif
			if IsDeviousDevice(akItem)
				NPC.EquipItem(akItem)
				return
			endif
			NPC.SetValue(OSMaintWait,0)
			NPC.AddInventoryEventFilter(None)
		endif
	endif
endEvent

Function EveryDayImShufflin()
	Bool WearingDD
	NPC.SetValue(OSMaintWait,1)
	if NPC.Is3DLoaded() && !NPC.IsDead() && !NPC.IsDeleted() && !NPC.IsDisabled() && !PowerArmorCheck(NPC) && CheckAAFSafe(NPC)
		DebugLogString="EveryDayImShufflin() "+NPC+""+NPC.GetLeveledActorBase().GetName()+" Checking for Maintenance."
		NPC.SetOutfit(EmptyOutfit)
		Form[] InvItems = NPC.GetInventoryItems()
		Int i=0
		While (i < InvItems.Length)
			Form akItem = InvItems[i]
			If (akItem as Armor)
				If akItem.getformid()<0x07000000 && !(GetModSettingBool("OutfitShuffler", "bAllowDLC:General") as Bool) && (StringFind(akitem.GetName(), "Skin") != -1)
					if !(OSAllItems.HasForm(akItem as ObjectReference) || SafeForm(NPC).HasForm(akItem as ObjectReference) || IsDeviousDevice(akItem))
						NPC.removeitem(akItem,-1)
					endif
				endif
			endif
		i += 1
		EndWhile

		InvItems = NPC.GetInventoryItems()
		i=0
		While (i < InvItems.Length)
		Form akItem = InvItems[i]
			If (akItem as Armor)
				If !IsDeviousDevice(akItem) ||!SafeForm(NPC).HasForm(akItem as ObjectReference)
					NPC.equipitem(akItem)
				endif
			endif
		i += 1
		endwhile

		InvItems = NPC.GetInventoryItems()
		i=0
		While (i < InvItems.Length)
			Form akItem = InvItems[i]
			if SafeForm(NPC).HasForm(akItem as ObjectReference)
				NPC.EquipItem(akItem)
				endif
		i += 1
		endwhile

		InvItems = NPC.GetInventoryItems()
		i=0
		While (i < InvItems.Length)
			Form akItem = InvItems[i]
			If (akItem as Armor)
				if IsDeviousDevice(akItem)
					if NPC.IsEquipped(akItem)
						WearingDD=True
					else
						WearingDD=True
						npc.equipitem(akItem)
					endif
				endif
			endif
		i += 1
		endwhile
		
		if WearingDD && NPC.GetItemCount(OSDontChangeItem)==0
			NPC.RemoveItem(OSAlwaysChangeItem, -1)
			NPC.AddItem(OSDontChangeItem,1,true)
		endif
		Wait(0.1)

		i=0
		InvItems = NPC.GetInventoryItems()
		While (i < InvItems.Length)
			Form akItem = InvItems[i]
			If (akItem as Armor)
				if !NPC.IsEquipped(akItem)
					NPC.RemoveItem(akItem, -1)
				endif
			endif
		i += 1
		EndWhile
	
		Wait(0.1)
	
		if NPC.GetItemCount(OSDontChangeItem)==0 && CountNPCArmor(NPC)<1 && (GetModSettingBool("OutfitShuffler", "bNoNudes:General") as Bool)
			NPC.RemoveItem(OSDontChangeItem, -1)
			NPC.SetValue(OSMaintTime, 0)
			return
		endif

		if (GetModSettingBool("OutfitShuffler", "bOneShot:General") as Bool==1) && NPC.GetItemCount(OSDontChangeItem)<1 && NPC.GetItemCount(OSAlwaysChangeItem)<1
			NPC.AddItem(OSDontChangeItem,1)
		endif

	endif

	SaveNPC(NPC)
	NPC.SetValue(OSMaintTime, GetCurrentGameTime())
	NPC.SetValue(OSMaintWait,0)
	NPC.AddInventoryEventFilter(None)
endfunction

Function BodyGenandScale(Actor NPCv)
;Do NewScale
	If NPCv.GetItemCount(OSAlwaysScaleItem)>0 || ((GetModSettingBool("OutfitShuffler", "bNPCUseScaling:General") as Bool==True) && (NPCv.GetValue(OSBodyDone)!=1))
		float NPCNewScale = 1.0
		if (GetModSettingFloat("OutfitShuffler", "fNPCMinScale:General") as Float) >= (GetModSettingFloat("OutfitShuffler", "fNPCMaxScale:General") as Float)
			NPCNewScale=(GetModSettingFloat("OutfitShuffler", "fNPCMinScale:General") as Float)
		else
			NPCNewScale = RandomFloat((GetModSettingFloat("OutfitShuffler", "fNPCMinScale:General") as Float), (GetModSettingFloat("OutfitShuffler", "fNPCMaxScale:General") as Float))
		endif
		NPCv.SetScale(NPCNewScale)
	endif
;Do BodyGen
	If (NPCv.GetItemCount(OSAlwaysBodyGenItem)>0) || (((GetModSettingBool("OutfitShuffler", "bRandomBodyGen:General") as Bool==True) && (NPCv.GetValue(OSBodyDone)!=1)))
		BodyGen.RegenerateMorphs(NPCv, true)
		if (GetModSettingBool("OutfitShuffler", "bBodygenOneShot:General") as Bool==True) && (NPCv.GetItemCount(OSAlwaysBodyGenItem)==0)
			NPCv.SetValue(OSBodyDone,1)
		endif
	endif
endfunction

Function LoadNPC(Actor NPCv)

;	Var[] TempVal = New Var[0]
;	TempVal = GetCustomConfigOptions(OSData, IntToHexString(NPC.GetFormID()))
;	Var[] TempVal2=New Var[0]
;	TempVal2=VarToVarArray(TempVal[0])
;	if Tempval2.Length>0
;		LoadNPC(NPC)
;	else
;Var[] Function GetCustomConfigOptions(string fileName, string section) native global
	NPCv.SetValue(OSMaintWait,1)
	Var[] TempVal = New Var[0]
	Var[] NPCvKey = New Var[0]
	Var[] NPCvValue = New Var[0]
	TempVal = GetCustomConfigOptions(OSData, IntToHexString(NPCv.GetFormID()))
	if TempVal!=None || TempVal.Length>0
		NPCvKey = VarToVarArray(TempVal[0])
		NPCvValue = VarToVarArray(TempVal[1])
	else
		NPCvKey.Add(0)
		NPCvValue.Add(0)
	endif

	If NPCvKey.Length>0
	;	UnequipItems(NPCv)
;Set outfit, weapon, and Misc items.
		Int i=0
		NPCv.SetOutfit(EmptyOutfit)
		While i<NPCvKey.Length
			if NPCvKey[i] as String=="Name"
				If NPCv.GetLeveledActorBase().GetName()!=NPCvValue[i] as String
					dlog(1,"LoadNPC() "+NPCv+NPCv.GetLeveledActorBase().GetName()+" Setting Name="+NPCvValue[i] as String)
					NPCv.GetLeveledActorBase().SetName(NPCvValue[i] as String)
				endif
				i+=1
			endif
			Form TempForm=GetFormFromFile(HexStringToInt(NPCvKey[i]),NPCvValue[i] as String)
			if TempForm!=None
				if !NPCv.IsEquipped(TempForm) &&(XYSafeItems.HasForm(TempForm) || XXSafeItems.HasForm(TempForm)||OSAllItems.HasForm(TempForm)||WeaponsList.HasForm(TempForm)||IsDeviousDevice(TempForm))
					dlog(1,"LoadNPC() "+NPCv+NPCv.GetLeveledActorBase().GetName()+" Equipping "+TempForm+TempForm.GetName())
					NPCv.EquipItem(TempForm)
				endif
			endif
			i+=1
		endwhile
	endif
	NPCv.SetValue(OSMaintTime,GetCurrentGameTime())
	NPCv.SetValue(OSMaintWait,0)
endfunction

Function UnEquipItems(Actor NPCv)
	if OSSuspend.GetValueInt()==1
		While OSSuspend.GetValueInt()==1
			wait(0.1)
		endwhile
	else
		Form[] InvItems = NPCv.GetInventoryItems()
		int i=0
;		DebugLogString+=NPCv+NPCv.GetLeveledActorBase().GetName()+"\n In UnEquipItems()")
		While (i < InvItems.Length)
		Form akItem = InvItems[i]
			if akItem!=None
				If IsDeviousDevice(akItem) || SafeForm(NPC).HasForm(akItem)
	;				DebugLogString+=NPCv+NPCv.GetLeveledActorBase().GetName()+" NOT REMOVING "+akItem+akItem.GetName()+" UseDD="+OSUseDD.GetValueInt()+" DDRendered="+akItem.HasKeyword(DDRendered)+" DDInventory="+akItem.HasKeyword(DDInventory))
					if !NPCv.IsEquipped(akItem)
						NPCv.EquipItem(akItem)
					endif
				elseif (akItem as Armor)
					NPCv.removeitem(akItem, -1)
				elseif WeaponsList.HasForm(akItem)
					NPCv.removeitem(akItem, -1)
				endif
			endif
		i += 1
		EndWhile
		If NPCv.HasSpell(EBCC_DirtTier01)
			NPCv.RemoveSpell(EBCC_DirtTier01)
		endif
		If NPCv.HasSpell(EBCC_DirtTier02)
			NPCv.RemoveSpell(EBCC_DirtTier02)
		endif
		If NPCv.HasSpell(EBCC_DirtTier03)
			NPCv.RemoveSpell(EBCC_DirtTier03)
		endif
	endif
endfunction

Function dLog(int dLogLevel,string LogMe)

	If GetModSettingInt("OutfitShuffler", "iLogLevel:General") as Int >0

		Debug.OpenUserLog(OSLogName)
	
		If GetModSettingInt("OutfitShuffler", "iLogLevel:General") as int > 0
			debug.TraceUser(OSLogName, "[Maintainer]"+LogMe,1)
		endif

		If dLogLevel > 1
			debug.Notification("[OSm] "+LogMe)
		endif

		If GetModSettingInt("OutfitShuffler", "iLogLevel:General") as int == 2 || dLogLevel == 2
			PrintConsole("[OSm] "+LogMe)
		endif
	
	endif
	DebugLogString=""
endFunction

Function SaveNPC(Actor NPCv)
	int i=0
	Var[] NPCvKey = New Var[0]
	Var[] NPCvValue = New Var[0]
	i=0
	NPCvKey.Add("Name")
	NPCvValue.Add(NPCv.GetLeveledActorBase().GetName())
	Form[] InvItems = NPCv.GetInventoryItems()
	While (i < InvItems.Length)
		Form akItem = InvItems[i]
			if akItem==Game.GetFormFromFile(akitem.GetFormID(), "OutfitShuffler.esl")
				NPCvKey.Add(IntToHexString(akItem.GetFormID()))
				NPCvValue.Add("OutfitShuffler.esl")
			endif
		i += 1
	EndWhile		
	i=0
	InvItems = NPCv.GetInventoryItems()
	While (i < InvItems.Length)
		Form akItem = InvItems[i]
			If ((akItem as Armor)||(akItem as Weapon)) && !akitem.GetName()==""
				String[] PluginData = GetFileFromForm(akItem)
				NPCvKey.Add(PluginData[1])
				NPCvValue.Add(PluginData[0])
			endif
		i += 1
	EndWhile
	bool retval=ResetCustomConfigOptions(OSData, IntToHexString(NPCv.GetFormID()), NPCvKey as String[], NPCvValue as String[])
	DebugLogString+="\nSaveNPC() "+NPCv+NPCv.GetLeveledActorBase().GetName()+" SAVED!"
	dlog(1,DebugLogString)
endfunction

int Function getLow12Bits(Int i)
    return RightShift(LeftShift(i,20),20)
EndFunction

int Function getLow24Bits(Int i)
    return RightShift(LeftShift(i,8),8)
EndFunction

String[] Function GetFileFromForm(Form InputForm)
	OutfitShuffler OS
	OS=GetFormFromFile(0x800, "outfitshuffler.esl") as OutfitShuffler
	String[] PluginsName
	String[] LightPluginsName
	PluginsName = OS.PluginsName as String[]
	LightPluginsName = OS.LightPluginsName as String[]
	Int i
	Int Working = RightShift(LeftShift(InputForm.GetFormID(),8),8)
	If PluginsName.length<1
		String[] RetVal = New String[2]
		retval[0]="NoPluginsName"
		retval[1]=IntToHexString(InputForm.GetFormID())
		return retval
	endif
	While i<PluginsName.length
		Form FoundForm=Game.GetFormFromFile(Working, PluginsName[i])
		If FoundForm!=None
			If FoundForm==InputForm
				String[] RetVal = New String[2]
				retval[0]=PluginsName[i]
				retval[1]=IntToHexString(GetLow24Bits(InputForm.GetFormID()))
				;dlog(1,"GetFileFromForm() "+InputForm+InputForm.GetName()+" Plugin="+retval[0]+" Item="+retval[1])
				return retval
			endif
		endif
		i+=1
	Endwhile
	i=0
	while LightPluginsName.length>0 && i<LightPluginsName.length
		Form FoundForm=Game.GetFormFromFile(Working, LightPluginsName[i])
		If FoundForm!=None
			If FoundForm==InputForm
				String[] RetVal = New String[2]
				retval[0]=LightPluginsName[i]
				retval[1]=IntToHexString(getLow12Bits(InputForm.GetFormID()))
				;dlog(1,"GetFileFromForm() "+InputForm+InputForm.GetName()+" Plugin="+retval[0]+" Item="+retval[1])
				return retval
			endif
		endif
		i+=1
	endwhile
	String[] RetVal = New String[2]
	retval[0]="ERROR"
	retval[1]=IntToHexString(InputForm.GetFormID())
	;dlog(1,"GetFileFromForm() "+InputForm+InputForm.GetName()+" Plugin="+retval[0]+" Item="+retval[1])
	return retval
endfunction