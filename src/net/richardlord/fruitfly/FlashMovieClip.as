package net.richardlord.fruitfly
{
	import flash.display.MovieClip;

	/**
	 * The data for a MovieClip that is to be added to the DisplayAssetHandler
	 */
	internal class FlashMovieClip
	{
		public var clip : MovieClip;
		public var fps : Number;
		public var scale : Number;
		public var frames : Vector.<TextureAtlasItem>;
		
		public function FlashMovieClip( clip : MovieClip, fps : Number, scale : Number )
		{
			this.clip = clip;
			this.fps = fps;
			this.scale = scale;
		}
	}
}
