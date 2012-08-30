package net.richardlord.fruitfly
{
	import starling.utils.getNextPowerOfTwo;

	import flash.geom.Rectangle;

	internal class TextureAtlasCollection
	{
		public static const maxWidth : int = 2048;
		public static const maxHeight : int = 2048;
		public static const maxArea : int = 2048 * 2048;
		
		private var itemNames : Object = {}; // used to check for collisions
		
		public var items : Vector.<TextureAtlasItem> = new Vector.<TextureAtlasItem>();
		public var name : String;
		public var area : int = 0;
		public var minWidth : int = 0;
		public var minHeight : int = 0;
		
		public var generated : Boolean;
		
		public var textureNodes : Vector.<TextureNode>;
		
		public function addItem( item : TextureAtlasItem ) : void
		{
			if( itemNames[item.name] )
			{
				throw new Error( "Subtexture name already in use - " + item.name );
			}
			itemNames[item.name] = true;
			if( item.bitmap.width > maxWidth || item.bitmap.height > maxHeight )
			{
				throw new Error( "Bitmap too large to add to the texture atlas" );
			}
			area += item.bitmap.width * item.bitmap.height;
			if( minWidth < item.bitmap.width ) minWidth = item.bitmap.width;
			if( minHeight < item.bitmap.height ) minHeight = item.bitmap.height;
			for( var i : int = 0; i < items.length; ++i )
			{
				if( items[i].bitmap.height < item.bitmap.height
					|| ( items[i].bitmap.height == item.bitmap.height && items[i].bitmap.width < item.bitmap.width ) )
				{
					break;
				}
			}
			items.splice( i, 0, item );
		}
		
		public function generateAtlas( generateMipMaps : Boolean ) : void
		{
			var minSide : int = getNextPowerOfTwo( Math.ceil( Math.sqrt( area ) ) );
			var width : int = minSide;
			var height : int = minSide;
			if( width * height / 2 > area )
			{
				height /= 2;
			}
			while( width < minWidth )
			{
				width *= 2;
				if( height / 2 >= minHeight )
				{
					height /= 2;
				}
			}
			while( height < minHeight )
			{
				height *= 2;
				if( width / 2 >= minWidth )
				{
					width /= 2;
				}
			}
			while( width > maxWidth && height < maxHeight )
			{
				width /= 2;
				height *= 2;
			}
			while( height > maxHeight && width < maxWidth )
			{
				height /= 2;
				width *= 2;
			}
			if( height * 2 < maxHeight )
			{
				height *= 2; // we'll reduce it again afterwards if we can.
			}
			if( height > maxHeight )
			{
				height = maxHeight;
			}
			if( width > maxWidth )
			{
				width = maxWidth;
			}
			
			textureNodes = new Vector.<TextureNode>();
			var root : SubTextureNode = new TextureNode();
			textureNodes.push( root );
			root.rect = new Rectangle( 0, 0, width, height );
			var rect : Rectangle;
			var item : TextureAtlasItem;
			for each( item in items )
			{
				rect = root.insert( item );
				while( !rect )
				{
					var newNode : TextureNode = new TextureNode();
					newNode.rect = new Rectangle( 0, 0, width, height );
					textureNodes.push( newNode );
					var newRoot : SubTextureNode = new SubTextureNode();
					newRoot.left = root;
					newRoot.right = newNode;
					root = newRoot;
					rect = root.insert( item );
				}
			}
			for each( var node : TextureNode in textureNodes )
			{
				node.createAtlas( generateMipMaps );
			}
			generated = true;
		}
	}
}
