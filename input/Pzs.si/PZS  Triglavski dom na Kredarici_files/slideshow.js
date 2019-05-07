
$(document).ready(function() {		
	slideShow();
});

function slideShow() {
	//$('#gallery a').css({opacity: 0.0});
	$('#gallery a:first').css({opacity: 1.0});
	
	$('#gallery .caption').css({opacity: 0.7} );
	$('#gallery .content').html('');
	
	//Call the gallery function to run the slideshow, 6000 = change to next image after 6 seconds
	setInterval('gallery()',6000);
	
}

function gallery() {
	
	var current = ($('#gallery a.show')?  $('#gallery a.show') : $('#gallery a:first'));
	var next = ((current.next().length) ? ((current.next().hasClass('caption'))? $('#gallery a:first') :current.next()) : $('#gallery a:first'));	
	var caption = next.find('img').attr('rel');	
	var caption = '';
	next.css({opacity: 0.0})
	.addClass('show')
	.animate({opacity: 1.0}, 1000);
	current.animate({opacity: 0.0}, 1000)
	.removeClass('show');
	
	//$('#gallery .caption').animate({opacity: 0.0}, { queue:false, duration:0 }).animate({height: '0px'}, { queue:true, duration:300 });	
	
	//if(caption!='') { // prikaže samo, èe ni prazen!!!
		//$('#gallery .caption').animate({opacity: 0.7},100 ).animate({height: '30px'},500 );
	//}
	
	//$('#gallery .content').html(caption);
	
}
