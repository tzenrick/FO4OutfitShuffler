Scriptname OutfitShuffler extends Quest
;=================================================================================================================
;Imported Properties from ESP
Quest Property pMQ101 Auto Const mandatory
Outfit Property UnboundOutfit Auto Const
Outfit Property UnBoundOutfitNOWEAP Auto Const
Outfit Property W1 Auto Const
Outfit Property W2 Auto Const
Outfit Property W3 Auto Const
Outfit Property W4 Auto Const
Outfit Property W5 Auto Const
Outfit Property W6 Auto Const
Keyword Property actorTypeHuman Auto Const
Keyword Property actorTypeGhoul Auto Const
Keyword Property AAFActorBusy Auto Const
float Property ShortTime Auto
int Property LongMult Auto
float Property ScanRange Auto
bool Property ChangeFollowers Auto
bool Property ChangeFollowersOnShort Auto
float Property WaitTime Auto
bool Property Notifications Auto
bool Property LogNotifications Auto

;=================================================================================================================
;Initialize a few variables
int ShortTimerID = 888
int MultCounter = 0
int MQ101EarlyStage = 30
int ActorsToDo = 0
int ActorsDone = 0
String Section = ""
Bool modEnabled = True
Actor[] playerFollowers
ActorBase DoppelGanger
;=================================================================================================================
;Setup logging and start Short and Long timers
Event OnInit()
	Section="OnInit"
	debug.openuserlog("OutfitShuffler")
	GetMCMSettings()
	dNotif(Section+": Outfit Shuffler Init: "+UnboundOutfit+UnboundOutfitNOWEAP+W1+W2+W3+W4+W5+W6)
	DoppelGanger = Game.GetFormFromFile(0x72e2,"aaf.esm") as ActorBase
	dNotif(Section+": DoppelGanger is "+DoppelGanger)
	GetMCMSettings()
	starttimer(ShortTime, ShortTimerID)
EndEvent
;=================================================================================================================
;Catch timer events
Event OnTimer(int aiTimerID)
	Section="Timer"
	If pMQ101.IsRunning() && pMQ101.GetStage() < MQ101EarlyStage
		dNotif(Section+": Still early in MQ101...")
		starttimer(ShortTime, ShortTimerID)
	else
		if aiTimerID == ShortTimerID
			GetMCMSettings()
			if modEnabled
				TimerTrap()
			endif
		endif
	endif
EndEvent

Function TimerTrap()
	playerFollowers = Game.GetPlayerFollowers( )
		if MultCounter > LongMult-1
			canceltimer(ShortTimerID)
			dNotif(Section+": LongTimer")
			ForceNPCs()
			ForceGhouls()	
			starttimer(ShortTime, ShortTimerID)
			MultCounter = 0
		else
			canceltimer(ShortTimerID)
			dNotif(Section+": ShortTimer")
			ScanNPCs()
			ScanGhouls()	
			starttimer(ShortTime, ShortTimerID)
			MultCounter += 1
		endif
endFunction
;=================================================================================================================
function ScanNPCs()
	Section="ScanNPCs"
	int i = 0
