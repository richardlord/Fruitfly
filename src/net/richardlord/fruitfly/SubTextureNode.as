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
		
		private var padding : int = 1;
		
		public function SubTextureNode( padding : int )
		{
			this.padding = padding;
		}
		
		public function insert( item : TextureAtlasItem ) : Rectangle
		{
			var newRect : Rectangle;
			
			var widthWithPadding : int = item.bitmap.width + padding;
			var heightWithPadding : int = item.bitmap.height + padding;
			
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
			if( rect.width < widthWithPadding || rect.height < heightWithPadding )
			{
				return null;
			}
			if( rect.width == widthWithPadding && rect.height == heightWithPadding )
			{
				image = item;
				item.region = rect;
				return rect;
			}
			left = new SubTextureNode( padding );
			right = new SubTextureNode( padding );
			
			if( rect.height == heightWithPadding )
			{
				left.rect = new Rectangle( rect.x, rect.y, widthWithPadding, rect.height );
				right.rect = new Rectangle( rect.x + widthWithPadding, rect.y, rect.width - widthWithPadding, rect.height );
			}
			else
			{
				left.rect = new Rectangle( rect.x, rect.y, rect.width, heightWithPadding );
				right.rect = new Rectangle( rect.x, rect.y + heightWithPadding, rect.width, rect.height - heightWithPadding );
			}
			return left.insert( item );
		}
	}
}
