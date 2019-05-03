    $(document).ready(function(){
        var default_star_value = 0;
 
        $("a span").mouseover(function(){
            showRedStar($(this).attr('title'))
        }).mouseout(function(){
            hideRedStar()
        }).click(function(){
            $("#star-msg").html("");
 
            var selected_star = $(this).attr('title');
 
            $.post(
                "jquery/rating/rate_inc.php",
                { star: selected_star },
                function(data){
                    $("#star-avg").html(data.average);
                    $("#star-total").html(data.total);
                    $("#star-msg").html(data.message).fadeIn(1000);
 
                    default_star_value = data.average
 
                    showRedStar(default_star_value)
                },
                "json"
            );
        });
 
        $("a").mouseout(function(){
            showRedStar(default_star_value)
        });
		
		setTimeout(function(){
			$("#star-msg").fadeOut(1000)
		}, 4000);
    });
 
    function showRedStar(star_number){
        hideRedStar();
 
        for(star_ctr = 1; star_ctr <= star_number; star_ctr++){
            $("#star" + star_ctr).removeClass('star-grey').addClass('star-red');
        }
    }
 
    function hideRedStar(){
        for(star_ctr = 5; star_ctr >=1; star_ctr--){
            $("#star" + star_ctr).removeClass('star-red').addClass('star-grey');
        }
    }
