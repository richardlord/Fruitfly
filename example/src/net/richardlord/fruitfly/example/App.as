package 
net.richardlord.fruitfly.example
{
	import net.richardlord.fruitfly.Fruitfly;

	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;

	import flash.display.StageQuality;
	import flash.text.TextField;

	public class App extends Sprite
	{
		private var handler : Fruitfly;
		
		public function App()
		{
			addEventListener( Event.ADDED_TO_STAGE, start );
		}
		
		private function start( event : Event ) : void
		{
			displaySource();
			loadAndShow();
		}
		
		public function createFromSource() : void
		{
			handler = new Fruitfly( "test" );
			handler.addMovieClip( "runRight", new RunRight(), 30, 2 );
			handler.addMovieClip( "runLeft", new RunLeft(), 30, 2 );
			handler.addDisplayObject( "grass", new Grass(), 2 );
			handler.addButton( "play", new PlayBtn(), 1 );
			handler.generateStarlingAssets( StageQuality.BEST );
			handler.saveToCache();
			displayStarling( false );
		}
		
		public function loadAndShow() : void
		{
			handler = new Fruitfly( "test" );
			handler.loadComplete.add( loadComplete );
			handler.loadFailed.add( loadFailed );
			handler.loadFromCache();
		}
		
		private function loadFailed() : void
		{
			handler.loadComplete.remove( loadComplete );
			handler.loadFailed.remove( loadFailed );
			createFromSource();
		}
		
		private function loadComplete() : void
		{
			handler.loadComplete.remove( loadComplete );
			handler.loadFailed.remove( loadFailed );
			displayStarling( true );
		}
		
		private function displayStarling( loaded : Boolean ) : void
		{
			var runRight : MovieClip = handler.getMovieClip( "runRight" );
			runRight.x = 100;
			runRight.y = 200;
			addChild( runRight );
			Starling.juggler.add( runRight );
			
			var runLeft : MovieClip = handler.getMovieClip( "runLeft" );
			runLeft.x = 200;
			runLeft.y = 200;
			addChild( runLeft );
			Starling.juggler.add( runLeft );
			
			var grass : Image = handler.getImage( "grass" );
			grass.x = 300;
			grass.y = 200;
			addChild( grass );
			
			var playBtn : Button = handler.getButton( "play" );
			playBtn.x = 400;
			playBtn.y = 150;
			addChild( playBtn );
			
			var tf : TextField = new TextField();
			tf.text = loaded ? "Starling loaded" : "Starling created";
			tf.x = 500;
			tf.y = 150;
			Starling.current.nativeOverlay.addChild( tf );
		}
		
		private function displaySource() : void
		{
			var runRight : RunRight = new RunRight();
			runRight.scaleX = runRight.scaleY = 2;
			runRight.x = 100;
			runRight.y = 100;
			Starling.current.nativeOverlay.addChild( runRight );
			
			var runLeft : RunLeft = new RunLeft();
			runLeft.scaleX = runLeft.scaleY = 2;
			runLeft.x = 200;
			runLeft.y = 100;
			Starling.current.nativeOverlay.addChild( runLeft );

			var grass : Grass = new Grass();
			grass.scaleX = grass.scaleY = 2;
			grass.x = 300;
			grass.y = 100;
			Starling.current.nativeOverlay.addChild( grass );

			var play : PlayBtn = new PlayBtn();
			play.scaleX = play.scaleY = 1;
			play.x = 400;
			play.y = 50;
			Starling.current.nativeOverlay.addChild( play );
			
			var tf : TextField = new TextField();
			tf.text = "Flash original";
			tf.x = 500;
			tf.y = 50;
			Starling.current.nativeOverlay.addChild( tf );
		}
	}
}
