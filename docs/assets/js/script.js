// Get the current year for the copyright notice
$("#year").text(new Date().getFullYear());

// Initalize scrollspy
$("body").scrollspy({
	target: ".navbar"
});

// Smooth scrolling for .navbar
$(".navbar a").on("click", function (event) {
	if (this.hash !== "") {
		event.preventDefault();
		const hash = this.hash;
		$("html, body").animate({
			scrollTop: $(hash).offset().top
		}, 800, function () {
			window.location.hash = hash;
		});
	}
});

// Smooth scrolling for #learnMore
$("#learnMore").on("click", function (event) {
	if (this.hash !== "") {
		event.preventDefault();
		const hash = this.hash;
		$("html, body").animate({
			scrollTop: $(hash).offset().top
		}, 800, function () {
			window.location.hash = hash;
		});
	}
});

// Close the responsive menu when a scroll trigger link is clicked
$(".js-scroll-trigger").click(function () {
	$(".navbar-collapse").collapse("hide");
});

// Change the navbar style
$(window).scroll(function () {
	// add .affix after scrolling down from the top
	if ($(document).scrollTop() > 100) {
		$(".navbar").addClass("affix");
	} else {
		$(".navbar").removeClass("affix");
	}
});

// Change the responsive menu style for small screen
$(".navbar-toggler").click(function () {
	// add .another-affix when showing the menu
	$(".navbar").on("show.bs.collapse", function () {
		$(".navbar").addClass("another-affix");
	});
	// remove .another-affix after hidden the menu
	$(".navbar").on("hidden.bs.collapse", function () {
		$(".navbar").removeClass("another-affix");
	});
});
