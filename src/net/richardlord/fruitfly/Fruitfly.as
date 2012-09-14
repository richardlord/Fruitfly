package net.richardlord.fruitfly
{
	import net.richardlord.signals.Signal0;

	import starling.display.Button;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.PNGEncoderOptions;
	import flash.display.SimpleButton;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	/**
	 * A FruitFly instance converts Flash display assets to Starling display assets.
	 * Optionally, it will store the results in local file storage and load them
	 * from storage next time for efficiency.
	 * 
	 * All textures are stored in texture atlases for efficiency. Where neccessary,
	 * multiple texture atlases will be used.
	 * 
	 * Each FruitFly instance is given a name. This name is used when storing and
	 * reloading the Starling assets.
	 */
	public class Fruitfly
	{
		private static const defaultStorageDirectory : String = "fruitfly";
		
		private var _name : String;
		
		private var flashDisplayObjects : Object = {};
		private var flashButtons : Object = {};
		private var flashMovieClips : Object = {};
		
		private var starlingImages : Object = {};
		private var starlingButtons : Object = {};
		private var starlingMovieClips : Object = {};
		
		private var collection : TextureAtlasCollection;
		private var imageLoaders : Vector.<ImageLoader> = new Vector.<ImageLoader>();
		private var imageLoadersToComplete : int = 0;
		
		private var path : File;
		private var master : XML;
		private var atlas : MultiAtlas;
		
		/**
		 * Signal dispatched when assets are successfully loaded from the local storage cache.
		 * The assets are ready to use when this signal is dispatched.
		 */
		public var loadComplete : Signal0 = new Signal0();
		/**
		 * Signal dispatched when assets fail to be loaded from the local storage cache. You
		 * should create the assets from the original Flash assets instead.
		 */
		public var loadFailed : Signal0 = new Signal0();
		/**
		 * Indicates whether mip-map textures should be created or not. The default is false.
		 */
		public var generateMipMaps : Boolean;
		
		/**
		 * Constructor.
		 * 
		 * @param name The name of this FruitFly is used to identify this FruitFly's assets
		 * when storing the Starling assets in the local storage cache and when reloading
		 * them from that cache.
		 */
		public function Fruitfly( name : String )
		{
			_name = name;
		}
		
		/**
		 * This FruitFly's name.
		 */
		public function get name() : String
		{
			return _name;
		}

		/**
		 * Attempt to load the assets from the local storage cache. If the load succeeds, the
		 * loadComplete signal will be dispatched. If the load fails the loadFailed signal
		 * will be dispatched.
		 * 
		 * @param path The path to the local storage cache. Only required if you want to
		 * override the default storage location.
		 */
		public function loadFromCache( path : File = null ) : void
		{
			if( !path )
			{
				path = File.applicationStorageDirectory.resolvePath( defaultStorageDirectory );
			}
			this.path = path;
			var stream : FileStream;
			var file : File;
			var masterName : String = _name + ".xml";
			file = path.resolvePath( masterName );
			if( !file.exists )
			{
				loadFailed.dispatch();
				return;
			}
			stream = new FileStream();
			stream.open( file, FileMode.READ );
			master = XML( stream.readUTFBytes( file.size ) );
			atlas = new MultiAtlas();
			for each( var mapNode : XML in master.atlases.map )
			{
				var mapName : String = mapNode.@name.toString();
				file = path.resolvePath( mapName );
				if( ! file.exists )
				{
					loadFailed.dispatch();
					return;
				}
				
				file = path.resolvePath( mapNode.@image.toString() );
				if( ! file.exists )
				{
					cleanUpLoaders();
					loadFailed.dispatch();
					return;
				}
				var loader : ImageLoader = new ImageLoader( mapName );
				loader.complete.add( loaderComplete );
				loader.failed.add( loaderFailed );
				imageLoaders.push( loader );
				imageLoadersToComplete ++;
				loader.load( file.url );
			}
		}
		
		private function loaderComplete( mapName : String, data : BitmapData ) : void
		{
			var file : File = path.resolvePath( mapName );
			if( ! file.exists )
			{
				cleanUpLoaders();
				loadFailed.dispatch();
				return;
			}
			var stream : FileStream = new FileStream();
			stream.open( file, FileMode.READ );
			var map : XML = XML( stream.readUTFBytes( file.size ) );
			atlas.addAtlas( new TextureAtlas( Texture.fromBitmapData( data, generateMipMaps ), map ) );
			imageLoadersToComplete --;
			if( imageLoadersToComplete == 0 )
			{
				finishLoad();
			}
		}
		
		private function finishLoad() : void
		{
			cleanUpLoaders();
			
			var node : XML;
			var name : String;
			var texture : Texture;
			for each( node in master.assets.Image )
			{
				name = node.@name.toString();
				texture = atlas.getTexture( name );
				if( !texture )
				{
					loadFailed.dispatch();
					return;
				}
				var image : Image = new Image( texture );
				image.pivotX = parseInt( node.@pivotX.toString() );
				image.pivotY = parseInt( node.@pivotY.toString() );
				starlingImages[ name ] = image;
			}
			for each( node in master.assets.MovieClip )
			{
				name = node.@name.toString();
				var fps : Number = parseFloat( node.@fps.toString() );
				var clip : starling.display.MovieClip;
				var i : int = 0;
				for each( var frame : XML in node.frame )
				{
					texture = atlas.getTexture( frame.@name.toString() );
					var duration : Number = parseFloat( frame.@duration.toString() );
					if( !texture )
					{
						loadFailed.dispatch();
						return;
					}
					if( i == 0 )
					{
						clip = new starling.display.MovieClip( new <Texture>[ texture ], fps );
						clip.setFrameDuration( 0, duration );
						clip.pivotX = parseInt( node.@pivotX.toString() );
						clip.pivotY = parseInt( node.@pivotY.toString() );
					}
					else
					{
						clip.addFrameAt( i, texture, null, duration );
					}
					++i;
				}
				starlingMovieClips[ name ] = clip;
			}
			loadComplete.dispatch();
		}
		
		private function loaderFailed( id : String ) : void
		{
			cleanUpLoaders();
			loadFailed.dispatch();
		}
		
		private function cleanUpLoaders() : void
		{
			for each( var loader : ImageLoader in imageLoaders )
			{
				loader.complete.remove( loaderComplete );
				loader.failed.remove( loaderFailed );
			}
			imageLoaders.length = 0;
			path = null;
		}
		
		/**
		 * Save the assets to the local storage cache. Used after creating the Starling assets
		 * from the original Flash assets so they can be loaded from the cache next time rather
		 * than creating them from scratch every time.
		 * 
		 * @param path The path to the local storage cache. Only required if you want to
		 * override the default storage location.
		 */
		public function saveToCache( path : File = null ) : void
		{
			if( !path )
			{
				path = File.applicationStorageDirectory.resolvePath( defaultStorageDirectory );
			}
			var master : XML = <TextureAtlasCollection><assets/><atlases/></TextureAtlasCollection>;
			var name : String;
			for( name in starlingImages )
			{
				var image : Image = starlingImages[name];
				master.assets.appendChild( <Image name={name} pivotX={image.pivotX} pivotY={image.pivotY}/> );
			}
			for( name in starlingMovieClips )
			{
				var clip : starling.display.MovieClip = starlingMovieClips[name];
				var clipXml : XML = <MovieClip name={name} pivotX={clip.pivotX} pivotY={clip.pivotY} fps={clip.fps}/>;
				var frames : Vector.<TextureAtlasItem> = flashMovieClips[name].frames;
				for each( var frame : TextureAtlasItem in frames )
				{
					clipXml.appendChild( <frame name={frame.name} duration={frame.duration}/> );
				}
				master.assets.appendChild( clipXml );
			}
			
			var stream : FileStream;
			var file : File;
			for( var i : int = 0; i < collection.textureNodes.length; ++i )
			{
				var node : TextureNode = collection.textureNodes[i];
				var png : ByteArray = node.bitmap.encode( node.bitmap.rect, new PNGEncoderOptions( true ) );
				var bmpName : String = _name + "_" + i + ".png";
				file = path.resolvePath( bmpName );
				if( file.exists )
				{
					file.deleteFile();
				}
				stream = new FileStream();
				stream.open( file, FileMode.WRITE );
				stream.writeBytes( png );
				node.map.@imagePath = bmpName;
				
				var xmlName : String = _name + "_" + i + ".xml";
				file = path.resolvePath( xmlName );
				if( file.exists )
				{
					file.deleteFile();
				}
				stream = new FileStream();
				stream.open( file, FileMode.WRITE );
				stream.writeUTFBytes( node.map.toXMLString() );
				
				master.atlases.appendChild( <map name={xmlName} image={bmpName}/> );
			}
			var masterName : String = _name + ".xml";
			file = path.resolvePath( masterName );
			if( file.exists )
			{
				file.deleteFile();
			}
			stream = new FileStream();
			stream.open( file, FileMode.WRITE );
			stream.writeUTFBytes( master.toXMLString() );
		}
		
		/**
		 * Get a Starling Image object. This will have been created from a static Flash DisplayObject.
		 * 
		 * @param name The name of the Image.
		 */
		public function getImage( name : String ) : Image
		{
			return starlingImages[ name ];
		}

		/**
		 * Get a Starling Button object. This will have been created from a Flash SimpleButton.
		 * 
		 * @param name The name of the Button.
		 */
		public function getButton( name : String ) : Button
		{
			return starlingButtons[ name ];
		}

		/**
		 * Get a Starling MovieClip object. This will have been created from a Flash MovieClip.
		 * 
		 * @param name The name of the MovieClip.
		 */
		public function getMovieClip( name : String ) : starling.display.MovieClip
		{
			return starlingMovieClips[ name ];
		}
		
		/**
		 * Add a Flash DisplayObject to this FruitFly. This will be converted to a Starling Image object.
		 * 
		 * @param name The name of the resulting Starling Image object.
		 * @param obj The Flash DisplayObject to add.
		 * @param scale The scale factor to use when creating the Starling Image object. The default is 1.
		 */
		public function addDisplayObject( name : String, obj : DisplayObject, scale : Number = 1 ) : void
		{
			if( flashDisplayObjects[name] )
			{
				throw new Error( "An object with that name already exists - " + name );
			}
			flashDisplayObjects[name] = new FlashDisplayObject( obj, scale );
		}
		
		/**
		 * Add a Flash SimpleButton to this FruitFly. This will be converted to a Starling Button object.
		 * 
		 * @param name The name of the resulting Starling Button object.
		 * @param obj The Flash SimpleButton to add.
		 * @param scale The scale factor to use when creating the Starling Button object. The default is 1.
		 */
		public function addButton( name : String, button : SimpleButton, scale : Number = 1 ) : void
		{
			if( flashButtons[name] )
			{
				throw new Error( "An object with that name already exists - " + name );
			}
			flashButtons[name] = new FlashButton( button, scale );
		}
		
		/**
		 * Add a Flash MovieClip to this FruitFly. This will be converted to a Starling MovieClip object.
		 * 
		 * @param name The name of the resulting Starling MovieClip object.
		 * @param obj The Flash MovieClip to add.
		 * @param fps The frame-rate of the MovieClip.
		 * @param scale The scale factor to use when creating the Starling MovieClip object. The default is 1.
		 */
		public function addMovieClip( name : String, clip : flash.display.MovieClip, fps : Number, scale : Number = 1 ) : void
		{
			if( flashMovieClips[name] )
			{
				throw new Error( "An object with that name already exists - " + name );
			}
			flashMovieClips[name] = new FlashMovieClip( clip, fps, scale );
		}

		/**
		 * Converts all the Flash assets that have been added to this FruitFly into Starling assets. This
		 * may take some time.
		 * 
		 * @param quality The quality to use when creating the atarling textures. A value from the StageQuality 
		 * class.
		 */
		public function generateStarlingAssets( quality : String ) : void
		{
			var creator : BitmapCreator = new BitmapCreator();
			collection = new TextureAtlasCollection();
			var frames : Vector.<TextureAtlasItem>;
			var frame : TextureAtlasItem;
			var other : TextureAtlasItem;
			var clip : FlashMovieClip;
			var obj : FlashDisplayObject;
			var btn : FlashButton;
			var name : String;
			for( name in flashMovieClips )
			{
				clip = flashMovieClips[ name ];
				clip.frames = frames = creator.convertClipToBitmaps( name, clip.clip, clip.fps, clip.scale, quality );
				for each( frame in frames )
				{
					collection.addItem( frame );
				}
			}
			for( name in flashDisplayObjects )
			{
				obj = flashDisplayObjects[ name ];
				obj.frame = creator.convertDisplayObjectToBitmap( name, obj.object, obj.scale, quality );
				collection.addItem( obj.frame );
			}
			for( name in flashButtons )
			{
				btn = flashButtons[ name ];
				var btnFrames : Vector.<TextureAtlasItem> = creator.convertButtonToBitmaps( name, btn.button, btn.scale, quality );
				btn.upFrame = btnFrames[0];
				collection.addItem( btn.upFrame );
				btn.downFrame = btnFrames[1];
				collection.addItem( btn.downFrame );
			}
			collection.generateAtlas( generateMipMaps );

			for( name in flashMovieClips )
			{
				frames = flashMovieClips[ name ].frames;
				if( frames.length > 0 )
				{
					frame = frames[0];
					var animation : starling.display.MovieClip = new starling.display.MovieClip( new <Texture>[frame.texture], clip.fps );
					animation.pivotX = frame.origin.x;
					animation.pivotY = frame.origin.y;
					animation.setFrameDuration( 0, frame.duration );
					for( var i : int = 1; i < frames.length; ++i )
					{
						frame = frames[i];
						animation.addFrameAt( i, frame.texture, null, frame.duration );
					}
					starlingMovieClips[ name ] = animation;
				}
				else
				{
					starlingMovieClips[ name ] = new starling.display.MovieClip( new <Texture>[Texture.empty()], clip.fps );
				}
			}
			for( name in flashDisplayObjects )
			{
				frame = flashDisplayObjects[ name ].frame;
				var image : Image = new Image( frame.texture );
				image.pivotX = frame.origin.x;
				image.pivotY = frame.origin.y;
				starlingImages[ name ] = image;
			}
			for( name in flashButtons )
			{
				frame = flashButtons[ name ].upFrame;
				other = flashButtons[ name ].downFrame;
				var button : Button = new Button( frame.texture, "", other.texture );
				button.pivotX = frame.origin.x;
				button.pivotY = frame.origin.y;
				starlingButtons[ name ] = button;
			}
		}
	}
}

