/**
 * The JavaScript library for the SWA components.
 * 
 * Note that this is under active development and some parts of this API
 * are more stable than others.
 * 
 * The public API that is considered relatively safe can be found on the top
 * of this file - anything under the demarkation line should only be used at
 * your own risk.  Please contact the developers if you need some specific
 * feature promoted to the stable API, or if you find a bug or limitation.
 */

// Global constants for RDF namespace
var swa = {
	
	diagrams : [],
		
initClassDiagram : function(id, subClassEdges) {
	swa.diagrams.push({ id : id, subClassEdges });
},

layoutDiagrams : function() {
	for(var i = 0; i < swa.diagrams.length; i++) {
		swa.doInitClassDiagram(swa.diagrams[i].id, swa.diagrams[i].subClassEdges);
	}
},

doInitClassDiagram : function(id, subClassEdges) {
	// $("#" + id).children(".swauml-class-node").draggable({ containment: "parent" });
	
	var g = new dagre.graphlib.Graph();
	g.setGraph({});
	g.setDefaultEdgeLabel(function() { return {}; });
	$("#" + id).children(".swauml-class-node").each(function(index, e) {
		var rs = e.getClientRects();
		var width = rs[0].width;
		var height = rs[0].height;
		var iri = $(e).attr("about");
		g.setNode(iri, { width: width, height: height });
	});
	
	$.each(subClassEdges, function(index, e) {
		g.setEdge(e.superClass, e.subClass);
	});
	
	dagre.layout(g);

	var offset = 20;
	var maxX = 40;
	var maxY = 40;
	g.nodes().forEach(function(v) {
		var node = g.node(v);
		var nodeElement = $("#" + id).children("[about=\"" + v + "\"]");
		nodeElement.css("left", offset + node.x - node.width / 2);
		nodeElement.css("top", offset + node.y - node.height / 2);
		maxX = Math.max(maxX, offset + node.x + node.width / 2 + offset);
		maxY = Math.max(maxY, offset + node.y + node.height / 2 + offset);
	});
	$("#" + id).css("height", maxY + "px");
	$("#" + id).css("width", maxX + "px");
	
	g.edges().forEach(function(e) {
		var edge = g.edge(e);
		var origin = edge.points[0];
		var lineElement = $("#" + id).find("[about=\"" + e.v + " " + e.w + "\"]");
		var points = "";
		$.each(edge.points, function(index, element) {
			points += "" + (offset + edge.points[index].x) + "," + (offset + edge.points[index].y) + " ";
		});
		lineElement.attr("points", points);
	});
},

	requireJSLibrary : function() {}
}
