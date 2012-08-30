package net.richardlord.fruitfly
{
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * A node representing a complete texture in the binary tree created when laying out the bitmaps on the textures.
	 */
	internal class TextureNode extends SubTextureNode
	{
		public var items : Vector.<TextureAtlasItem> = new Vector.<TextureAtlasItem>();
		
		public var minHeight : int = 0;
		public var minWidth : int = 0;
		
		public var bitmap : BitmapData;
		public var atlas : TextureAtlas;
		public var map : XML;
		
		override public function insert( item : TextureAtlasItem ) : Rectangle
		{
			var returnRect : Rectangle = super.insert( item );
			if( returnRect )
			{
				if( minHeight < returnRect.bottom )
				{
					minHeight = returnRect.bottom;
				}
				if( minWidth < returnRect.right )
				{
					minWidth = returnRect.right;
				}
				items.push( item );
			}
			return returnRect;
		}
		
		public function createAtlas( generateMipMaps : Boolean ) : void
		{
			while( minHeight < rect.height / 2 )
			{
				rect.height /= 2;
			}
			while( minWidth < rect.width / 2 )
			{
				rect.width /= 2;
			}

			bitmap = new BitmapData( rect.width, rect.height, true, 0 );
			var point : Point = new Point();
			for each( var item : TextureAtlasItem in items )
			{
				point.x = item.region.x;
				point.y = item.region.y;
				bitmap.copyPixels( item.bitmap, item.bitmap.rect, point );
			}

			atlas = new TextureAtlas( Texture.fromBitmapData( bitmap, generateMipMaps ) );
			for each( item in items )
			{
				atlas.addRegion( item.name, item.region, item.frame );
				item.texture = atlas.getTexture( item.name );
			}
			
			var length : int = items.length;
			var sorted : Array = new Array( length );
			for( var i : int = 0; i < length; ++i )
			{
				sorted[i] = items[i];
			}
			sorted.sortOn( "name", Array.CASEINSENSITIVE );
			map = <TextureAtlas/>;
			for each( item in sorted )
			{
				if( item.frame )
				{
					map.appendChild( <SubTexture name={item.name} x={item.region.left} y={item.region.y} width={item.region.width} height={item.region.height} frameX={item.frame.x} frameY={item.frame.y} frameWidth={item.frame.width} frameHeight={item.frame.height}/> );
				}
				else
				{
					map.appendChild( <SubTexture name={item.name} x={item.region.left} y={item.region.y} width={item.region.width} height={item.region.height}/> );
				}
			}
		}
	}
}
