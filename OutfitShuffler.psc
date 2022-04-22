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
float Property ShortTime Auto Const
int Property LongMult Auto Const
float Property ScanRange Auto Const
bool Property ChangeFollowers Auto Const
bool Property ChangeFollowersOnShort Auto Const
float Property WaitTime Auto Const
bool Property Logging Auto Const
bool Property Notifications Auto Const
bool Property LogNotifications Auto Const

;=================================================================================================================
;Initialize a few variables
int ShortTimerID = 888
int MultCounter = 0
int MQ101EarlyStage = 30
int ActorsToDo = 0
int ActorsDone = 0
String Section=""
Actor[] playerFollowers
ActorBase DoppelGanger
;=================================================================================================================
;Setup logging and start Short and Long timers
Event OnInit()
	debug.openuserlog("OutfitShuffler")
	dLog("Outfit Shuffler :"+UnboundOutfit+UnboundOutfitNOWEAP+W1+W2+W3+W4+W5+W6)
	DoppelGanger = Game.GetFormFromFile(0x72e2,"aaf.esm") as ActorBase
	dNotif("DoppelGanger is "+DoppelGanger)
	starttimer(ShortTime, ShortTimerID)
EndEvent
;=================================================================================================================
;Catch timer events
Event OnTimer(int aiTimerID)
	If pMQ101.IsRunning() && pMQ101.GetStage() < MQ101EarlyStage
		dLog("Still early in MQ101...")
		starttimer(ShortTime, ShortTimerID)
	else
		if aiTimerID == ShortTimerID
			playerFollowers = Game.GetPlayerFollowers( )
			if MultCounter > LongMult-1
				canceltimer(ShortTimerID)
				dLog("LongTimer")
				ForceNPCs()
				ForceGhouls()	
				starttimer(ShortTime, ShortTimerID)
				MultCounter = 0
			else
				canceltimer(ShortTimerID)
				dLog("ShortTimer")
				ScanNPCs()
				ScanGhouls()	
				starttimer(ShortTime, ShortTimerID)
				MultCounter += 1
			endif
		endif
	endif
;dLog("MQ101Stage:"+pMQ101.GetStage())
EndEvent
;=================================================================================================================
function ScanNPCs()
	Section="ScanNPCs"
	int i = 0
;Nearby humans
	ObjectReference[] kActorArray = Game.GetPlayer().FindAllReferencesWithKeyword(actorTypeHuman, ScanRange)
	ActorsToDo = kActorArray.Length
	ActorsDone = 0
	dNotif(Section+": MultCounter="+MultCounter+" ToDo:"+ActorsToDo)
	while i <ActorsToDo
		Actor NPC = kActorArray[i] as Actor
		if NPC != Game.GetPlayer()
			If CheckIfFollower(NPC)
				If !NPC.IsChild()
					If NPC.GetLeveledActorBase().GetSex() == 1
						If !NPC.IsTalking() ==True
							dLog(NPC.GetLeveledActorBase().GetName()+NPC+NPC.GetLeveledActorBase().Getoutfit())
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
								if NPC.GetLeveledActorBase() == DoppelGanger
									dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+NPC.GetLeveledActorBase()+" is a "+DoppelGanger)
								else
									dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is ready for an outfit.")
									SetSettlerOutfit(NPC, UnboundOutfit)
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
				dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is a follower we don't change.")
			endif
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
		dNotif(Section+": MultCounter="+MultCounter+" ToDo:"+ActorsToDo)
		while i <ActorsToDo
			Actor NPC = kActorArray[i] as Actor
			if NPC != Game.GetPlayer()
				If CheckIfFollower(NPC)
					If !NPC.IsChild()
						If NPC.GetLeveledActorBase().GetSex() == 1
							If !NPC.IsTalking() ==True
								dLog("LT: "+NPC.GetLeveledActorBase().GetName()+NPC+NPC.GetLeveledActorBase().Getoutfit())
								if NPC.GetLeveledActorBase().GetOutfit() == (UnBoundOutfitNOWEAP||UnboundOutfit)
										if NPC.GetLeveledActorBase() == DoppelGanger
											dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+NPC.GetLeveledActorBase()+" is a "+DoppelGanger)
										else
											dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is ready for an outfit.")
											SetSettlerOutfit(NPC, UnboundOutfit)
										endif
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
					dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is a follower we don't change.")
				endif
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
	dNotif(Section+": MultCounter="+MultCounter+" ToDo:"+ActorsToDo)
	while i <ActorsToDo
		Actor NPC = kActorArray[i] as Actor
		if NPC != Game.GetPlayer()
			If CheckIfFollower(NPC)
				If !NPC.IsChild()
					If NPC.GetLeveledActorBase().GetSex() == 1
						If !NPC.IsTalking() ==True
							dLog(NPC.GetLeveledActorBase().GetName()+NPC+NPC.GetLeveledActorBase().Getoutfit())
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
								if NPC.GetLeveledActorBase() == DoppelGanger
									dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+NPC.GetLeveledActorBase()+" is a "+DoppelGanger)
								else
									dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is ready for an outfit.")
									SetSettlerOutfit(NPC, UnboundOutfit)
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
				dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is a follower we don't change.")
			endif
		else
			dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is the player.")
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
		dNotif(Section+": MultCounter="+MultCounter+" ToDo:"+ActorsToDo)
		while i <ActorsToDo
			Actor NPC = kActorArray[i] as Actor
			if NPC != Game.GetPlayer()
				If CheckIfFollower(NPC)
					If !NPC.IsChild()
						If NPC.GetLeveledActorBase().GetSex() == 1
							If !NPC.IsTalking() ==True
								dLog("LT: "+NPC.GetLeveledActorBase().GetName()+NPC+NPC.GetLeveledActorBase().Getoutfit())
								if NPC.GetLeveledActorBase().GetOutfit() == (UnBoundOutfitNOWEAP||UnboundOutfit)
									if NPC.GetLeveledActorBase() == DoppelGanger
										dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+NPC.GetLeveledActorBase()+" is a "+DoppelGanger)
									else
										dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is ready for an outfit.")
										SetSettlerOutfit(NPC, UnboundOutfit)
									endif
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
				endif
			else
				dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is the player.")
			endif
			i += 1
		endwhile
		dNotif(Section+": Changed "+ActorsDone+"/"+ActorsToDo)
	endif
