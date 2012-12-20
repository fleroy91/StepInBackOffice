function showWaiting() {
	$('.ajax-loader').show();
	$('#chart_container').hide();
	$('#chart_container_2').hide();
}
function hideWaiting() {
	$('.ajax-loader').hide();
	$('#chart_container').show();
}
function showWaitingAndSubmit(form) {
	showWaiting();
	form.submit();
}
$('#apply-date').click(function() {
	showWaiting();
});
$(function() {
	var chart;
	$(document).ready(function() {
		console.log("In ready");
		showWaiting();
		$.get("/stats/compute.js");
	});
});