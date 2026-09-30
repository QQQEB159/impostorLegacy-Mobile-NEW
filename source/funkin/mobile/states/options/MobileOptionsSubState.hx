package funkin.mobile.states.options;

import funkin.states.options.*;

class MobileOptionsSubState extends BaseOptionsMenu
{
	#if android
	var storageTypes:Array<String> = [
        Lang.str('storage_external_data', 'EXTERNAL_DATA'),
        Lang.str('storage_external_obb', 'EXTERNAL_OBB'),
        Lang.str('storage_external_media', 'EXTERNAL_MEDIA'),
        Lang.str('storage_external', 'EXTERNAL')
    ];
	var externalPaths:Array<String> = StorageUtil.checkExternalPaths(true);
	final lastStorageType:String = ClientPrefs.storageType;
	#end
	final exControlTypes:Array<String> = ["NONE", "SINGLE", "DOUBLE"];
	final hintOptions:Array<String> = [
        Lang.str('hint_noGradient', 'No Gradient'),
        Lang.str('hint_noGradientOld', 'No Gradient (Old)'),
        Lang.str('hint_gradient', 'Gradient'),
        Lang.str('hint_hidden', 'Hidden')
    ];
    var spacePosOptions:Array<String> = [
        Lang.str('pos_bottom', 'Bottom'),
        Lang.str('pos_middle', 'Middle'),
        Lang.str('pos_top', 'Top')
    ];
	var option:Option;

	public function new()
	{
		#if android if (!externalPaths.contains('\n'))
			storageTypes = storageTypes.concat(externalPaths); #end
		title = 'mobileoptions';
		rpcTitle = 'Mobile Options Menu'; // for Discord Rich Presence, fuck it

		var option:Option = new Option(Lang.str('opt_mobilecontrols', 'Mobile Controls'), Lang.str('opt_mobilecontrols_desc', 'Choose which control to play.'), '', 'button', true);
		option.callback = function() {
		    openSubState(new funkin.mobile.states.substates.MobileControlSelectSubState());
		    funkin.states.options.OptionsState.qqqeb = true;
		    //touchPad.active = touchPad.visible = false;
		}
		addOption(option);
		
		var option:Option = new Option(Lang.str('opt_mobileControlsOpacity', 'Mobile Controls Opacity'), Lang.str('opt_mobileControlsOpacity_desc', 'Selects the opacity for the mobile buttons (careful not to put it at 0 and lose track of your buttons).'), 'controlsAlpha', 'percent', 0.6);
		option.scrollSpeed = 1;
		option.minValue = 0.001;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		option.onChange = () ->
		{
			//touchPad.alpha = curOption.getValue();
		};
		addOption(option);

		#if mobile
	    var option:Option = new Option(Lang.str('opt_allowPhoneScreensaver', 'Allow Phone Screensaver'), Lang.str('opt_allowPhoneScreensaver_desc', 'If checked, the phone will sleep after going inactive for few seconds.\n(The time depends on your phone\'s options)'), 'screensaver', 'bool', false);
		option.onChange = () -> lime.system.System.allowScreenTimeout = curOption.getValue();
		addOption(option);
		#end

		var option:Option = new Option(Lang.str('opt_spaceControl', 'Space Control'), Lang.str('opt_spaceControl_desc', 'If checked, the space bar will be enabled.'), 'extraButton', 'bool', false);
        addOption(option);
		
		if (MobileData.mode == 3)
		{
			var option:Option = new Option(Lang.str('opt_hitboxDesign', 'Hitbox Design'), Lang.str('opt_hitboxDesign_desc', 'Choose how your hitbox should look like.'), 'hitboxType', 'string', 'Gradient', hintOptions, ['No Gradient', 'No Gradient (Old)', 'Gradient', 'Hidden']);
			addOption(option);
			
			var option:Option = new Option(Lang.str('opt_spacePosition', 'Space Position'), Lang.str('opt_spacePosition_desc', "Choose Space Control Position For Hitbox"), 'hitboxLocation', 'string', 'Bottom', spacePosOptions, ['Bottom', 'Middle', 'Top']);
            addOption(option);
		}

		#if android
		var option:Option = new Option(Lang.str('opt_storageType', 'Storage Type'), Lang.str('opt_storageType_desc', 'Which folder NightmareVision Engine should use?\n(CHANGING THIS MAKES DELETE YOUR OLD FOLDER!!)'), 'storageType', 'string', 'EXTERNAL_DATA', storageTypes, ["EXTERNAL_DATA", "EXTERNAL_OBB", "EXTERNAL_MEDIA", "EXTERNAL"]);
		addOption(option);
		#end

		super();
	}

	#if android
	function onStorageChange():Void
	{
		File.saveContent(lime.system.System.applicationStorageDirectory + 'storagetype.txt', ClientPrefs.storageType);

		var lastStoragePath:String = StorageType.fromStrForce(lastStorageType) + '/';

		try
		{
			if (ClientPrefs.storageType != "EXTERNAL")
				Sys.command('rm', ['-rf', lastStoragePath]);
		}
		catch (e:haxe.Exception)
			trace('Failed to remove last directory. (${e.message})');
	}
	#end

	override public function destroy()
	{
		super.destroy();
		ClientPrefs.flush();
		#if android
		if (ClientPrefs.storageType != lastStorageType)
		{
			onStorageChange();
			CoolUtil.showPopUp('Storage Type has been changed and you needed restart the game!!\nPress OK to close the game.', 'Notice!');
			lime.system.System.exit(0);
		}
		#end
	}
}
