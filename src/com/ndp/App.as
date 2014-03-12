package com.ndp
{
	import adobe.utils.ProductManager;
	import feathers.controls.Button;
	import feathers.controls.Label;
	import feathers.controls.Panel;
	import feathers.controls.supportClasses.TextFieldViewPort;
	import feathers.controls.text.TextFieldTextEditor;
	import feathers.controls.text.TextFieldTextRenderer;
	import feathers.controls.TextInput;
	import feathers.core.FeathersControl;
	import feathers.core.FocusManager;
	import feathers.core.ITextEditor;
	import feathers.core.ITextRenderer;
	import feathers.layout.TiledColumnsLayout;
	import feathers.text.BitmapFontTextFormat;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeDragManager;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.PNGEncoderOptions;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.SharedObject;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	import starling.core.Starling;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.QuadBatch;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.extensions.Particle;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.utils.RectangleUtil;
	import starling.utils.ScaleMode;
	
	/**
	 * ...
	 * @author ndp
	 */
	public class App extends Sprite
	{
		private var bd:BitmapData;
		private var textVals:Array;
		
		private const W:String = "width";
		private const H:String = "height";
		private const M:String = "margin";
		private const S:String = "spacing";
		private const C:String = "alpha";
		
		private const INPUT:Array = [W, H, M, S, C];
		private const SPACING:int = 10;
		private var imageSpr:Sprite;
		private var listPreview:QuadBatch;
		private var sourceTexture:Texture;
		private var shareObj:SharedObject;		
		private var panelPreview:Panel;
		
		public function App()
		{
			addEventListener(Event.ADDED_TO_STAGE, onInit);
			Util.root = this;
			shareObj = SharedObject.getLocal("tileextractor");
		}
		
		public function showImage(bd:BitmapData):void
		{
			var bt:Button;
			var quad:Quad;
			this.removeChildren();
						
			this.bd = bd;
			
			
			// image panel
			var panel:Panel = new Panel();
			panel.padding = 10;
			quad = new Quad(20, 20, 0x71B8FF);
			panel.backgroundSkin = quad;
			panel.x = 10;
			panel.y = 10;
			panel.headerProperties.title = "Image";
			panel.width = (Util.appWidth >> 1) - panel.x * 2;
			panel.height = Util.appHeight - panel.y * 2;
			addChild(panel);
			
			imageSpr = new Sprite();
			panel.addChild(imageSpr);
			
			var texture:Texture = Texture.fromBitmapData(bd);
			var img:Image = new Image(texture);
			imageSpr.addChild(img);			
			sourceTexture = texture;
			
			// config panel
			panel = new Panel();
			panel.padding = 10;
			quad = new Quad(20, 20, 0x71B8FF);
			panel.backgroundSkin = quad;
			panel.width = (Util.appWidth >> 1) - 10;
			panel.x = (Util.appWidth >> 1);
			panel.y = 10;
			panel.height = (Util.appHeight >> 1) - 20;
			addChild(panel);
			
			textVals = [];
			for (var i:int = 0; i < INPUT.length; i++)
			{
				textVals.push(createTextInput(50, 50 * i + 50, (Util.appWidth >> 1) - 100, 45, INPUT[i], panel));
			}
			
			bt = new Button();
			bt.label = "Alpha";
			quad = new Quad(20, 20, 0x00FF80)
			bt.defaultSkin = quad;
			bt.x = 10;
			bt.y = textVals[textVals.length - 1].y + 70;
			panel.addChild(bt);
			Factory.addMouseClickCallback(bt, onShowImage);
			
			bt = new Button();
			bt.label = "Preview";
			quad = new Quad(20, 20, 0x00FF80)
			bt.defaultSkin = quad;
			bt.x = 140;
			bt.y = textVals[textVals.length - 1].y + 70;
			panel.addChild(bt);
			Factory.addMouseClickCallback(bt, onPreview);
			
			bt = new Button();
			bt.label = "Generate images";
			quad = new Quad(20, 20, 0x00FF80)
			bt.defaultSkin = quad;
			bt.x = 300;
			bt.y = textVals[textVals.length - 1].y + 70;
			panel.addChild(bt);
			Factory.addMouseClickCallback(bt, onGenerate);
			
			FocusManager.isEnabled = true;
			FocusManager.pushFocusManager(new FocusManager(panel));
			
			panel = new Panel();
			panel.padding = 10;
			quad = new Quad(20, 20, 0x71B8FF);
			panel.backgroundSkin = quad;
			panel.headerProperties.title = "tiles generate";
			panel.width = (Util.appWidth >> 1) - 10;
			panel.height = (Util.appHeight >> 1) - 10;
			panel.x = (Util.appWidth >> 1);
			panel.y = (Util.appHeight >> 1);
			addChild(panel);
			
			listPreview = new QuadBatch();			
			panel.addChild(listPreview);
			panelPreview = panel;
		}
		
		private function onShowImage():void 
		{
			var c:uint = 0;
			var idx:int = INPUT.indexOf(C);
			c = 0x5E81A2;
			c = parseInt((textVals[idx] as TextInput).text);			
			shareObj.data[C] = c;
			
			
			var outputBitmapData:BitmapData = new BitmapData(bd.width, bd.height, true , 0x000000);						
			var threshold:uint = c;						
			for (var l:int = 0; l < bd.height; l++)
			{
				for (var j:int = 0; j < bd.width; j++)
				{
					
					var currentPixel:uint = bd.getPixel(j, l);
					var argb:uint = (0xFF << 24) | currentPixel;
					if (currentPixel != threshold)
					{
						outputBitmapData.setPixel32(j,l, argb);
					}					
				}
			}			
			this.bd = outputBitmapData;
			imageSpr.removeChildren();
			var texture:Texture = Texture.fromBitmapData(outputBitmapData);
			var img:Image = new Image(texture);
			imageSpr.addChild(img);			
			sourceTexture = texture;
		}
		
		private function onGenerate():void
		{
			var w:int = 0;
			var h:int = 0;
			var m:int = 0;
			var s:int = 0;			
			for (var i:int = 0; i < textVals.length; i++)
			{
				
				var value:int = parseInt((textVals[i] as TextInput).text);
				switch (INPUT[i])
				{
					case W: 
						w = value;
						shareObj.data[W] = w;
						break;
					case H: 
						h = value;
						shareObj.data[H] = h;
						break;
					case M: 
						m = value;
						shareObj.data[M] = m;
						break;
					case S: 
						s = value;
						shareObj.data[S] = s;
						break;								
				}
			}			
			var widthBD:int = bd.width;
			var heightBD:int = bd.height;			
			var posY:int = m;
			var posX:int = 0;
			var rec:Rectangle = new Rectangle();			
			var desktopFolder:File = File.desktopDirectory.resolvePath(".");
			var row:int = 0;
			var col:int = 0;
			while (posY + h <= heightBD)
			{
				posX = m;
				col = 0;
				while (posX + w <= widthBD)
				{
					rec.x = posX;
					rec.y = posY;
					rec.width = w;
					rec.height = h;					
					var byteArray:ByteArray = new ByteArray();
					bd.encode(rec, new PNGEncoderOptions(), byteArray);
					
					var file:File = desktopFolder.resolvePath("tileexport/img" + "_" + row + "_" + col + ".png");
					var stream:FileStream = new FileStream();
					stream.open(file, FileMode.WRITE);
					stream.writeBytes(byteArray);					
					stream.close();
					
					posX += w + s;										
					col++;
				}
				posY += h + s;				
				row++;
			}
			panelPreview.removeChildren();
			panelPreview.addChild(new TextField(panelPreview.width,panelPreview.height,"Done!","Verdana",40) );
		}
		
		private function onPreview():void
		{
			var w:int = 0;
			var h:int = 0;
			var m:int = 0;
			var s:int = 0;			
			for (var i:int = 0; i < textVals.length; i++)
			{
				
				var value:int = parseInt((textVals[i] as TextInput).text);
				switch (INPUT[i])
				{
					case W: 
						w = value;
						shareObj.data[W] = w;
						break;
					case H: 
						h = value;
						shareObj.data[H] = h;
						break;
					case M: 
						m = value;
						shareObj.data[M] = m;
						break;
					case S: 
						s = value;
						shareObj.data[S] = s;
						break;								
				}
			}
			listPreview.reset();
			var widthBD:int = bd.width;
			var heightBD:int = bd.height;
			var drawX:int = 0;
			var drawY:int = 0;
			var posY:int = m;
			var posX:int = 0;
			var rec:Rectangle = new Rectangle();
			var img:Image = new Image(Texture.empty(w, h));
			while (posY + h <= heightBD)
			{
				posX = m;
				drawX = 0;
				while (posX + w <= widthBD)
				{
					rec.x = posX;
					rec.y = posY;
					rec.width = w;
					rec.height = h;
					var texture:Texture = Texture.fromTexture(sourceTexture, rec);
					img.texture = texture;
					img.readjustSize();
					img.x = drawX;
					img.y = drawY;
					listPreview.addImage(img);
					
					posX += w + s;					
					drawX += w + SPACING;
				}
				posY += h + s;
				drawY += h + SPACING;
			}	
			panelPreview.removeChildren();
			panelPreview.addChild(listPreview);
		}
		
		private function createTextInput(x:int, y:int, width:int, height:int, title:String, parent:DisplayObjectContainer):TextInput
		{
			var lbl:Label = new Label();
			lbl.text = title;
			lbl.x = x;
			lbl.y = y;
			parent.addChild(lbl);
			var w:int = width >> 1;
			var textInput:TextInput = new TextInput();
			var quad:Quad = new Quad(100, height, 0x8080C0);
			textInput.backgroundSkin = quad;
			textInput.width = w;
			textInput.height = height;
			textInput.x = lbl.x + w;
			textInput.y = y;
			parent.addChild(textInput);
			textInput.text = shareObj.data[title];
			return textInput;
		}
		
		private function onInit(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onInit);
			
			var textfield:TextField = new TextField(Util.appWidth, Util.appHeight, "Drag Image File Here...", "Verdana", 60);
			addChild(textfield);
			textfield.touchable = false;
			
			FeathersControl.defaultTextRendererFactory = function():ITextRenderer
			{
				var textRenderer:TextFieldTextRenderer = new TextFieldTextRenderer();
				textRenderer.textFormat = new TextFormat("Arial", 32, 0x0, true, false, false, null, null, null, 10, 10);
				return textRenderer;
			}
			
			FeathersControl.defaultTextEditorFactory = function():ITextEditor
			{
				var textEditor:TextFieldTextEditor = new TextFieldTextEditor();
				textEditor.textFormat = new TextFormat("Arial", 32, 0x0, true);
				return textEditor;
			}
		}
	
	}

}