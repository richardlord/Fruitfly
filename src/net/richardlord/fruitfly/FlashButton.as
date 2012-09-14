package net.richardlord.fruitfly
{
	import flash.display.SimpleButton;

	/**
	 * The data for a DisplayObject that is to be added to the DisplayAssetHandler
	 */
	internal class FlashButton
	{
		public var button : SimpleButton;
		public var scale : Number;
		public var upFrame : TextureAtlasItem;
		public var downFrame : TextureAtlasItem;
		
		public function FlashButton( button : SimpleButton, scale : Number )
		{
			this.button = button;
			this.scale = scale;
		}
	}
}
