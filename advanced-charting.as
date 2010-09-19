//This will be an evolution of an advanced charting component in ActionScript 3.0 
//(similar to charting components found on Google Finance).

package Charts
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	//import flash.display.StageAlign;
	//import flash.display.StageScaleMode;
	
	//[SWF(width="400", height="400", backgroundColor="#050505", frameRate="30")]
	public class AdvancedCharting extends Sprite
	{
		private var urlLoader:URLLoader;
		
		private var base:Sprite;
		private var channel:Sprite;
		//middle Control
		private var middleControl:Sprite;
		private var midWidth:Number;
		private var middleControlDeltaX:Number;
		
		private var leftControl:Sprite;
		private var rightControl:Sprite;
		
		private var startGraph:int = 100;
		private var endGraph:int = 200;
		
		//data arrays
		private var intensities:Array = new Array();
		private var timeStamps:Array = new Array();
		
		private var line:Sprite;
		
		private var intensity:TextField;
		private var intensityTextFormat:TextFormat;
		
		//Colors
		private var graphFill:uint = 0xEdF7FF;
		private var lineColor:uint = 0x3B8AE5;
		
		//setting range
		private var numberOfDaysToDisplay:int = 1000;
		private var start:int;
		private var end:int;
		
		//time stamp
		//Could use AS3's Date Class; each timeStamp would have to be a Number instead of an int; this
		//make the application more processor intensive than it needs to be
		private var cumulativeNumberOfDays:Array = [0, 365, 731, 1096, 1491, 1826, 2192, 2557, 2922, 3287, 3653, 4018, 4383, 4748, 5114, 5479,
													5844, 6209]; //ends at January 1st, 2012											
		private var cumulativeNumberOfDaysInRegYear:Array = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334];		
		private var cumulativeNumberOfDaysInLeapYear:Array = [0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335];
		
		private var month:int;
		private var day:int;
		private var year:int;
		
		public function AdvancedCharting()
		{
			//IN PROGRESS: Line charts in AS3; focused on charting data, separated by days, since 1995
			
			//switch between dynamic and static? or just do dynamic?
			
			//generalize variables and expressions
			
			//tweening transitions; easein and easeout
			
			base = new Sprite();
			base.graphics.beginFill(0xFFFFFF,1);
			base.graphics.drawRect(90,100,120,-80);
			base.graphics.endFill();
			addChild(base);
			
			channel = new Sprite();
			channel.graphics.beginFill(0xFF0000,1);
			channel.graphics.drawRect(0,110,100,-10);
			channel.graphics.endFill();
			channel.x = startGraph;
			addChild(channel);
			
			
			//addChild to channel?
			middleControl = new Sprite();
			middleControl.buttonMode = middleControl.useHandCursor = true;
			channel.addChild(middleControl);
			
			leftControl = new Sprite();
			leftControl.buttonMode = leftControl.useHandCursor = true;
			leftControl.graphics.beginFill(0x00FF00,1);
			leftControl.graphics.drawRect(startGraph - 10,110,10,-10);
			leftControl.graphics.endFill();
			addChild(leftControl);
			
			rightControl = new Sprite();
			rightControl.buttonMode = rightControl.useHandCursor = true;
			rightControl.graphics.beginFill(0x00FF00,1);
			rightControl.graphics.drawRect(endGraph,110,10,-10);
			rightControl.graphics.endFill();
			addChild(rightControl);
			
			line = new Sprite();
			base.addChild(line);
			
			intensity = new TextField();
			intensityTextFormat = new TextFormat('_sans',10,0x000000);
			intensity.defaultTextFormat = intensityTextFormat;
			intensity.height = 20;
			intensity.y = 5;
			addChild(intensity);
			
			//add mouse event listeners for controls
			leftControl.addEventListener(MouseEvent.MOUSE_OVER, leftControlOverHandler,false,0,true);
			leftControl.addEventListener(MouseEvent.MOUSE_DOWN, leftControlDownHandler,false,0,true);
			leftControl.addEventListener(MouseEvent.MOUSE_UP, leftControlUpHandler,false,0,true);
			leftControl.addEventListener(MouseEvent.MOUSE_OUT, leftControlOutHandler,false,0,true);
			
			rightControl.addEventListener(MouseEvent.MOUSE_OVER, rightControlOverHandler,false,0,true);
			rightControl.addEventListener(MouseEvent.MOUSE_DOWN, rightControlDownHandler,false,0,true);
			rightControl.addEventListener(MouseEvent.MOUSE_UP, rightControlUpHandler,false,0,true);
			rightControl.addEventListener(MouseEvent.MOUSE_OUT, rightControlOutHandler,false,0,true);
			
			channel.addEventListener(MouseEvent.MOUSE_DOWN, channelDownHandler,false,0,true);
			
			middleControl.addEventListener(MouseEvent.MOUSE_OVER, middleOverHandler, false, 0, true);
			middleControl.addEventListener(MouseEvent.MOUSE_OUT, middleOutHandler, false, 0, true);
			middleControl.addEventListener(MouseEvent.MOUSE_DOWN, middleOnClick, false, 0, true);
			
			
			//Loading Data
			var urlRequest:URLRequest = new URLRequest('data/SampleData.xml');
			urlLoader = new URLLoader();
			urlLoader.load(urlRequest);
			urlLoader.addEventListener(Event.COMPLETE, processData, false, 0, true);
		}
		
		public function processData(e:Event):void{
			var xml:XML = new XML(e.target.data); //e.target is the url loader, the object that loaded the XML file
			//data is the data received from the load operation
			
			var a:*; // a has no type; between the blocks
			
			for each(a in xml.instance){
				intensities.push(int(a.intensity));
				
				month = int(a.month);
				day = int(a.day);
				year = int(a.year);
				
				timeStamps.push(getTimeStamp(month,day,year));
			}
			
			//setting range
			end = timeStamps[timeStamps.length - 1]; //could use date class or php
			start = end - numberOfDaysToDisplay + 1;
			
			initGraph();
		}
		
		public function initGraph():void{
			midWidth = Math.round((numberOfDaysToDisplay/(timeStamps[timeStamps.length-1] - timeStamps[0] + 1)) * channel.width);
			
			
			middleControl.graphics.beginFill(0x0000FF,1);
			middleControl.graphics.drawRect(0,110,midWidth,-10);
			middleControl.graphics.endFill();
			middleControl.x = Math.round((start/(timeStamps[timeStamps.length -1] - numberOfDaysToDisplay + 1)) * (channel.width-midWidth));
			
			drawGraph();
		}
		
		public function drawGraph():void{
			//channel starts at 100, and is 100 in width
			//var start:int = 15;
			var range:int = .5*(endGraph - startGraph);  //--> stop at 200 --> 100 +2*i = 200 --> .5*(endGraph - startGraph) --> 
													    //i = .5(channelwidth + channel.x - start.x)
			
			intensity.x = 180;
			//intensity.text = String(intensities[start - 1 + range-1]); //adjust for the array
			intensity.text = String(start);
			
			line.graphics.beginFill(graphFill,.9);
			//line.graphics.lineStyle(0,graphFill,0);
			line.graphics.moveTo(100,100);
			//line.graphics.lineTo(100,100-intensities[start]);
			line.graphics.lineStyle(1,lineColor,1,false,"none");
			
			/*
			discrete:
			for(i=1; i < range; i++){ //used to go to intensities.length
				line.graphics.lineTo(100+2*i,100-intensities[start-1+i]); //vs. 6i
			}
			*/
			var position:Number;
			var i:int;
			var j:int;
			
			for (i=0; i < timeStamps.length; i++){
				if (timeStamps[i] >= start){
					line.graphics.lineStyle(0,graphFill,0);
					line.graphics.lineTo(100,100-intensities[i]);
					line.graphics.lineStyle(1,lineColor,1,false,"none");
					break; //breaks out of the for loop
				}
			}
			
			for (i++; i < timeStamps.length; i++){
				if (timeStamps[i] >= start && timeStamps[i] <= end){
					//mapping the day to x
					position = (timeStamps[i] - start)/(end - start) * range;
					line.graphics.lineTo(100+2*position,100-intensities[i]); //vs. 6i
					j = i; //possibility of i still getting incremented outside of the if
				}
				if (timeStamps[i] > end){
					break; //out of the for loop
				}
			}
			
			if (Math.round(100+2*position) < endGraph){
				line.graphics.lineTo(endGraph,100-intensities[j+1]);
			}
			
			line.graphics.lineStyle(0,graphFill,0);
			line.graphics.lineTo(100+2*range,100);
			line.graphics.endFill();
		}
		
		public function leftControlOverHandler(event:MouseEvent):void{
			leftControl.alpha = .8;
		}
		
		public function leftControlDownHandler(event:MouseEvent):void{
			leftControl.alpha = .3;
			
			leftControl.addEventListener(Event.ENTER_FRAME, continuousDown, false,0,true);
		}
		
		public function continuousDown(event:Event):void{		
			line.graphics.clear();
			if (event.target == leftControl){
				start = start - 10;
			
				if (start <= timeStamps[0]){
					start = timeStamps[0];
				}
			
				end = start + numberOfDaysToDisplay - 1;
			
				if(middleControl.x > 0){
					//**
					middleControl.x = Math.round((channel.width-midWidth)*(start - timeStamps[0])/(timeStamps[timeStamps.length-1] - numberOfDaysToDisplay + 1
					- timeStamps[0]));
					//middleControl.x = Math.round((start/(days[days.length -1] - numberOfDaysToDisplay + 1)) * (channel.width-midWidth)) - 1;
					//middleControl.x = middleControl.x - 1;
				}
				drawGraph();
			}
			
			if (event.target == rightControl){
				end = end + 10;
				if (end >= timeStamps[timeStamps.length - 1]){
					end = timeStamps[timeStamps.length - 1];
				}
				start = end - numberOfDaysToDisplay + 1;
			
				if(middleControl.x < channel.width - midWidth){
					//*
					middleControl.x = Math.round((channel.width-midWidth)*(start - timeStamps[0])/(timeStamps[timeStamps.length-1] - numberOfDaysToDisplay + 1
					- timeStamps[0]));
					//middleControl.x = Math.round((start/(days[days.length -1] - numberOfDaysToDisplay + 1)) * (channel.width-midWidth)) - 1;
					//middleControl.x = middleControl.x + 1;
				}
				drawGraph();
			}
		}
		
		public function leftControlUpHandler(event:MouseEvent):void{
			leftControl.alpha = .8;
			leftControl.removeEventListener(Event.ENTER_FRAME, continuousDown);
			/*						
			line.graphics.clear();
			
			start = start - 1;
			
			if (start <= 1){
				start = 1;
			}
			
			end = start + numberOfDaysToDisplay - 1;
			
			if(middleControl.x > 0){
				middleControl.x = Math.round((channel.width-midWidth)*(start -1)/(days[days.length-1] - numberOfDaysToDisplay));
				//middleControl.x = Math.round((start/(days[days.length -1] - numberOfDaysToDisplay + 1)) * (channel.width-midWidth)) - 1;
				//middleControl.x = middleControl.x - 1;
			}
			drawGraph();
			*/
		}
		
		public function leftControlOutHandler(event:MouseEvent):void{
			leftControl.alpha = 1;
		}
		
		public function rightControlOverHandler(event:MouseEvent):void{
			rightControl.alpha = .8;
		}
		
		public function rightControlDownHandler(event:MouseEvent):void{
			rightControl.alpha = .3;
			rightControl.addEventListener(Event.ENTER_FRAME, continuousDown, false,0,true);
		}
		
		public function rightControlUpHandler(event:MouseEvent):void{
			rightControl.removeEventListener(Event.ENTER_FRAME, continuousDown);			
			rightControl.alpha = .8;
			/*
			line.graphics.clear();
			
			end = end + 1;
			if (end >= days[days.length - 1]){
				end = days[days.length - 1];
			}
			start = end - numberOfDaysToDisplay + 1;
			
			if(middleControl.x < channel.width - midWidth){
				middleControl.x = Math.round((channel.width-midWidth)*(start -1)/(days[days.length-1] - numberOfDaysToDisplay));
				//middleControl.x = Math.round((start/(days[days.length -1] - numberOfDaysToDisplay + 1)) * (channel.width-midWidth)) - 1;
				//middleControl.x = middleControl.x + 1;
			}
			drawGraph();
			*/
		}
		
		public function rightControlOutHandler(event:MouseEvent):void{
			rightControl.alpha = 1;
		}
		
		public function channelDownHandler(event:MouseEvent):void{
			var x:int;
			
			if (channel.mouseX < middleControl.x){
				x = channel.mouseX;
			} else {
				x = channel.mouseX - midWidth;
			}
			
			if (x < 0){
				x = 0;
			} else if (x > channel.width - midWidth){
				x = channel.width - midWidth;
			}
			
			middleControl.x = x; //accessing slider.mouseX at two different times - onclick and dragging
			
			line.graphics.clear();
			
			start = Math.round((x/(channel.width-midWidth)) * (timeStamps[timeStamps.length - 1] - numberOfDaysToDisplay + 1 - timeStamps[0])) + timeStamps[0]; 
			end = start + numberOfDaysToDisplay - 1;
			
			drawGraph();
		}
		
		public function middleOverHandler(event:MouseEvent):void{
			middleControl.alpha = .4;
		}
		
		public function middleOutHandler(event:MouseEvent):void{
			middleControl.alpha = 1;
		}
		
		public function middleOnClick(event:MouseEvent):void{
			event.stopPropagation();
			//http://www.rubenswieringa.com/blog/eventbubbles-eventcancelable-and-eventcurrenttarget
			//http://livedocs.adobe.com/flex/201/langref/flash/events/Event.html#stopImmediatePropagation%28%29
			middleControlDeltaX = middleControl.x - channel.mouseX;
			
			stage.addEventListener(MouseEvent.MOUSE_UP, removeDraggingMiddleControl, false, 0, true);
			middleControl.addEventListener(MouseEvent.MOUSE_MOVE, draggingMiddleControl, false, 0, true);
			channel.addEventListener(MouseEvent.MOUSE_MOVE, draggingMiddleControl, false, 0, true);
		}
		
		public function draggingMiddleControl(event:MouseEvent):void{
			var x:int = channel.mouseX + middleControlDeltaX;
			
			if (x < 0){
				x = 0;
			} else if (x > channel.width - midWidth){
				x = channel.width - midWidth;
			}
			
			middleControl.x = x; //accessing slider.mouseX at two different times - onclick and dragging
			
			line.graphics.clear();
			
			if (channel.width == midWidth){
				start = timeStamps[0];
			} else{
				start = Math.round((x/(channel.width-midWidth)) * (timeStamps[timeStamps.length - 1] - numberOfDaysToDisplay + 1 - timeStamps[0])) + timeStamps[0];
			}
			//trace('start',start);
			end = start + numberOfDaysToDisplay - 1;
			
			drawGraph();
			
		}
		
		public function removeDraggingMiddleControl(event:MouseEvent):void{
			stage.removeEventListener(MouseEvent.MOUSE_UP, removeDraggingMiddleControl);
			middleControl.removeEventListener(MouseEvent.MOUSE_MOVE, draggingMiddleControl);
			channel.removeEventListener(MouseEvent.MOUSE_MOVE, draggingMiddleControl);
		}
		
		//Making My Own Date Method; this is for charts based on days; int vs. number
		
		private function getTimeStamp(month:int, day:int, year:int):int{
			//Number of Days since January 1st, 1995; getTimeStamp(1,1,1995) = 0;
			var timeStamp:int = cumulativeNumberOfDays[year-1995];
			
			if (year%4 == 0){
				timeStamp += cumulativeNumberOfDaysInLeapYear[month-1];
			} else {
				timeStamp += cumulativeNumberOfDaysInRegYear[month-1];
			}
			
			timeStamp += day - 1;
			
			return timeStamp;
		}

	}
}