endFunction
;=================================================================================================================


;CheckIfFollower(NPC) returns True for non-followers. Returns Property ChangeFollowers/ChangeFollowersOnShort for followers. 
Bool Function CheckIfFollower(Actor CheckNPC)
int index = 0
while (index < playerFollowers.Length)
	If CheckNPC == playerFollowers[index]
		if Section == ("ScanNPCs"||"ScanGhouls")
			If ChangeFollowersOnShort
				return ChangeFollowersOnShort
				dNotif(Section+":"+CheckNPC.GetLeveledActorBase().GetName()+" is a follower.")
			else
				return ChangeFollowersOnShort
				dNotif(Section+":"+CheckNPC.GetLeveledActorBase().GetName()+" is a follower, that's not getting changed.")
			endif
		else
			If ChangeFollowers
				return ChangeFollowers
				dNotif(Section+":"+CheckNPC.GetLeveledActorBase().GetName()+" is a follower.")
			else
				return ChangeFollowers
				dNotif(Section+":"+CheckNPC.GetLeveledActorBase().GetName()+" is a follower, that's not getting changed.")
			endif
		endif
	endIf
index += 1
endWhile
return true
dNotif(Section+":"+CheckNPC.GetLeveledActorBase().GetName()+" is NOT a follower.")
endFunction
;=================================================================================================================
Function SetSettlerOutfit(Actor NPC, Outfit OTFTToSet)
		NPC.GetLeveledActorBase().setoutfit(OTFTToSet,false)
		NPC.setoutfit(OTFTToSet,false)
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
								Utility.Wait(WaitTime)
								NPC.Resurrect()
								dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is being changed.")
								NPC.setposition(X,Y,Z)
								NPC.setangle(0,0,ROT)
									if furnitureRef
										NPC.SnapIntoInteraction(furnitureRef)
									endif
								ActorsDone += 1
							else
								dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is too far away, now.")
							endif
						else
							dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is busy.")
						endIf
					else
						dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is disabled.")
					endif
				else
					dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is AAF Busy.")
				endif	
			else
				dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is deleted.")
			endif
		else
			dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+" is dead.")
		endif
		dNotif(Section+":"+NPC.GetLeveledActorBase().GetName()+"::"+npc+ " got an outfit "+OTFTToSet)
EndFunction
;=================================================================================================================
Function dLog(String Loggit)
;Simple, basic logging
if Logging
	debug.traceuser("OutfitShuffler",loggit)
endif
endfunction

Function dNotif(String NotificationText)
if Notifications
	Debug.Notification(NotificationText)
	if LogNotifications
		dLog(NotificationText)
	endif
endif
endfunction