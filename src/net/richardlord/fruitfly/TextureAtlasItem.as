package net.richardlord.fruitfly
{
	import starling.textures.Texture;

	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * An item in a texture atlas created when a display object is added to the dynamic atlas.
	 */
	internal class TextureAtlasItem
	{
		public var name : String;
		public var bitmap : BitmapData;
		public var region : Rectangle;
		public var frame : Rectangle;
		public var origin : Point;
		public var duration : Number;
		public var texture : Texture;
		
		public function TextureAtlasItem( name : String, bitmap : BitmapData )
		{
			this.name = name;
			this.bitmap = bitmap;
		}
	}
}
