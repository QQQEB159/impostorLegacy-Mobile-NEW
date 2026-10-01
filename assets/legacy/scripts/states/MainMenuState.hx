import funkin.data.ClientPrefs;
import funkin.data.FinaleState;
import funkin.data.CosmicubeData;
import funkin.states.TitleState;
import funkin.states.editors.MasterEditorMenu;

import flixel.text.FlxText;

function onLoad()
{
	if (!ClientPrefs.inDevMode) return;
	var debugText = new FlxText(0, 0, 1280,
		'assets/scripts/states/MainMenuState.hx\nPress 9 to go to credits roll sequence\nPress 8 to open the Editor menu\nPress 7 to toggle Finale Endgame Sequence\nPress 6 to Force unlock Cosmicube requirements\nPress 5 to delete Cosmicube unlocks\nPress 4 to toggle Force Unlock for freeplay and story mode\nPress 3 to delete bought songs\nPress 2 to be rich\nPress 1 to be poor',
		12.5);
	debugText.alignment = 'right';
	add(debugText);
	
	keyboard = new FlxSprite(40, 20);
	keyboard.loadGraphic(Paths.image('keyboard', 'mobile'));
	keyboard.scale.set(0.4, 0.4);
	keyboard.updateHitbox();
	#if mobile
	add(keyboard);
	#end
	
	FlxG.stage.window.onTextInput.add(handleCode);
}

final code:Array<String> = ["1", "2", "3", "4", "5", "6", "7", "9", "qqqeb", "8"];
var curCode:String = '';
function handleCode(str:String)
{
	curCode += str.toLowerCase();
	
	if (curCode == code[0])
	{
		CosmicubeData.currentMoney = 0;
		ClientPrefs.flush();
		trace('no money :(');
		curCode = '';
	}
	else if (curCode == code[1])
	{
		CosmicubeData.currentMoney += 1000000;
		ClientPrefs.flush();
		trace('FREE MONEY');
		curCode = '';
	}
	else if (curCode == code[2])
	{
		ClientPrefs.unlockedSongs = [];
		ClientPrefs.flush();
		trace('WIPED SONG DATA');
		curCode = '';
	}
	else if (curCode == code[3])
	{
		ClientPrefs.forceUnlock = !ClientPrefs.forceUnlock;
		ClientPrefs.doubletrouble = ClientPrefs.forceUnlock;
		ClientPrefs.flush();
		trace(ClientPrefs.forceUnlock ? 'FORCE UNLOCK ON' : 'FORCE UNLOCK OFF');
		curCode = '';
	}
	else if (curCode == code[4])
	{
		ClientPrefs.cosmicubeUnlocks.resize(0);
		ClientPrefs.flush();
		trace('Cosmicube progress reset');
		curCode = '';
	}
	else if (curCode == code[5])
	{
	    ClientPrefs.forceUnlockReq = !ClientPrefs.forceUnlockReq;
		ClientPrefs.flush();
		trace(ClientPrefs.forceUnlockReq ? 'FORCE UNLOCK REQ ON' : 'FORCE UNLOCK REQ OFF');
		curCode = '';
	}
	else if (curCode == code[6])
	{
		ClientPrefs.finaleState = (ClientPrefs.finaleState == FinaleState.ACTIVE ? FinaleState.INACTIVE : FinaleState.ACTIVE);
		ClientPrefs.flush();
		TitleState.initialized = false;
		FlxG.resetGame();
		curCode = '';
	}
	else if (curCode == code[7])
	{
		persistentUpdate = persistentDraw = false;
		openSubState(new funkin.states.substates.CreditsRollSubState(true, function() persistentUpdate = persistentDraw = true, function() persistentUpdate = persistentDraw = true));
		curCode = '';
	}
	else if (curCode == code[8])
	{
		trace("hello");
		curCode = '';
	}
	else if (curCode == code[9])
	{
		FlxG.switchState(new MasterEditorMenu());
		curCode = '';
	}
}

function onUpdate()
{
	if (!ClientPrefs.inDevMode) return;
	
	if (FlxG.keys.justPressed.SEVEN)
	{
		ClientPrefs.finaleState = (ClientPrefs.finaleState == FinaleState.ACTIVE ? FinaleState.INACTIVE : FinaleState.ACTIVE);
		ClientPrefs.flush();
		TitleState.initialized = false;
		FlxG.resetGame();
	}
	if (FlxG.keys.justPressed.EIGHT)
	{
	    FlxG.switchState(new MasterEditorMenu());
	}
	if (FlxG.keys.justPressed.NINE)
	{
		persistentUpdate = persistentDraw = false;
		openSubState(new funkin.states.substates.CreditsRollSubState(true, function() persistentUpdate = persistentDraw = true, function() persistentUpdate = persistentDraw = true));
	}
	if (FlxG.keys.justPressed.SIX)
	{
		ClientPrefs.forceUnlockReq = !ClientPrefs.forceUnlockReq;
		ClientPrefs.flush();
		trace(ClientPrefs.forceUnlockReq ? 'FORCE UNLOCK REQ ON' : 'FORCE UNLOCK REQ OFF');
	}
	if (FlxG.keys.justPressed.FIVE)
	{
		ClientPrefs.cosmicubeUnlocks.resize(0);
		ClientPrefs.flush();
		trace('Cosmicube progress reset');
	}
	if (FlxG.keys.justPressed.FOUR)
	{
		ClientPrefs.forceUnlock = !ClientPrefs.forceUnlock;
		ClientPrefs.doubletrouble = ClientPrefs.forceUnlock;
		ClientPrefs.flush();
		trace(ClientPrefs.forceUnlock ? 'FORCE UNLOCK ON' : 'FORCE UNLOCK OFF');
	}
	if (FlxG.keys.justPressed.THREE)
	{
		ClientPrefs.unlockedSongs = [];
		ClientPrefs.flush();
		trace('WIPED SONG DATA');
	}
	if (FlxG.keys.justPressed.TWO)
	{
		CosmicubeData.currentMoney += 1000000;
		ClientPrefs.flush();
		trace('FREE MONEY');
	}
	if (FlxG.keys.justPressed.ONE)
	{
		CosmicubeData.currentMoney = 0;
		ClientPrefs.flush();
		trace('no money :(');
	}
	
    if (keyboard != null && TouchUtil.overlaps(keyboard) && TouchUtil.justPressed)
	{
        FlxG.stage.window.textInputEnabled = true;
		curCode = '';
	}
}

function onDestroy()
{
    FlxG.stage.window.onTextInput.remove(handleCode);
}