package net.richardlord.fruitfly
{
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	/**
	 * Combines multiple TextureAtlases into a single object giving a single point of
	 * access to the textures in all the atlases.
	 */
	public class MultiAtlas
	{
		private var atlases : Vector.<TextureAtlas> = new Vector.<TextureAtlas>();

		public function addAtlas( atlas : TextureAtlas ) : void
		{
			atlases.push( atlas );
		}
		
		public function dispose() : void
		{
			for each( var atlas : TextureAtlas in atlases )
			{
				atlas.dispose();
			}
			atlases.length = 0;
		}
		
		public function getTexture( name : String ) : Texture
		{
			for each( var atlas : TextureAtlas in atlases )
			{
				var texture : Texture = atlas.getTexture( name );
				if( texture )
				{
					return texture;
				}
			}
			return null;
		}
	}
}
