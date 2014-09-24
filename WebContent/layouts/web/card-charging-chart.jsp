<%@ page language="java" trimDirectiveWhitespaces="true" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>
<%@ taglib prefix="display" uri="http://displaytag.sf.net/el"%>
<%@ page import="vn.onepay.common.SharedConstants, vn.onepay.account.model.Account, java.lang.String"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<jsp:include page="head.jsp"></jsp:include>
<link href="${pageContext.request.contextPath }/css/personal.css" rel="stylesheet" type="text/css" />
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath() %>/css/jquery.multiselect.css" />
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/css/jquery-ui.min.css" />
<script type="text/javascript" src="<%=request.getContextPath() %>/js/jquery-ui.min.js"></script>
<script type="text/javascript" src="<%=request.getContextPath() %>/js/jquery.multiselect.js"></script>

<script src="<%=request.getContextPath() %>/js/chart/d3.v3.js"></script>
<script src="<%=request.getContextPath() %>/js/chart/nv.d3.js"></script>
<script src="<%=request.getContextPath() %>/js/chart/src/models/legend.js"></script>
<script src="<%=request.getContextPath() %>/js/chart/src/models/pie.js"></script>
<script src="<%=request.getContextPath() %>/js/chart/src/models/pieChart.js"></script>
<script src="<%=request.getContextPath() %>/js/chart/src/utils.js"></script>

<link href="<%=request.getContextPath() %>/css/chart/nv.d3.css" rel="stylesheet" type="text/css">

<style>
	.filter_row .fieldset_filter {border: solid 1px #ccc;margin-left:40px; width: auto;}
</style>


<script type="text/javascript">
$(function(){

	$("#filter_merchant").multiselect({
		selectedList: 4,
		noneSelectedText: "Tất cả"
	});
	$("#filter_provider").multiselect({
		selectedList: 4,
		noneSelectedText: "Tất cả"
	});
	$("#filter_card_type").multiselect({
		selectedList: 4,
		noneSelectedText: "Tất cả"
	});
	$("#filter_card_amount").multiselect({
		selectedList: 4,
		noneSelectedText: "Tất cả"
	});
});
</script>

<style >
	.box_locketqua table a{
		font-size: 14px;
		color: #2c8f39;
		padding-top: 2px;
		
	}
	
	.box_locketqua table a.slc_link {
		color: #FFA200;
	}
	
	.select_filter{
		border: 1px solid #CCCCCC;
		padding: 6px;
		margin: 0px;
		-webkit-border-radius: 3px;
		-moz-border-radius: 3px;
		border-radius: 3px;
		width: 140px;
		margin-left: 5px;
		box-shadow: 0 0 0 #000000, 0 3px 3px #EEEEEE inset;
	}
	
	.chart , .chart:HOVER{
		background: url("<%=request.getContextPath()%>/images/btngreen_bg.png") repeat-x scroll center top;
		color: #FFFFFF;
		display: block;
		float: right;
		font-weight: bold;
		height: 20px;
		line-height: 20px;
		padding-left: 5px;
		padding-right: 5px;
		border: 1px solid #39B54A;
		border-radius: 10px;
		text-shadow: 0 1px #20942B;
	}
	
	.mypiechart {
	  width: 500px;
	  border: 2px;
	}

</style>
</head>
<%
	Account account = (Account) request.getSession().getAttribute(SharedConstants.ACCOUNT_LOGINED);
	boolean isAdmin = account.isAdmin();
	boolean mbiz =  SharedConstants.MBIZ && isAdmin;
	request.setAttribute("MBIZ", mbiz);
%>
<body>
	<!-- 1PAY WEB -->
	<div id="wrapper">
		<!-- Web Top -->
		<div id="w_top">
			<div class="layout_1000">
				<!-- Header -->
				<%request.setAttribute("menuTrangChu", true); %>
				<jsp:include page="header.jsp"></jsp:include>
				<!-- / Header -->

				<!-- Body -->
				<div id="w_body">
					<div class="row_sub">
						<!-- Persanal Bar -->
						<jsp:include page="include_personal_bar.jsp" />
						<!-- Left Menu -->
						<%request.setAttribute("cardReportElastic", true);%>
						<jsp:include page="card-charging-search-menu.jsp" />
						
						<div class="right_content">
							<h1 class="srv_title">Biểu đồ</h1>
							<h2>____________________________</h2>
							<svg id="test1" class="mypiechart"></svg>

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
								  //alert(statusArrays);
								  					  							  							
								nv.addGraph(function() {
								    var width = 300,
								        height = 300;
								
								    var chart = nv.models.pieChart()
								        .x(function(d) { return d.key })
								        .y(function(d) { return d.value })
								        .color(d3.scale.category10().range())
								        .width(width)
								        .height(height);
								
								      d3.select("#test1")
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
						</div>
					</div>
				</div>
				<!-- / Body -->
			</div>
		</div>
		<!-- / Web Top -->

		<!-- Web Foot -->
		<jsp:include page="footer.jsp"></jsp:include>
		<!-- / Web Foot -->
	</div>
	<!-- / 1PAY WEB -->
	<script type="text/javascript">
		/*         */
		jQuery(function($) {

			$(function() {
				$('#hot_productslides').slides({
					preload : true,
					preloadImage : 'images/loading.gif',
					play : 5000,
					pause : 2500,
					hoverPause : true
				});
			});

		});
		/*   */
	</script>
	<!-- Create Menu Settings: (Menu ID, Is Vertical, Show Timer, Hide Timer, On Click ('all' or 'lev2'), Right to Left, Horizontal Subs, Flush Left, Flush Top) -->
	<script type="text/javascript">
		qm_create(0, false, 0, 250, false, false, false, false, false);
	</script>
	<!--[if IE]><iframe onload="on_script_loaded(function() { HashKeeper.reloading=false; });" style="display: none" name="hashkeeper" src="/blank" height="1" width="1" id="hashkeeper"></iframe><![endif]-->

</body>
</html>
