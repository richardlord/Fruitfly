package 
net.richardlord.fruitfly.example{
	import starling.core.Starling;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;

	[SWF(width='650', height='400', frameRate='30', backgroundColor='#999999')]

	public class Main extends Sprite
	{
		private var starling : Starling;
		
		public function Main()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.quality = StageQuality.LOW;

			addEventListener( Event.ENTER_FRAME, create );
		}
		
		private function create( event : Event ) : void
		{
			removeEventListener( Event.ENTER_FRAME, create );
			
			starling = new Starling( App, stage );
			starling.antiAliasing = 1;
			starling.start();
		}
	}
}
