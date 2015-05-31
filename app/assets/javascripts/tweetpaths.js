// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var map;
var path;
var zindex = 0;
var initial_user = false;

function enableInputs(name) {
	elements = document.getElementsByName(name);
	for ( i in elements ) {
		elements[i].disabled = false;

	}
}

function disableInputs(name) {
	var elements = document.getElementsByName(name);
	for ( i in elements ) {
		elements[i].disabled = true;
		
	}
	
}

function initMap(location, screen_name) {
	var latlng = new google.maps.LatLng(0, 0);
	var zoom = 2;
	
	var geocoder = new google.maps.Geocoder();
	geocoder.geocode( { 'address': location}, function(results, status) {
		if (status == google.maps.GeocoderStatus.OK) {
			latlng = results[0].geometry.location;
			zoom = 10;
		}
		var myOptions = {
			zoom: zoom,
			center: latlng,
			mapTypeId: google.maps.MapTypeId.ROADMAP
		};
		map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
	});
	
	if (screen_name != "") {
		document.getElementById("user").value = screen_name;
		initial_user = true;
	}
}

function initPath() {
	path = new Array();
}

function addMarker(lat, long, text, infoHTML, markerURL, shadowURL) {
	var myLatLong = new google.maps.LatLng(lat, long);
	var shadowImage = new google.maps.MarkerImage(shadowURL, new google.maps.Size(64, 32), new google.maps.Point(0,0), new google.maps.Point(16, 32));
	var marker = new google.maps.Marker({
	    position: myLatLong, 
		map: map, 
		title: text,
		icon: markerURL,
		shadow: shadowImage
	});
	
	var infowindow = new google.maps.InfoWindow({
		content: infoHTML
		});

	google.maps.event.addListener(marker, 'click', function() {
		infowindow.setZIndex(zindex);
		infowindow.open(map,marker);
		zindex++;
		!function(d,s,id) {
			var js;
			if(js=d.getElementById(id)) {
				js.parentNode.removeChild(js);
			}
			var fjs=d.getElementsByTagName(s)[0];
			if(!d.getElementById(id)) {
				js=d.createElement(s);
				js.id=id;
				js.src="//platform.twitter.com/widgets.js";
				fjs.parentNode.insertBefore(js,fjs);
			}
		}(document,"script","twitter-wjs");
	});
	
	path.push(myLatLong);
}

function addPath(rgb) {
	var polyline = new google.maps.Polyline({
											map: map,
											path: path,
											strokeColor: rgb,
											strokeOpacity: 0.7,
											strokeWeight: 3
											});
}

function sizeMap() {
	var map_controls = document.getElementById("map_controls");
	var map_canvas = document.getElementById("map_canvas");
	var signin_message = document.getElementById("signin_message");
	var twitter_settings = document.getElementById("twitter_settings");
	var marker_message = document.getElementById("marker_message");
	var copyright = document.getElementById("copyright");
	
	var myWidth = 0, myHeight = 0;
	if( typeof( window.innerWidth ) == 'number' ) {
		//Non-IE
		myWidth = window.innerWidth;
		myHeight = window.innerHeight;
	} else if( document.documentElement && ( document.documentElement.clientWidth || document.documentElement.clientHeight ) ) {
		//IE 6+ in 'standards compliant mode'
		myWidth = document.documentElement.clientWidth;
		myHeight = document.documentElement.clientHeight;
	} else if( document.body && ( document.body.clientWidth || document.body.clientHeight ) ) {
		//IE 4 compatible
		myWidth = document.body.clientWidth;
		myHeight = document.body.clientHeight;
	}

	map_canvas.style.top = map_controls.offsetTop + "px";
	var mapTop = map_canvas.offsetTop;
	var mapLeft = map_canvas.offsetLeft;
	if (mapLeft < 10) {mapLeft += 300;}
	var mapHeight = myHeight - mapTop - copyright.offsetHeight - 10;
	var mapWidth = myWidth - mapLeft- 25;
	if (mapHeight < 200) {mapHeight = 200};
	if (mapWidth < 450) {mapWidth = 450};
	map_controls.style.height = mapHeight + "px";
	map_canvas.style.height = mapHeight + "px";
	map_canvas.style.width = mapWidth + "px";
	
	if (signin_message) {
		positionBox(signin_message, mapHeight, mapWidth, mapTop, mapLeft);
		signin_message.style.visibility = "visible";
	}
	
	if (twitter_settings) {
		positionBox(twitter_settings, mapHeight, mapWidth, mapTop, mapLeft);
	}

    if (marker_message) {
	    positionBox(marker_message, mapHeight, mapWidth, mapTop, mapLeft);
    }
}

