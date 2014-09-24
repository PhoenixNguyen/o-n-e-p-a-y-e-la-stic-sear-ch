<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<style>
	.pie_chart {
	  width: 500px;
	  border: 2px;
	}
	#pie{
		margin-left: 50px;
	}
</style>

<script>
  $( function() { load_data(); });

  var display_chart = function(json) {
    //alert(json.facets.tags.terms);
    Donut().data(json.facets.tags.terms).draw();
  };

  var load_data = function() {
    $.ajax({   url: 'http://localhost:9200/cardcdrs/_search?pretty=true'
             , type: 'POST'
             , data :
                JSON.stringify(
                {
                  "query" : { "match_all" : {} },

                  "facets" : {
                    "tags" : {
                      "terms" : {
                          "field" : "status",
                          "size"  : "1000"
                      }
                    }
                  }
                })
             , dataType : 'json'
             , processData: false
             , success: function(json, statusText, xhr) {
          	   //drawPie(json);
                 return drawPie(json.facets.tags.terms);
               }
             , error: function(xhr, message, error) {
                 console.error("Error while loading data from ElasticSearch", message);
                 throw(error);
               }          
    });
  };
</script>

      				<script>
  function drawPie(json){
	  //alert(json);
	  var statusArrays = [];
	  $.each(json, function(k , v){
		  //alert(v.term);
		  statusArrays.push({key : v.term, value : v.count});
	  });
	  					  							  							
	nv.addGraph(function() {
	    var width = 400,
	        height = 400;
	
	    var chart = nv.models.pieChart()
	        .x(function(d) { return d.key })
	        .y(function(d) { return d.value })
	        .color(d3.scale.category10().range())
	        .width(width)
	        .height(height);
	
	      d3.select("#pie_chart")
	          .datum(statusArrays)
	        .transition().duration(1200)
	          .attr('width', width)
	          .attr('height', height)
	          .call(chart);
	
	    chart.dispatch.on('stateChange', function(e) { nv.log('New State:', JSON.stringify(e)); });
	
	    return chart;
	});
}													
</script>