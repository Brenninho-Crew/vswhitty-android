package;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

/**
 * Central asset-path resolver for FNF: Vs Whitty.
 *
 * ANDROID RULES — read before adding new file access:
 *   • NEVER use sys.io.File.getContent() or sys.FileSystem on Android.
 *     The APK is a zip archive; raw file I/O will crash or return nothing.
 *   • ALWAYS use getText(), getBytes(), or OpenFlAssets.exists() to read
 *     assets. OpenFL routes these through the Android AssetManager
 *     automatically, with no extraction to external storage required.
 *   • Lua scripting (linc_luajit) is guarded by #if !android because JIT
 *     compilation is not permitted on Android by the OS.
 */
class Paths
{
	// OGG on every target except web (web uses MP3 due to codec support).
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	static var currentLevel:String;

	static public function setCurrentLevel(name:String):Void
	{
		currentLevel = name.toLowerCase();
	}

	// ─────────────────────────── Core path resolver ────────────────────────────

	static function getPath(file:String, type:AssetType, library:Null<String>):String
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload"):String
	{
		return (library == "preload" || library == "default")
			? getPreloadPath(file)
			: getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String):String
	{
		return '$library:assets/$library/$file';
	}

	inline static function getPreloadPath(file:String):String
	{
		return 'assets/$file';
	}

	// ──────────────────────────── Text / data helpers ──────────────────────────

	/**
	 * Read a text asset as a String.
	 *
	 * Always use this instead of sys.io.File.getContent() — on Android the
	 * file lives inside the APK and can only be read via the AssetManager.
	 *
	 * Returns null if the asset does not exist (check with exists() first if
	 * you need to handle missing files gracefully).
	 */
	static public function getText(path:String):Null<String>
	{
		if (!OpenFlAssets.exists(path, TEXT))
			return null;
		return OpenFlAssets.getText(path);
	}

	/**
	 * Read a binary asset as haxe.io.Bytes.
	 *
	 * Use this instead of sys.io.File.getBytes() on Android.
	 */
	static public function getBytes(path:String):Null<haxe.io.Bytes>
	{
		if (!OpenFlAssets.exists(path, BINARY))
			return null;
		return OpenFlAssets.getBytes(path);
	}

	/**
	 * Check whether an asset exists on all targets (including Android).
	 *
	 * Replaces sys.FileSystem.exists() — that function cannot see inside
	 * the APK on Android.
	 */
	inline static public function exists(path:String, ?type:AssetType):Bool
	{
		return OpenFlAssets.exists(path, type == null ? TEXT : type);
	}

	// ─────────────────────────── Typed path helpers ────────────────────────────

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String):String
	{
		return getPath(file, type, library);
	}

	// Lua is desktop-only (linc_luajit requires JIT, which Android forbids).
	#if !android
	inline static public function lua(key:String, ?library:String):String
	{
		return getPath('data/$key.lua', TEXT, library);
	}

	inline static public function luaImage(key:String, ?library:String):String
	{
		return getPath('data/$key.png', IMAGE, library);
	}
	#end

	inline static public function txt(key:String, ?library:String):String
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String):String
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String):String
	{
		return getPath('data/$key.json', TEXT, library);
	}

	// ──────────────────────────── Audio helpers ────────────────────────────────

	static public function sound(key:String, ?library:String):String
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String):String
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String):String
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function voices(song:String):String
	{
		return 'songs:assets/songs/${song.toLowerCase()}/Voices.$SOUND_EXT';
	}

	inline static public function inst(song:String):String
	{
		return 'songs:assets/songs/${song.toLowerCase()}/Inst.$SOUND_EXT';
	}

	// ──────────────────────────── Visual helpers ───────────────────────────────

	inline static public function image(key:String, ?library:String):String
	{
		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function font(key:String):String
	{
		// Fonts are always in the preload bundle and embedded at compile time
		// (see Project.xml: <assets path="assets/fonts" embed="true" />).
		return 'assets/fonts/$key';
	}

	inline static public function getSparrowAtlas(key:String, ?library:String):FlxAtlasFrames
	{
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String):FlxAtlasFrames
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}
}