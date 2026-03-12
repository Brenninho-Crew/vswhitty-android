package;

import openfl.display.BlendMode;
import openfl.text.TextFormat;
import openfl.display.Application;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;

class Main extends Sprite
{
	var gameWidth:Int = 1280;  // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720;  // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = -1;       // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 120;   // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets.

	public static var watermarks:Bool = true; // Whether to put Kade Engine literally anywhere.

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int  = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth  / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth  = Math.ceil(stageWidth  / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		#if !debug
		initialState = TitleState;
		#end

		// On Android the game runs at 60 fps to keep the device cool and the
		// framerate stable. Override by changing ANDROID_FPS below.
		#if android
		final ANDROID_FPS:Int = 60;
		game = new FlxGame(gameWidth, gameHeight, initialState, zoom, ANDROID_FPS, ANDROID_FPS, skipSplash, startFullscreen);
		#else
		game = new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen);
		#end

		addChild(game);

		// FPS counter is hidden on mobile — it wastes render budget and is hard
		// to tap on a touchscreen. The toggle methods below still work on desktop.
		#if !mobile
		fpsCounter = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsCounter);
		toggleFPS(FlxG.save.data.fps);
		#end

		// On Android, keep the screen on while the game is running.
		#if android
		lime.system.System.allowScreenTimeout = false;
		#end
	}

	var game:FlxGame;

	#if !mobile
	var fpsCounter:FPS;

	/** Show or hide the FPS counter (desktop only). */
	public function toggleFPS(fpsEnabled:Bool):Void
	{
		fpsCounter.visible = fpsEnabled;
	}

	/** Change the colour of the FPS counter text (desktop only). */
	public function changeFPSColor(color:FlxColor):Void
	{
		fpsCounter.textColor = color;
	}
	#else
	// Stub methods so any code that calls toggleFPS / changeFPSColor compiles
	// on Android without needing #if guards at every call site.

	/** No-op on Android — there is no FPS counter on mobile. */
	public function toggleFPS(fpsEnabled:Bool):Void {}

	/** No-op on Android — there is no FPS counter on mobile. */
	public function changeFPSColor(color:FlxColor):Void {}
	#end

	/** Set the stage frame-rate cap (works on all targets). */
	public function setFPSCap(cap:Float):Void
	{
		openfl.Lib.current.stage.frameRate = cap;
	}

	/** Return the current stage frame-rate cap (works on all targets). */
	public function getFPSCap():Float
	{
		return openfl.Lib.current.stage.frameRate;
	}

	/** Return the measured FPS. Returns 0 on Android (no FPS counter). */
	public function getFPS():Float
	{
		#if !mobile
		return fpsCounter.currentFPS;
		#else
		return 0;
		#end
	}
}