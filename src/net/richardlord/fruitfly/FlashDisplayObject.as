package net.richardlord.fruitfly
{
	import flash.display.DisplayObject;

	/**
	 * The data for a DisplayObject that is to be added to the DisplayAssetHandler
	 */
	internal class FlashDisplayObject
	{
		public var object : DisplayObject;
		public var scale : Number;
		public var frame : TextureAtlasItem;
		
		public function FlashDisplayObject( object : DisplayObject, scale : Number )
		{
			this.object = object;
			this.scale = scale;
		}
	}
}
