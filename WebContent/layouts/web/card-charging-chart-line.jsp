<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>


<style>
#line_chart {
	/* margin-top: 200px;
	  margin-left: 100px; */
	
}
</style>

<script>
	$(function() {
		load_time_detail();
		load_time();
		
	});

	var load_time = function() {
		var date1 = new Date('2014/09/18');
		var date2 = new Date('2014/09/19');
		
		$.ajax({
			url : 'http://localhost:9200/cardcdrs/_search?pretty=true',
			type : 'POST',
			data : JSON.stringify({
				"query" : {
					"match_all" : {}
				},
				"facets" : {
					"published" : {
						"date_histogram" : {
							"field" : "timestamp",
							"interval" : "0.1h"
						}
					}

				}
				,
				"query": {
		            "range" : {
		                "timestamp" : {
		                    "gte": date1.getTime(),
		                    "lte": date2.getTime()
		                }
		            }
		        }
		        		        
			}),
			dataType : 'json',
			processData : false,
			success : function(json, statusText, xhr) {
				//alert(json);
				return draw(json.facets.published.entries);
			},
			error : function(xhr, message, error) {
				console.error("Error while loading data from ElasticSearch",
						message);
				throw (error);
			}
		});
	};
	var listSuccess, listError, listWrong;
	var load_time_detail = function() {
		var status = '00';
		var date1 = new Date('2014/09/18');
		var date2 = new Date('2014/09/19');
		//alert(date.getTime());
		
		$.ajax({
			url : 'http://localhost:9200/cardcdrs/_search?pretty=true',
			type : 'POST',
			data : JSON.stringify({
				"query" : {
					"match_all" : {}
				},
				"facets" : {
					"published" : {
						"date_histogram" : {
							"field" : "timestamp",
							"interval" : "0.1h"
						}
					}

				},
				"query": {
				    "filtered":{
				    "filter" : {
				    	"and" : [{
				                
				                "range" : {
					                "timestamp" : {
					                    "from": date1.getTime(),
					                    "to": date2.getTime()
					                }
				            	}
							},
							{
								"query" : {
									"term" : {
										"status" : status
									}
								}
							}
							]
							
				        }
				    }
			     } 
		        		        
			}),
			dataType : 'json',
			processData : false,
			success : function(json, statusText, xhr) {
				//alert(json);
				listSuccess = json.facets.published.entries;
				//return null;
			},
			error : function(xhr, message, error) {
				console.error("Error while loading data from ElasticSearch",
						message);
				throw (error);
			}
		});
		$.ajax({
			url : 'http://localhost:9200/cardcdrs/_search?pretty=true',
			type : 'POST',
			data : JSON.stringify({
				"query" : {
					"match_all" : {}
				},
				"facets" : {
					"published" : {
						"date_histogram" : {
							"field" : "timestamp",
							"interval" : "0.1h"
						}
					}

				},
				"query": {
				    "filtered":{
				    "filter" : {
				    	"and" : [{
				                
				                "range" : {
					                "timestamp" : {
					                    "from": date1.getTime(),
					                    "to": date2.getTime()
					                }
				            	}
							},
							{
								"query" : {
									"terms" : {
										"status" : ['01', '02', '03', '04', '05', '06', '16', '17', '18', '19', '20', '21', '22', '23', '99','07'],
										"minimum_should_match" : 1
									}
								}
							}
							]
							
				        }
				    }
			     } 
		        		        
			}),
			dataType : 'json',
			processData : false,
			success : function(json, statusText, xhr) {
				//alert(json);
				listError = json.facets.published.entries;
				//return null;
			},
			error : function(xhr, message, error) {
				console.error("Error while loading data from ElasticSearch",
						message);
				throw (error);
			}
		});
		$.ajax({
			url : 'http://localhost:9200/cardcdrs/_search?pretty=true',
			type : 'POST',
			data : JSON.stringify({
				"query" : {
					"match_all" : {}
				},
				"facets" : {
					"published" : {
						"date_histogram" : {
							"field" : "timestamp",
							"interval" : "0.1h"
						}
					}

				},
				"query": {
				    "filtered":{
				    "filter" : {
				    	"and" : [{
				                
				                "range" : {
					                "timestamp" : {
					                    "from": date1.getTime(),
					                    "to": date2.getTime()
					                }
				            	}
							},
							{
								"query" : {
									"terms" : {
										"status" : ['11', '14']
									}
								}
							}
							]
							
				        }
				    }
			     } 
		        		        
			}),
			dataType : 'json',
			processData : false,
			success : function(json, statusText, xhr) {
				//alert(json);
				listWrong = json.facets.published.entries;
				//return null;
			},
			error : function(xhr, message, error) {
				console.error("Error while loading data from ElasticSearch",
						message);
				throw (error);
			}
		});
	};
	
