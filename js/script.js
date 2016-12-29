var w = 0, 
	h = 0;
var grid = 5;
var cells = [];
var cellDim = 0;
var state = [];
var speed = 250;
var pause = false;
var startup = true;
window.onload = init;
setTimeout(fetch, speed);

function fetch() {
	//console.log("request sent");
	$.ajax({
	  type: "POST",
	  data: "state="+document.getElementById('state').innerHTML,
	  url: "http://127.0.0.1:8000/game",
	  success: function(data){
	  	document.getElementById('state').innerHTML = data;
	  	updateState();
	  	if(!pause)
		  	setTimeout(fetch, speed);
	  }
	});
}


function init(){
	console.log("Start");
	var svg = d3.selectAll("svg");
	w = window.innerWidth*0.9;
	h = window.innerHeight*0.9;
	svg.attr("width",w);
	svg.attr("height",h);
	cellDim = Math.min(w/grid, h/grid);
	svg.selectAll("rect").remove();
	cells = [];
	for(var i = 0; i<grid; i++){
		for(var j = 0; j<grid; j++){	
			var r = svg.append("rect");			
			r.attr("width", cellDim*0.9);
			r.attr("height", cellDim*0.9);
			r.attr("fill", "black");
			r.attr("x", j*cellDim);
			r.attr("y", i*cellDim);
			r.attr("id", j+i*grid);
			r.on("mouseover", toggleState);
			cells.push(r);
		}
	}
	if(startup){
		getState();
		updateState();
	}
	else{
		state = [];
		while(grid*grid>state.length)
			state.push(0);
		while(grid*grid<state.length)
			state.pop();
		console.log(state);
		updateStateStr();
		updateState();
	}
	startup = false;
}

function toggleState(){
	var elem = d3.select(this);
	id = elem.attr("id");
	if (elem.style("opacity")==1)
		elem.style("opacity", 0.25);
	else
		elem.style("opacity", 1);
	state[Number(id)] = Math.floor(elem.style("opacity"));
	updateStateStr();
}

function updateState(){
	getState();
	console.log(state);
	console.log(cells.length);
	for(var i = 0; i<state.length; i++){
		if(Number(state[i])==1)
			cells[i].style("opacity", 1);
		else
			cells[i].style("opacity", 0.25);
	}
}

function getState(){
	var stateStr = document.getElementById('state').innerHTML;
	state = stateStr.substring(1,stateStr.length-1).split(',');
	state.pop();
	//console.log(state);
}

function updateStateStr(){
	var stateStr = "["+grid+","+state.join(',')+"]";
	//console.log(stateStr);
	document.getElementById('state').innerHTML = stateStr;
}

