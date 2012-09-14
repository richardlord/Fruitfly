package net.richardlord.fruitfly
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.StageQuality;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * converts DisplayObjects into BitmapData objects
	 */
	public class BitmapCreator
	{
		private var transform : Matrix = new Matrix();

		public function convertDisplayObjectToBitmap( name : String, displayObject : DisplayObject, scale : Number = 1, quality : String = StageQuality.BEST ) : TextureAtlasItem
		{
			var bounds : Rectangle = displayObject.getBounds( displayObject );
			var w : int = Math.abs( Math.ceil( bounds.width * scale ) );
			var h : int = Math.abs( Math.ceil( bounds.height * scale ) );
			var bitmapData : BitmapData = new BitmapData( w, h, true, 0 );
			var absScale : Number = scale < 0 ? -scale : scale;
			var x : Number = -bounds.left * absScale;
			var y : Number = -bounds.top * absScale;
			transform.a = scale;
			transform.d = scale;
			transform.tx = x;
			transform.ty = y;
			bitmapData.drawWithQuality( displayObject, transform, null, null, null, true, quality );
			var item : TextureAtlasItem = new TextureAtlasItem( name, bitmapData );
			item.origin = new Point( x, y );
			return item;
		}

		public function convertClipToBitmaps( name : String, clip : MovieClip, fps : Number, scale : Number = 1, quality : String = StageQuality.BEST ) : Vector.<TextureAtlasItem>
		{
			transform.a = scale;
			transform.d = scale;
			transform.tx = 0;
			transform.ty = 0;
			
			var bounds : Rectangle;
			var item : TextureAtlasItem;
			var bitmapData : BitmapData;
			var w : int;
			var h : int;
			var x : Number;
			var y : Number;
			var places : int = clip.totalFrames.toString().length;
			var absScale : Number = scale < 0 ? -scale : scale;

			var frames : Vector.<TextureAtlasItem> = new Vector.<TextureAtlasItem>();
			var len : uint = clip.totalFrames;
			var frame : int;
			var maxBounds : Rectangle = clip.getBounds( clip );
			for ( frame = 1; frame <= len; ++frame )
			{
				clip.gotoAndStop( frame );
				bounds = clip.getBounds( clip );
				maxBounds = maxBounds.union( bounds );
			}
			maxBounds.x *= absScale;
			maxBounds.y *= absScale;
			maxBounds.width *= absScale;
			maxBounds.height *= absScale;
			roundOutRect( maxBounds );
			for ( frame = 1; frame <= len; ++frame )
			{
				clip.gotoAndStop( frame );
				bounds = roundOutRect( scaleRect( clip.getBounds( clip ), absScale ) );
				w = bounds.width;
				h = bounds.height;
				bitmapData = new BitmapData( w, h, true, 0 );
				x = -bounds.left;
				y = -bounds.top;
				transform.tx = x;
				transform.ty = y;
				bitmapData.drawWithQuality( clip, transform, null, null, null, true, quality );
				if ( item && frame != len && compareData( bitmapData, item.bitmap ) )
				{
					if ( x == item.origin.x && y == item.origin.y )
					{
						item.duration += 1 / fps;
						continue;
					}
					else
					{
						bitmapData = item.bitmap;
					}
				}
				item = new TextureAtlasItem( name + "_" + padWithZeros( frame, places ), bitmapData );
				item.duration = 1 / fps;
				item.frame = maxBounds.clone();
				item.frame.offset( x, y );
				item.origin = new Point( -maxBounds.x, -maxBounds.y );
				frames.push( item );
			}
			return frames;
		}

		public function convertButtonToBitmaps( name : String, button : SimpleButton, scale : Number = 1, quality : String = StageQuality.BEST ) : Vector.<TextureAtlasItem>
		{
			transform.a = scale;
			transform.d = scale;
			transform.tx = 0;
			transform.ty = 0;
			
			var bounds : Rectangle;
			var item : TextureAtlasItem;
			var bitmapData : BitmapData;
			var w : int;
			var h : int;
			var x : Number;
			var y : Number;
			var absScale : Number = scale < 0 ? -scale : scale;

			var frames : Vector.<TextureAtlasItem> = new Vector.<TextureAtlasItem>();
			var maxBounds : Rectangle = button.upState.getBounds( button );
			bounds = button.downState.getBounds( button );
			maxBounds = maxBounds.union( bounds );
			maxBounds.x *= absScale;
			maxBounds.y *= absScale;
			maxBounds.width *= absScale;
			maxBounds.height *= absScale;
			roundOutRect( maxBounds );

			bounds = roundOutRect( scaleRect( button.upState.getBounds( button.upState ), absScale ) );
			w = bounds.width;
			h = bounds.height;
			bitmapData = new BitmapData( w, h, true, 0 );
			x = -bounds.left;
			y = -bounds.top;
			transform.tx = x;
			transform.ty = y;
			bitmapData.drawWithQuality( button.upState, transform, null, null, null, true, quality );
			item = new TextureAtlasItem( name + "_up", bitmapData );
			item.frame = maxBounds.clone();
			item.frame.offset( x, y );
			item.origin = new Point( -maxBounds.x, -maxBounds.y );
			frames.push( item );
			
			bounds = roundOutRect( scaleRect( button.downState.getBounds( button.downState ), absScale ) );
			w = bounds.width;
			h = bounds.height;
			bitmapData = new BitmapData( w, h, true, 0 );
			x = -bounds.left;
			y = -bounds.top;
			transform.tx = x;
			transform.ty = y;
			bitmapData.drawWithQuality( button.downState, transform, null, null, null, true, quality );
			if ( compareData( bitmapData, item.bitmap ) )
			{
				bitmapData = item.bitmap;
			}
			item = new TextureAtlasItem( name + "_down", bitmapData );
			item.frame = maxBounds.clone();
			item.frame.offset( x, y );
			item.origin = new Point( -maxBounds.x, -maxBounds.y );
			frames.push( item );
			
			return frames;
		}

		private function compareData( b1 : BitmapData, b2 : BitmapData ) : Boolean
		{
			if ( b1.width != b2.width || b1.height != b2.height )
			{
				return false;
			}
			var data : * = b1.compare( b2 );
			if ( data is Number && data == 0 )
			{
				return true;
			}
			return false;
		}
		
		private function padWithZeros( value : int, places : int ) : String
		{
			var str : String = value.toString();
			while( str.length < places )
			{
				str = "0" + str;
			}
			return str;
		}
		
		private function scaleRect( rect : Rectangle, scale : Number ) : Rectangle
		{
			rect.x *= scale;
			rect.y *= scale;
			rect.width *= scale;
			rect.height *= scale;
			return rect;
		}
		
		private function roundOutRect( rect : Rectangle ) : Rectangle
		{
			var bx : Number = Math.floor( rect.left );
			var by : Number = Math.floor( rect.top );
			var bw : Number = Math.ceil( rect.right ) - bx;
			var bh : Number = Math.ceil( rect.bottom ) - by;
			rect.setTo( bx, by, bw, bh );
			return rect;
		}
	}
}
