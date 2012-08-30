package net.richardlord.fruitfly
{
	import flash.geom.Rectangle;

	/**
	 * A simple node in the binary tree created when laying out the bitmaps on the textures.
	 */
	internal class SubTextureNode
	{
		public var left : SubTextureNode;
		public var right : SubTextureNode;
		public var rect : Rectangle;
		public var image : TextureAtlasItem;
		
		public function insert( item : TextureAtlasItem ) : Rectangle
		{
			var newRect : Rectangle;
			if( image )
			{
				return null;
			}
			if( left || right )
			{
				newRect = left.insert( item );
				if( newRect )
				{
					return newRect;
				}
				else
				{
					return right.insert( item );
				}
			}
			if( rect.width < item.bitmap.width || rect.height < item.bitmap.height )
			{
				return null;
			}
			if( rect.width == item.bitmap.width && rect.height == item.bitmap.height )
			{
				image = item;
				item.region = rect;
				return rect;
			}
			left = new SubTextureNode();
			right = new SubTextureNode();
			
			if( rect.height == item.bitmap.height )
			{
				left.rect = new Rectangle( rect.x, rect.y, item.bitmap.width, rect.height );
				right.rect = new Rectangle( rect.x + item.bitmap.width, rect.y, rect.width - item.bitmap.width, rect.height );
			}
			else
			{
				left.rect = new Rectangle( rect.x, rect.y, rect.width, item.bitmap.height );
				right.rect = new Rectangle( rect.x, rect.y + item.bitmap.height, rect.width, rect.height - item.bitmap.height );
			}
			return left.insert( item );
		}
	}
}
