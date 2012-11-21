function showWaiting(id) {
	if(! id || id == 'all') {
		$('.ajax-loader').show();
		$('.content').hide();
	} else {
		$(id + ' .ajax-loader').show();
		$(id + ' .content').hide();
	}
}
function hideWaiting(id) {
	if(! id || id == 'all') {
		$('.ajax-loader').hide();
		$('.content').show();
	} else {
		$(id + ' .ajax-loader').hide();
		$(id + ' .content').show();
	}
}

function manageChangeDate(form) {
	var select = $('#home_predefined_dates').val();
	console.log("Select = " + select);
	if(select == 'custom') {
		$('#custom-dates').fadeIn();
	} else {
		$('#custom-dates').fadeOut();
		showWaiting();
		form.submit();
	}
}

$('#apply-date').click(function() {
	showWaiting();
});

$(function() {
	$(document).ready(function() {
		console.log("In ready home");
		showWaiting();
		$.get("/home/compute.js");
	});
});