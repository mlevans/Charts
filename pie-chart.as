/*
In this example, we display five slices in a pie chart.
*/
package Charts
{	
	import flash.display.CapsStyle;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class PieChart extends Sprite
	{
		private var data:Array;
		private var sum:int;
		
		private var pieChartLines:Sprite;
		private var slices:Array = new Array(5);
		private var sliceColors:Array = [0x389cff, 0x5eafff, 0x85c2ff, 0xabd5ff, 0xd1e8ff]; //This is a successively desaturated blue.
		/*
		Sort the slices based on size; slices are positioned based on size to 
		improve readability of pie chart; see Dona Wong's Guide to Information Graphics.
		*/
		private var sortedSliceOrder:Array; 
		private var sliceDisplayOrder:Array = [0, 4, 3, 2, 1];
		
		private var sliceHighlighted:Array = new Array(5); //Slices of the piechart highlight upon mouseover; there is also dynamic text which accompanies the chart.
		
		//The dynamic text can be based on a slice's name and accompanying data, such as temporal data.
		private var pieText:TextField;
		private var sliceName:Array = ["Slice One", "Slice Two", "Slice Three", "Slice Four", "Slice Five"]; //Drawing five slices in this example

		
		public var displayed:Boolean = false;
		
		public function PieChart(data:Array)
		{	
			//We pass in an array of data.  In this example, the data array contains five elements.
			//It also needs to work with the sorting method, compareValues().  To do so, the array should be a collection of numbers.
			//Otherwise, the compareValues method (found below) would need to be changed.

			this.data = data;
			
			reset();
			
			pieChartLines = new Sprite;
			pieChartLines.mouseEnabled = pieChartLines.useHandCursor = pieChartLines.buttonMode = false;
			
			pieText = new TextField();
			pieText.defaultTextFormat = new TextFormat('_Sans', 17, 0xEEEEEE, true);
			//Set pieText.x and pieText.y here
			
			var i:int;
			
			for(i=0; i<5; i++){
				sliceHighlighted[i] = false;
				slices[i] = new Sprite();
				slices[i].mouseEnabled = slices[i].useHandCursor = slices[i].buttonMode = true;
				addChild(slices[i]);
				
				slices[i].addEventListener(MouseEvent.MOUSE_OVER, pieHighlight, false, 0, true);
				slices[i].addEventListener(MouseEvent.MOUSE_OUT, pieUnhighlight, false, 0, true);
			}
			addChild(pieChartLines);
		}
		
		public function reset():void{
			this.graphics.clear(); //Very critical for perforrmance
		}
		
		private function compareValues(a:Number, b:Number):Number{
			if (a > b){
				return - 1;
			} else if (a < b) {
				return 1;
			} else {
				return 0;
			}
		}
		
		public function update():void{	
			var i:int;
			var j:int;
			var angle:Number = 90.0;
			var arc:Number;
			var sliceColor:int;
			
			pieChartLines.graphics.clear();
			
			sum = 0;
			//Looping through the data to sum up all of the data; we need to know the proportion of each slice to the whole pie
			for (i = 0; i < data.length; i++){
				sum += data[i];
			}
			
			sortedSliceOrder = data.sort(compareValues, Array.RETURNINDEXEDARRAY);
			
			for(i = 0; i < 5; i++){
				
				j = sliceDisplayOrder[i];
				
				if (data[sortedSliceOrder[j]] <= 0) {
					continue;
				}
				
				arc = -(data[sortedSliceOrder[j]] / (sum)) * 360;
				slices[j].graphics.clear();
				
				if (sliceHighlighted[j]){
            		sliceColor = 0xFFFFFF;
    			} else {
    				sliceColor = sliceColors[j];
    			}
				drawSliceFill(angle, arc, sliceColor, 1, slices[j]);
				angle = angle + arc;
			}
			
			angle = 90.0;
			
			for(i = 0; i < 5; i++){
				
				j = sliceDisplayOrder[i];
				
				if (data[sortedSliceOrder[j]] <= 0) {
					continue;
				}
				
				arc = -(data[sortedSliceOrder[j]] / (sum)) * 360;
				drawSliceLine(angle, arc, sliceColors[j]);
				angle = angle + arc;
			}
			
		}
		
		private function drawSliceFill(startAngle:Number, arc:Number, sliceColor:int, slice:Sprite):void{
            
            var segments:int;
            var segmentAngle:Number;
            var theta:Number;
            var angle:Number;
            var midAngle:Number;
            var ax:Number;
            var ay:Number;
            var bx:Number;
            var by:Number;
            var cx:Number;
            var cy:Number;
            
            var radius:Number = 43;
            
            segments = Math.ceil(Math.abs(arc) / 45);
            segmentAngle = arc / segments;
            theta = -(segmentAngle / 180) * Math.PI;
            
            angle = -(startAngle / 180) * Math.PI;
            
            if (segments > 0) {
            	ax = Math.cos((startAngle / 180)*Math.PI)*radius;
            	ay = Math.sin((-startAngle / 180) * Math.PI) * radius;
            	
            	slice.graphics.beginFill(sliceColor, alpha);
            	slice.graphics.moveTo(0,0);
            	slice.graphics.lineStyle(1, sliceColor, 0);
            	slice.graphics.lineTo(ax, ay);
            	
            	slice.graphics.lineStyle(1, sliceColor, 0);
            	var i:int;
            	
            	for(i = 0; i<segments; i++) {
            		angle += theta;
            		midAngle = angle - (.5 * theta);
            		bx = Math.cos(angle) * radius;
            		by = Math.sin(angle) * radius;
            		cx = Math.cos(midAngle) * (radius / Math.cos(.5 * theta));
            		cy = Math.sin(midAngle) * (radius / Math.cos(.5 * theta));
            		slice.graphics.curveTo(cx, cy, bx, by);
            	}
            	slice.graphics.lineStyle(1, sliceColor, 0);
            	slice.graphics.lineTo(0,0);
            	slice.graphics.endFill();
            	
            	//trace(ax, ay);
            	//trace(bx, by);
            }
		}
		
		private function drawSliceLine(startAngle:Number, arc:Number, sliceColor:int):void{
			var endAngle:Number;
            var ax:Number;
            var ay:Number;

            var radius:Number = 43; //A sample radius
            
            if (arc > 0 || arc < 0) {
            	ax = Math.cos((startAngle / 180)*Math.PI)*radius;
            	ay = Math.sin((-startAngle / 180) * Math.PI) * radius;
            	pieChartLines.graphics.moveTo(0,0);
            	pieChartLines.graphics.lineStyle(1, 0xFFFFFF, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE);
            	pieChartLines.graphics.lineTo(ax, ay);

            	endAngle = startAngle + arc;
            	ax = Math.cos((endAngle / 180)*Math.PI)*radius;
            	ay = Math.sin((-endAngle / 180) * Math.PI) * radius;
            	pieChartLines.graphics.moveTo(0,0);
            	pieChartLines.graphics.lineTo(ax,ay);
            }
		}
		
		private function pieHighlight(event:MouseEvent):void{
			var i:int;
			var j:int;
			var slice:Sprite = event.target as Sprite;
			
			for(i=0; i < 5; i++){
				if (slice == slices[i]){
					sliceHighlighted[i] = true;
					update();
					j = sortedSliceOrder[i];
					//A general sample of a text snippet explaining each pie slice
					pieText.text = sliceName[j] + ' ' + Number(100*(data[j] / (sum))).toFixed(2) + '%' + ' or ' + data[j] + ' Total Cases';
					pieText.width = pieText.textWidth + 120;
					return;
				}
			}
		}
		
		private function pieUnhighlight(event:MouseEvent):void{
			var i:int;
			var slice:Sprite = event.target as Sprite;
			
			var n:int = sum;
			
			for(i=0; i < 5; i++){
				if(slice == slices[i]){
					sliceHighlighted[i] = false;
					update();
					
					if (n >= 1000){
						pieText.text = 'General Pie Chart Description' + ' ' + 
						Math.floor(n/1000) + ',' + totalCasesCompletion(n%1000) + ' Total Cases';
					} else {
						pieText.text ='General Pie Chart Description' + ' ' + n + ' Total Cases';
					}
					
					return;
				}
			}
		}
		
		private function totalCasesCompletion(n:int):String{
			var h:int; //hundreds
			var t:int; //tens
			var o:int; //ones
			
			h = n/100;
			t = (n - h*100)/10;
			o = n - h*100 - t*10;
			
			return (String(h) + String (t) + String(o));
		}
		
		//Methods for changing visibility of the pie chart
		public function pieChartVisible():void{
			displayed = true;
			update();
		}
		
		public function pieChartInvisible():void{
			displayed = false;
		}

	}
}