</script>

<script>
	function draw(json){
		
		var chart;

		nv.addGraph(function() {
			chart = nv.models.lineChart().options({
				margin : {
					left : 100,
					bottom : 100
				},
				x : function(d, i) {
					return i
				},
				showXAxis : true,
				showYAxis : true,
				transitionDuration : 250
			});

			// chart sub-models (ie. xAxis, yAxis, etc) when accessed directly, return themselves, not the parent chart, so need to chain separately
			chart.xAxis.axisLabel("Thời gian").tickFormat(d3.format(',.1f'));

			chart.yAxis.axisLabel('Số lượng').tickFormat(d3.format(',.2f'));

			//var format = d3.time.format("%Y-%m-%d %H:%m:%s"); 
			chart.xAxis.tickFormat(function (d) {
				var date = new Date(json[d].time);
				
				//return [date.getDate(), date.getMonth()+1].join('/');
				return [date.getDate(), date.getMonth()+1].join('/') +" " + [date.getHours(), date.getMinutes()].join(':');
			});
			
			d3.select('#line_chart svg').datum(generateLineCoordinates()).call(chart);

			
			//TODO: Figure out a good way to do this automatically
			nv.utils.windowResize(chart.update);
			//nv.utils.windowResize(function() { d3.select('#chart1 svg').call(chart) });

			chart.dispatch.on('stateChange', function(e) {
				nv.log('New State:', JSON.stringify(e));
			});

			return chart;
		});
		
		function generateLineCoordinates(){
			/* for (var key in json[0]) {
			    alert(key);
			} */
			
			//alert(listError);
			/* if(listSuccess.length == 0)
				listSuccess = []; */
			
			for (var i = 0; i < json.length; i++) {
				if(json[i].time != listSuccess[i].time){
					var blank = {time:json[i].time, count:0};
					listSuccess.splice(i, 0, blank);
				}
				if(json[i].time != listError[i].time){
					var blank = {time:json[i].time, count:0};
					listError.splice(i, 0, blank);
				}
				if(json[i].time != listWrong[i].time){
					var blank = {time:json[i].time, count:0};
					listWrong.splice(i, 0, blank);
				}
			}
			
			var lineTotal = [], lineSuccess = [], lineError = [], lineWrong = [];
			for (var i = 0; i < json.length; i++) {
				lineTotal.push({
					x : i,
					y : json[i].count
				}); 
				
				//if(json[i].time == list1[i].time && i < list1.length)
					 lineSuccess.push({
						x : i,
						y : listSuccess[i].count
					});
				
				lineError.push({
					x : i,
					y : listError[i].count
				}); 
				lineWrong.push({
					x : i,
					y : listWrong[i].count
				});
				
			}
			
			return [ {
				
				values : lineTotal,
				key : "Tất cả",
				color : "#2222ff"
			}
			,
			{
				
				values : lineSuccess,
				key : "Thành công",
				color : "#2ca02c"
			}
			,
			{
				
				values : lineError,
				key : "Thẻ lỗi",
				color : "#ff7f0e"
			},
			{
	
				values : lineWrong,
				key : "Thẻ sai",
				color : "#667711"
			}
			];
		}
		
	}
	
</script>