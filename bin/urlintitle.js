function urlintitle() {
	if(! document.title.includes(document.URL)) {
		document.title += " " + document.URL;
	}
}

urlintitle();

var target = document.querySelector('title');
var observer = new MutationObserver(function(mutations) {
	mutations.forEach(function(mutation) {
		console.log('title changed to "%s"', document.title);
		urlintitle();
	});
});
var config = {
	childList: true,
};
observer.observe(target, config);
