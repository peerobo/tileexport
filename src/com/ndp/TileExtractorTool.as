package com.ndp
{
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeDragManager;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import starling.core.Starling;
	import starling.utils.RectangleUtil;
	import starling.utils.ScaleMode;
	
	/**
	 * ...
	 * @author ndp
	 */
	[SWF(width="1280",height="900")]
	public class TileExtractorTool extends Sprite 
	{
		private var spr:Sprite;
		
		public function TileExtractorTool():void 
		{
			var starling:Starling = new Starling(App, stage);
			starling.start();			
			
			spr = new Sprite();
			addChild(spr);
			addEventListener(Event.ADDED_TO_STAGE, onStaged);
						
		}
		
		private function onStaged(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, onStaged);
			
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0x0, 0);
			shape.graphics.drawRect(0, 0, Util.appWidth, Util.appHeight);
			spr.addChild(shape);
			
			//register for the drag enter event
			spr.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, onDragIn);			
			//register for the drag drop event
			spr.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, onDragDrop);
		}
		
		private function onDragDrop(e:NativeDragEvent):void
		{
			//get the array of files being drug into the app
			var arr:Array = e.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;			
			//grab the files file
			var f:File = File(arr[0]);			
			//create a FileStream to work with the file
			var fs:FileStream = new FileStream();			
			//open the file for reading
			fs.open(f, FileMode.READ);			
			//read the file as a string
			var data:ByteArray = new ByteArray();
			fs.readBytes(data);
			//close the file
			fs.close();
			
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadByteComplete);
			loader.loadBytes(data);
		}
		
		private function onLoadByteComplete(e:Event):void 
		{
			var loader:LoaderInfo = e.currentTarget as LoaderInfo;
			var bitmap:Bitmap = loader.content as Bitmap;
			if (bitmap)
			{
				var bd:BitmapData = bitmap.bitmapData;
				//var rec:Rectangle = new Rectangle(0, 0, bd.width, bd.height);
				//var recInto:Rectangle = new Rectangle(0, 0, Util.appWidth, Util.appHeight);
				//rec = RectangleUtil.fit(rec, recInto, ScaleMode.SHOW_ALL);
				//var scale:Number = rec.width / bd.width;
				//bitmap.scaleX = bitmap.scaleY = scale;
				//bitmap.x = rec.x;
				//bitmap.y = rec.y;
				//Starling.current.nativeOverlay.addChild(bitmap);
				Util.root.showImage(bd);
			}
		}
		
		private function onDragIn(e:NativeDragEvent):void
		{
			//check and see if files are being drug in
			if (e.clipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT))
			{
				//get the array of files
				var files:Array = e.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;				
				//make sure only one file is dragged in (i.e. this app doesn't
				//support dragging in multiple files)
				if (files.length == 1)
				{
					//accept the drag action
					NativeDragManager.acceptDragDrop(spr);
				}
			}
		
		}
		
	}
	
}