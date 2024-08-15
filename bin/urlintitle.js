function urlintitle() {
	if(! document.title.includes(document.URL)) {
		console.log('title changed to "%s"', document.title);
		document.title += " " + document.URL;
	}
}

urlintitle();

var observer = new MutationObserver(function(mutations) {
	mutations.forEach(function(mutation) {
		urlintitle();
	});
});
observer.observe(document.querySelector('title'), {childList: true,});