;Nearby humans
	ObjectReference[] kActorArray = Game.GetPlayer().FindAllReferencesWithKeyword(actorTypeHuman, ScanRange)
	ActorsToDo = kActorArray.Length
	ActorsDone = 0
	dNotif(Section+": MultCounter="+MultCounter+"/"+LongMult+" ToDo:"+ActorsToDo)
	while i <ActorsToDo
		Actor NPC = kActorArray[i] as Actor
		if NPC != Game.GetPlayer()
			If !NPC.IsChild()
				If NPC.GetLeveledActorBase().GetSex() == 1
					If !NPC.IsTalking() ==True
						dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+NPC+NPC.GetLeveledActorBase().Getoutfit())
						int CorrectOutfit = 0
						if (NPC.GetLeveledActorBase().GetOutfit() == UnboundOutfitNOWEAP)
							CorrectOutfit = 1
						endif
						if (NPC.GetLeveledActorBase().GetOutfit() == UnboundOutfit)
							CorrectOutfit = 1
						endif
						if (NPC.GetLeveledActorBase().GetOutfit() == W1)
							CorrectOutfit = 1
						endif
						if (NPC.GetLeveledActorBase().GetOutfit() == W2)
							CorrectOutfit = 1
						endif
						if (NPC.GetLeveledActorBase().GetOutfit() == W3)
							CorrectOutfit = 1
						endif
						if (NPC.GetLeveledActorBase().GetOutfit() == W4)
							CorrectOutfit = 1
						endif
						if (NPC.GetLeveledActorBase().GetOutfit() == W5)
							CorrectOutfit = 1
						endif
						if (NPC.GetLeveledActorBase().GetOutfit() == W6)
							CorrectOutfit = 1
						endif
						If CorrectOutfit == 0
							If CheckIfFollower(NPC)
								if NPC.GetLeveledActorBase() == DoppelGanger
									dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+NPC.GetLeveledActorBase()+" is a "+DoppelGanger)
								else
									dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is ready for an outfit.")
									SetSettlerOutfit(NPC, UnboundOutfit)
								endif
							else
							dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is a follower we don't change.")
							endif
						else
							dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is already in an outfit.")
						endif
					else
						dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is talking.")
					endif
				else
					dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is not a female.")
				endif
			else
				dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is a child.")
			endIf
		else
			dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is the player.")
		endif
		i += 1
	endwhile
	dNotif(Section+": Changed "+ActorsDone+"/"+ActorsToDo)
endFunction
;=================================================================================================================
function ForceNPCs()
;===================================MAGIC NUMBER ALERT!!! If the Int Property LongMult = 1111.0, It will trigger rarely,
;and skip repeated clothing changes. Once an outfit is assigned the first time, it won't be changed again.
	Section="ForceNPCs"
	If LongMult != 1111
		int i = 0
		ObjectReference[] kActorArray = Game.GetPlayer().FindAllReferencesWithKeyword(actorTypeHuman, ScanRange)
		ActorsToDo = kActorArray.Length
		ActorsDone = 0
		dNotif(Section+": MultCounter="+MultCounter+"/"+LongMult+" ToDo:"+ActorsToDo)
		while i <ActorsToDo
			Actor NPC = kActorArray[i] as Actor
			if NPC != Game.GetPlayer()
				If !NPC.IsChild()
					If NPC.GetLeveledActorBase().GetSex() == 1
						If !NPC.IsTalking() ==True
							dNotif(Section+" :"+NPC.GetLeveledActorBase().GetName()+NPC+NPC.GetLeveledActorBase().Getoutfit())
							if NPC.GetLeveledActorBase().GetOutfit() == (UnBoundOutfitNOWEAP||UnboundOutfit)
								If CheckIfFollower(NPC)
								if NPC.GetLeveledActorBase() == DoppelGanger
									dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+NPC.GetLeveledActorBase()+" is a "+DoppelGanger)
								else
									dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is ready for an outfit.")
									SetSettlerOutfit(NPC, UnboundOutfit)
								endif
							else
							dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is a follower we don't change.")
							endif
							else
								dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is a follower we don't change.")
							endif
						else
								dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is talking.")
						endif
					else
						dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is not a female.")
					endif
				else
					dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is a child.")
				endIf
			else
				dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is the player.")
			endif
			i += 1
		endwhile
		dNotif(Section+": Changed "+ActorsDone+"/"+ActorsToDo)
	endif
endFunction
;=================================================================================================================
;This section is called from the Short Timer
function scanGhouls()
	Section="ScanGhouls"
	int i = 0
