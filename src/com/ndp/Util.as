package com.ndp 
{
	import starling.core.Starling;
	/**
	 * ...
	 * @author ndp
	 */
	public class Util 
	{
		static public var root:App;
		
		public function Util() 
		{
			
		}
		
		public static function get appWidth():int
		{
			return Starling.current.stage.stageWidth;
		}
		
		public static function get appHeight():int
		{
			return Starling.current.stage.stageHeight;
		}
		
		public static function get deviceWidth():int
		{
			return Starling.current.nativeStage.fullScreenWidth;
		}
		
		public static function get deviceHeight():int
		{
			return Starling.current.nativeStage.fullScreenHeight;
		}
		
	}

}