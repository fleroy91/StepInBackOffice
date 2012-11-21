function showWaiting() {
	$('.ajax-loader').show();
	$('#container').hide();
}
function hideWaiting() {
	$('.ajax-loader').hide();
	$('#container').show();
}

function changeAndSubmit(form) {
	hideWaiting();
	form.submit();
}

// showWaiting();