;Nearby ghouls
	ObjectReference[] kActorArray = Game.GetPlayer().FindAllReferencesWithKeyword(actorTypeGhoul, ScanRange)
	ActorsToDo = kActorArray.Length
	ActorsDone = 0
	dNotif(Section+": MultCounter="+MultCounter+"/"+LongMult+" ToDo:"+ActorsToDo)
	while i <ActorsToDo
		Actor NPC = kActorArray[i] as Actor
		if NPC != Game.GetPlayer()
			If !NPC.IsChild()
				If NPC.GetLeveledActorBase().GetSex() == 1
					If !NPC.IsTalking() ==True
						dNotif(NPC.GetLeveledActorBase().GetName()+NPC+NPC.GetLeveledActorBase().Getoutfit())
						int CorrectOutfit = 0
						if (NPC.GetLeveledActorBase().GetOutfit() == UnboundOutfitNOWEAP)
							CorrectOutfit = 1
						endif
						if (NPC.GetLeveledActorBase().GetOutfit() == UnboundOutfit)
							CorrectOutfit = 1
						endif
						if (NPC.GetLeveledActorBase().GetOutfit() == W1)
							CorrectOutfit = 1
						endif
						if (NPC.GetLeveledActorBase().GetOutfit() == W2)
							CorrectOutfit = 1
						endif
						if (NPC.GetLeveledActorBase().GetOutfit() == W3)
							CorrectOutfit = 1
						endif
						if (NPC.GetLeveledActorBase().GetOutfit() == W4)
							CorrectOutfit = 1
						endif
						if (NPC.GetLeveledActorBase().GetOutfit() == W5)
							CorrectOutfit = 1
						endif
						if (NPC.GetLeveledActorBase().GetOutfit() == W6)
							CorrectOutfit = 1
						endif
						If CorrectOutfit == 0
							If CheckIfFollower(NPC)
								if NPC.GetLeveledActorBase() == DoppelGanger
									dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+NPC.GetLeveledActorBase()+" is a "+DoppelGanger)
								else
									dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is ready for an outfit.")
									SetSettlerOutfit(NPC, UnboundOutfit)
								endif
							else
							dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is a follower we don't change.")
							endif
						else
							dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is already in an outfit.")
							Return
						endif
					else
						dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is talking.")
						Return
					endif
				else
					dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is not a female.")
					Return
				endif
			else
				dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is a child.")
				Return
			endIf
		else
			dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is the player.")
			Return
		endif
		i += 1
	endwhile
	dNotif(Section+": Changed "+ActorsDone+"/"+ActorsToDo)
endFunction
;=================================================================================================================
;This section is called from the Long Timer
function ForceGhouls()
;===================================MAGIC NUMBER ALERT!!! If the Int Property LongMult = 1111.0, It will trigger rarely,
;and skip repeated clothing changes. Once an outfit is assigned the first time, it won't be changed again.
	Section="ForceGhouls"
	If LongMult != 1111
		int i = 0
		ObjectReference[] kActorArray = Game.GetPlayer().FindAllReferencesWithKeyword(actorTypeGhoul, ScanRange)
		ActorsToDo = kActorArray.Length
		ActorsDone = 0
		dNotif(Section+": MultCounter="+MultCounter+"/"+LongMult+" ToDo:"+ActorsToDo)
		while i <ActorsToDo
			Actor NPC = kActorArray[i] as Actor
			if NPC != Game.GetPlayer()
				If !NPC.IsChild()
					If NPC.GetLeveledActorBase().GetSex() == 1
						If !NPC.IsTalking() ==True
							dNotif(Section+NPC.GetLeveledActorBase().GetName()+NPC+NPC.GetLeveledActorBase().Getoutfit())
							If CheckIfFollower(NPC)
								if NPC.GetLeveledActorBase() == DoppelGanger
									dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+NPC.GetLeveledActorBase()+" is a "+DoppelGanger)
								else
									dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is ready for an outfit.")
									SetSettlerOutfit(NPC, UnboundOutfit)
								endif
							else
							dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is a follower we don't change.")
							endif
						else
								dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is talking.")
								Return
						endif
					else
						dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is not a female.")
						Return
					endif
				else
					dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is a child.")
					Return
				endIf
			else
				dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is the player.")
				Return
			endif
			i += 1
		endwhile
		dNotif(Section+": Changed "+ActorsDone+"/"+ActorsToDo)
		Return
	endif
endFunction
;=================================================================================================================
;CheckIfFollower(NPC) returns True for non-followers. Returns Property ChangeFollowers/ChangeFollowersOnShort for followers. 
Bool Function CheckIfFollower(Actor CheckNPC)
String SectionReturn = Section
Section = Section+":CheckIfFollower: "
int index = 0
while (index < playerFollowers.Length)
	If CheckNPC == playerFollowers[index]
		if MultCounter > LongMult-1
			If ChangeFollowersOnShort
				dNotif(Section+":"+CheckNPC.GetLeveledActorBase().GetName()+" is a follower.")
				Section = SectionReturn
				return ChangeFollowersOnShort
			else
				dNotif(Section+":"+CheckNPC.GetLeveledActorBase().GetName()+" is a follower, that's not getting changed.")
				Section = SectionReturn
				return ChangeFollowersOnShort
			endif
		else
			If ChangeFollowers
				dNotif(Section+":"+CheckNPC.GetLeveledActorBase().GetName()+" is a follower.")
				Section = SectionReturn
				return ChangeFollowers
			else
				dNotif(Section+":"+CheckNPC.GetLeveledActorBase().GetName()+" is a follower, that's not getting changed.")
				Section = SectionReturn
				return ChangeFollowers
			endif
		endif
	endIf
	index += 1
