function changeSpeed(delta){
	speed+=delta;
	speed = Math.max(50, speed);
	console.log(speed);
}

function togglePause(){
	pause = !pause;
	if(!pause){
		setTimeout(fetch, speed);
		document.getElementById('pausebtn').innerHTML = "Pause";
	}
	else{
		document.getElementById('pausebtn').innerHTML = "Resume";
	}
}

function changeGrid(delta){
	grid+=delta;
	init();
}