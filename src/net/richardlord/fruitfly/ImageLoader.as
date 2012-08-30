package net.richardlord.fruitfly
{
	import net.richardlord.signals.Signal1;
	import net.richardlord.signals.Signal2;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;

	public class ImageLoader
	{
		public var complete : Signal2 = new Signal2( String, BitmapData );
		public var failed : Signal1 = new Signal1( String );
		
		private var id : String;
		private var data : BitmapData;
		private var loader : Loader;
		
		public function ImageLoader( id : String )
		{
			this.id = id;
		}

		public function load( url : String ) : void
		{
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener( Event.COMPLETE, loadComplete );
			loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, loadFailed );
			loader.load( new URLRequest( url ) );
		}
		
		private function loadComplete( event : Event ) : void
		{
			loader.contentLoaderInfo.removeEventListener( Event.COMPLETE, loadComplete );
			loader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, loadFailed );
			if( loader.content && loader.content is Bitmap )
			{
				data = Bitmap( loader.content ).bitmapData;
				complete.dispatch( id, data );
			}
			else
			{
				failed.dispatch( id );
			}
		}
		
		private function loadFailed( event : Event ) : void
		{
			loader.contentLoaderInfo.removeEventListener( Event.COMPLETE, loadComplete );
			loader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, loadFailed );
			failed.dispatch( id );
		}
	}
}