function mobileSizeMap() {
	
	var toolbar = document.getElementById("toolbar");
	var map_canvas = document.getElementById("map_canvas");
	var signin_message = document.getElementById("signin_message");
	var twitter_settings = document.getElementById("twitter_settings");
	var add_user_form = document.getElementById("add_user_form");
	var map_legend = document.getElementById("map_legend");
	var marker_message = document.getElementById("marker_message");
	
	var myWidth = 0, myHeight = 0;
	if( typeof( window.innerWidth ) == 'number' ) {
		//Non-IE
		myWidth = window.innerWidth;
		myHeight = window.innerHeight;
	} else if( document.documentElement && ( document.documentElement.clientWidth || document.documentElement.clientHeight ) ) {
		//IE 6+ in 'standards compliant mode'
		myWidth = document.documentElement.clientWidth;
		myHeight = document.documentElement.clientHeight;
	} else if( document.body && ( document.body.clientWidth || document.body.clientHeight ) ) {
		//IE 4 compatible
		myWidth = document.body.clientWidth;
		myHeight = document.body.clientHeight;
	}
	
	map_canvas.style.top = toolbar.offsetBottom + "px";
	var mapTop = map_canvas.offsetTop;
	var mapHeight = myHeight - mapTop;
	var mapWidth = myWidth;
	var mapLeft = 0;
	map_canvas.style.height = mapHeight + "px";
	map_canvas.style.width = myWidth + "px";
	
	if (signin_message) {
		positionBox(signin_message, mapHeight, mapWidth, mapTop, mapLeft);
		signin_message.style.visibility = "visible";
	}
	
	if (twitter_settings) {
		positionBox(twitter_settings, mapHeight, mapWidth, mapTop, mapLeft);
	}
	
	if (marker_message) {
		positionBox(marker_message, mapHeight, mapWidth, mapTop, mapLeft);
	}
	
	if (add_user_form) {
		positionBox(add_user_form, mapHeight, mapWidth, mapTop, mapLeft);
	}
	
	if (map_legend) {
		var legendHeight = map_legend.offsetHeight;
		var legendWidth = map_legend.offsetWidth;
		var legendTop = ((mapHeight - legendHeight) / 2) + mapTop;
		if (legendTop < 30) {
			legendTop = 30;
		}
		var legendLeft = ((myWidth - legendWidth) / 2);
		map_legend.style.top = legendTop + "px";
		map_legend.style.left = legendLeft + "px";
	}
}

function positionBox(box, mapHeight, mapWidth, mapTop, mapLeft) {
	var boxHeight = box.offsetHeight;
	var boxWidth = box.offsetWidth;
	var boxTop = ((mapHeight - boxHeight) / 2) + mapTop;
	var boxLeft = ((mapWidth - boxWidth) / 2) + mapLeft;
	box.style.top = boxTop + "px";
	box.style.left = boxLeft + "px";
}	

function positionMap(north, south, east, west) {
	var sw = new google.maps.LatLng(south, west);
	var ne = new google.maps.LatLng(north, east);
	var bounds = new google.maps.LatLngBounds(sw, ne);
	map.fitBounds(bounds);
}

function resetForm(id) {
	document.getElementById(id).reset();
}

function enableElement(id) {
	element = document.getElementById(id);
	if (element) {
		element.disabled = false;
	}
}

function disableElement(id) {
	element = document.getElementById(id);
	if (element) {
		element.disabled = true;
	}
}

function showElement(id) {
	element = document.getElementById(id);
	if (element) {
		element.style.visibility = "visible";
	}
}

function hideElement(id) {
	element = document.getElementById(id);
	if (element) {
		element.style.visibility = "hidden";
	}
}

function invalidField(id) {
	document.getElementById(id).style.backgroundColor = '#FFDEDE'
}

function clearUser() {
	if (initial_user) {
		document.getElementById("user").value = "";
		initial_user = false;
	}
}

function focusUser() {
	document.getElementById("user").focus();
}

function fakeClick(anchorObj) {
	if (anchorObj.click) {
		anchorObj.click();
	} else if(document.createEvent) {
		var evt = document.createEvent("MouseEvents"); 
		evt.initMouseEvent("click", true, true, window, 
							0, 0, 0, 0, 0, false, false, false, false, 0, null); 
		var allowDefault = anchorObj.dispatchEvent(evt);
	}
}

function showOptions() {
	$('#hide-options').show();
	$('#show-options').hide();
	$('#options').slideDown(200);
}

function hideOptions() {
	$('#hide-options').hide();
	$('#show-options').show();
	$('#options').slideUp(200);
}

function showSignout () {
	document.getElementById("signout").style.visibility="visible";
	document.getElementById("navbar-right").style.backgroundColor = "#484848";
}

function hideSignout () {
	document.getElementById("signout").style.visibility="hidden";
	document.getElementById("navbar-right").style.backgroundColor = "#303030";
}