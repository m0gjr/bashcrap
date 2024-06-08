let title=document.title+" "+document.URL;

for(let i=0; i<5; i++){
	setTimeout(function() {
		document.title=title;
	}, 1000*i);
}