endWhile
dNotif(Section+":"+CheckNPC.GetLeveledActorBase().GetName()+" is NOT a follower.")
Section = SectionReturn
return True
endFunction
;=================================================================================================================
Function SetSettlerOutfit(Actor NPC, Outfit OTFTToSet)
String SectionReturn = Section
Section = Section+":SetSettlerOutfit: "
	float X=NPC.getpositionx()
	float Y=NPC.getpositiony()
	float Z=NPC.getpositionz()
	float ROT=NPC.getAngleZ()
	If !NPC.IsDead()
		If !Npc.IsDeleted()
			if !NPC.HasKeyword(AAFActorBusy)
				If NPC.IsEnabled()
					If !NPC.IsInScene()
						if Game.GetPlayer().GetDistance(NPC) < ScanRange
							ObjectReference furnitureRef = NPC.GetFurnitureReference()
							if furnitureRef
								dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is being changed. ("+ furnitureRef +")")
								NPC.SetOutfit(OTFTToSet)
								;NPCSetOutfit(NPC, OTFTToSet)
								;NPC.SnapIntoInteraction(furnitureRef)
							else
								dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is being changed.(Non-Furniture)")
								NPCSetOutfit(NPC, OTFTToSet)
								NPC.setposition(X,Y,Z)
								NPC.setangle(0,0,ROT)
							endif
							ActorsDone += 1
							Section = SectionReturn
							Return
						else
							dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is too far away, now.")
							Section = SectionReturn
							Return
						endif
					else
						dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is busy.")
						Section = SectionReturn
						Return
					endIf
				else
					dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is disabled.")
					Section = SectionReturn
					Return
				endif
			else
				dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is AAF Busy.")
				Section = SectionReturn
				Return
			endif	
		else
			dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is deleted.")
			Section = SectionReturn
			Return
		endif
	else
		dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is dead.")
		Section = SectionReturn
		Return
	endif
EndFunction
;=================================================================================================================
Function dNotif(String NotificationText)
if Notifications
	Debug.Notification(NotificationText)
endif
if LogNotifications
	debug.traceuser("OutfitShuffler",NotificationText)
endif
endfunction
;=================================================================================================================
Function NPCSetOutfit(Actor NPCtoSet, Outfit OutfitToSet)
String SectionReturn = Section
Section = Section+":NPCSetOutfit:"
NPCtoSet.GetLeveledActorBase().setoutfit(OutfitToSet,false)
NPCtoSet.setoutfit(OutfitToSet,false)
Utility.Wait(WaitTime)
NPCtoSet.Resurrect()
Utility.Wait(WaitTime)
dNotif(Section+":"+NPCtoSet.GetLeveledActorBase().GetName()+"::"+NPCtoSet+ " got an outfit "+OutfitToSet)
Section = SectionReturn
endfunction
;=================================================================================================================
Function GetMCMSettings()
	modEnabled = MCM.GetModSettingBool("OutfitShuffler", "bIsEnabled:General")
	ChangeFollowers = MCM.GetModSettingBool("OutfitShuffler", "bChangeFollowers:General")
	ChangeFollowersOnShort = MCM.GetModSettingBool("OutfitShuffler", "bChangeFollowersOnShort:General")
	Notifications = MCM.GetModSettingBool("OutfitShuffler", "bNotifications:General")
	LogNotifications = MCM.GetModSettingBool("OutfitShuffler", "bLogNotifications:General")
	ScanRange = MCM.GetModSettingFloat("OutfitShuffler", "fScanRange:General")
	WaitTime = MCM.GetModSettingFloat("OutfitShuffler", "fWaitTime:General")
	ShortTime = MCM.GetModSettingFloat("OutfitShuffler", "fShortTime:General")
	LongMult = MCM.GetModSettingInt("OutfitShuffler", "iLongMult:General")
endfunction