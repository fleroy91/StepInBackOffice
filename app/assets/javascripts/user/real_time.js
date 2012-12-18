function twoDigits(x) { 'use strict';
    var ret = x.toString();
    if(x < 10) {
        ret = "0" + ret;
    }
    return ret;
}

function formatDate(date) { 'use strict';
    var str = twoDigits(date.getDate()) + "/" + twoDigits(date.getMonth() + 1) + "/" + date.getFullYear() + 
        " à " + twoDigits(date.getHours()) + ":" + twoDigits(date.getMinutes());
    return str;
}
function update(no_fade) {
	var v = $("#now").text();
	console.log(now);
	var now = null;
	if(v) {
		now = new Date(Date.parse(v));
	}
	$.get("/real_time/update.json" + (now ? "?from=" + now.toISOString() : ""), function(array) {
		if(array && array.length > 0) {
			var el = $("table tbody");
			var max_time = null;
			$("table").remove("tr:gt(20)");
			// console.log("Body = " + el);
			function getHtml(array, index) {
				var html = null;
				if(index < array.length) {
					var obj = array[index];
					var rew = obj.reward;
					html = "<tr><td>"
					// console.log(rew);
					var badd = true ;
					if(rew.action_kind === 'stepin') {
						html += "<ul>";
						var user = null;
						if(rew.user) {
							var user = rew.user;
							if(user.entry) {
								user = user.entry;
							}
						}
						if(user && user.photo0) {
							html+='<img style="width:30px;height:30px;" src="' + user.photo0.photo0.m_url + '"/>  ';
						}
						html += "Step-In";
						if(user) {
							html += " de <strong>" + user.firstname + "</strong>";
						}
						html+= '</ul>'
					} else if(rew.action_kind === 'catalog') {
						// console.log("Catalog");
						// console.log(rew.catalog);
						html += "<ul>"
						if(rew.catalog) {
							html += "Vue du catalogue <strong>" + rew.catalog.entry.name + "</strong>"
						} else {
							html += "Vue d'un catalogue"
						}
						html += "</ul>"
					} else {
						console.log("Not added : ");
						console.log(rew);
						badd = false;
					}
					html+='</td>'

					if(badd) {
						var dwhen = new Date(Date.parse(rew.when));
						if(! max_time || max_time.getTime() < dwhen.getTime()) {
							max_time = dwhen;
						}
						html+= '<td>' + rew.shop.entry.name + '</td>';
						html+= '<td>' + formatDate(dwhen) + '</td>';
						html+='</tr>';
					} else {
						html = null;
					}
				}
				return html;
			}

			function addHtml(array, index) {
				var html = getHtml(array, index);
				if(html) {
					$(html).prependTo(el).hide().fadeIn("fast", function() { addHtml(array, index + 1);});
				}
			}

			if(no_fade) {
				var i;
				for(i = 0; i < array.length; i ++) {
					var html = getHtml(array, i);
					if(html) {
						$(html).appendTo(el);		
					}
				}
				$(".ajax-loader").hide();
				// update();
				setInterval(function() { update(); }, 5000);
			} else {
				addHtml(array, 0);
			}
			if(max_time) {
				$("#now").html(max_time.toISOString());
			} 
		}
	});
}

update(true);


