
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
       "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">

<head>
<meta http-equiv="content-type" content="text/html; charset=UTF-8" />
<title>RGB Control Panel</title>
<script src="//code.jquery.com/jquery-2.1.0.min.js" type="text/javascript"></script>
<script src="//cdnjs.cloudflare.com/ajax/libs/raphael/2.1.2/raphael-min.js" type="text/javascript"></script>
<script src="./js/colorwheel/color.js" type="text/javascript"></script>


<link rel="stylesheet" href="./js/jquery-toggles/css/toggles.css">
<link rel="stylesheet" href="./js/jquery-toggles/css/toggles-full.css">
<script src="./js/jquery-toggles/toggles.js" type="text/javascript"></script>

  <link rel="stylesheet" href="./js/jquery-ui/jquery-ui.css">
  <script src="./js/jquery-ui/jquery-ui.js"></script>

<link rel="stylesheet" href="./css/styles.css">
  

</head>

<body>
     <div class="colorwheel_large" style="text-align:left; float:left;margin-right:5%; float:left;width:95% ">
     <div id="placeholder_toggles"></div>

     </div>
<script>




function init_toggle()
{
     //var soap_call="settings.json&tmp="+(new Date());
      var soap_call="utils.php?op=list_nodes"
      html="";
        $.ajax({  url:soap_call, async:   false, context: $(this) })  
          .done(function( data ) 
           { 
              var map={};
              for (var key in data) {
                map[data[key]["order"]]=data[key];
              }
               
              for (var key in map) {
                html+="<tr style='height:140px'><td class='label' style='width:60%'>"+map[key]["name"]+"</td>";
                html+="<td> <div id='"+map[key]["chipid"]+"' class='toggle toggle-light'></div></td>";
                html+="<td> <button id='reboot_"+map[key]["chipid"]+"' class='button-reboot ui-button ui-widget ui-corner-all' style='height:100px;width:200px'>Reboot</button></td>";
                html+="<td> <button id='off_"+map[key]["chipid"]+"' class='button-off ui-button ui-widget ui-corner-all' style='height:100px;width:200px'>Off</button></td>";
                html+="</tr>";
              }
            
            html="<table>"+html+"</table>";
           $("#placeholder_toggles").html(html);
       });     

    

    $('.toggle').toggles({
        drag: true, // allow dragging the toggle between positions
        click: true, // allow clicking on the toggle
        on: true, // is the toggle ON on init
        animate: 250, // animation time (ms)
        text: {
            on: '', // text for the ON position
            off: '' // and off
          },
        easing: 'swing', // animation transition easing function
        checkbox: null, // the checkbox to toggle (for use in forms)
        clicker: null, // element that can be clicked on to toggle. removes binding from the toggle itself (use nesting)
        width: 250, // width used if not set in css
        height: 100, // height if not set in css
        type: 'compact' // if this is set to 'select' then the select style toggle will be used
    });

    $( ".widget button" ).button();
    $( ".button-reboot" ).click( function( event ) {
       var node=$( this ).attr("id").substring(7);     
       $.ajax({  url:"utils.php?op=reboot&nodes="+node, async:   false, context: $(this) })  
          .done(function( data ){ alert(data) });
      event.preventDefault();
    } );
    $( ".button-off" ).click( function( event ) {
       var node=$( this ).attr("id").substring(4);     
       $.ajax({  url:"utils.php?op=poweroff&nodes="+node, async:   false, context: $(this) })  
          .done(function( data ){ alert(data) });
      event.preventDefault();
    } );

}

function init_colorwheel()
{
  cw=Raphael.colorwheel($(".colorwheel_large")[0],Math.min($(window).width(),$(window).height()), 180).color("#00F");
  cw.onchange(function(color)
  {
      var nodes="";

      $( ".toggle" ).each(function( index ) {
        if($( this ).data('toggles').active)
        {
            if(nodes!="")
              nodes+=",";
            nodes+=$( this ).attr("id");
        }
      });
      
      console.log(nodes);
      var colors = [parseInt(color.r), parseInt(color.g), parseInt(color.b)]
      $.get( "utils.php?op=color&color="+colors+"&nodes="+nodes );

    

  })

}

function init()
{
  init_colorwheel();
  init_toggle();

}



      $(document).ready(function(){
          init();
    })



    </script>

 
</body>
</html>
