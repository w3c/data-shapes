<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:dcterms="http://purl.org/dc/terms/" xmlns:oslc="http://open-services.net/ns/core#"
	xmlns:vs="http://www.w3.org/2003/06/sw-vocab-status/ns#"
	exclude-result-prefixes="rdf rdfs owl dcterms oslc">

	<xsl:output method="html" indent="yes" encoding="iso-8859-1" />

	<!-- The importing stylesheet should redefine the following templates to 
		provide content that depends on the site. -->

	<!-- Writes the license terms and date copyrighted. -->
	<xsl:template name="license">
		<xsl:param name="license" />
		<xsl:param name="dateCopyrighted" />
	</xsl:template>

	<!-- Writes details about how this document was generated. -->
	<xsl:template name="about-this-document" />

	<!-- The following templates do not depend on the site and should not normally 
		be redefined by the importing stylesheet. -->

	<xsl:template match="/rdf:RDF">
		<html>
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
			</head>
			<body>

				<!-- write the description of the RDF vocabulary -->
				<xsl:apply-templates
					select="rdf:Description[rdf:type/@rdf:resource='http://www.w3.org/2002/07/owl#Ontology']"
					mode="h1" />

				<!-- write the lists of defined RDF terms, grouped by kind -->
				<xsl:call-template name="write-defined-classes" />
				<xsl:call-template name="write-defined-properties" />
				<xsl:call-template name="write-defined-individuals" />

				<!-- write the table of prefixes used in this document -->
				<xsl:call-template name="write-prefix-table" />

				<!-- write the description of each RDF term defined by this vocabulary -->
				<xsl:for-each select="rdf:Description[rdfs:isDefinedBy]">
					<xsl:sort select="@rdf:about" case-order="upper-first" />
					<xsl:apply-templates select="." mode="h2" />
				</xsl:for-each>
			</body>
		</html>
	</xsl:template>

	<xsl:template
		match="rdf:Description[rdf:type/@rdf:resource='http://www.w3.org/2002/07/owl#Ontology']"
		mode="h1">
		<div class="rdf-vocabulary-section">
			<h1>
				<xsl:value-of select="dcterms:title" />
			</h1>

			<xsl:call-template name="write-license" />

			<p>
				<xsl:text>The namespace URI for this vocabulary is: </xsl:text>
				<blockquote>
					<a href="{@rdf:about}">
						<code>
							<xsl:value-of select="@rdf:about" />
						</code>
					</a>
				</blockquote>
			</p>

			<xsl:call-template name="description" />
			<xsl:call-template name="labels" />
			<xsl:call-template name="seeAlso" />

			<p>
				<xsl:text>This document lists the RDF classes, properties, and individuals that are defined by this vocabulary. Following </xsl:text>
				<a href="http://www.w3.org/TR/swbp-vocab-pub/">W3C best practices</a>
				<xsl:text>, this vocabulary is available as HTML (this document) and as </xsl:text>
				<a href="{dcterms:source/@rdf:resource}">RDF source</a>
				<xsl:text>.</xsl:text>
			</p>

			<xsl:call-template name="about-this-document" />

		</div>
	</xsl:template>

	<xsl:template match="rdf:Description" mode="toc">
		<xsl:variable name="local-name">
			<xsl:call-template name="write-local-name">
				<xsl:with-param name="uri" select="@rdf:about" />
			</xsl:call-template>
		</xsl:variable>
		<a href="#{$local-name}">
			<code>
				<xsl:value-of select="$local-name" />
			</code>
		</a>
	</xsl:template>

	<xsl:template match="rdf:Description" mode="h2">
		<div class="rdf-term-section">
			<xsl:variable name="local-name">
				<xsl:call-template name="write-local-name">
					<xsl:with-param name="uri" select="@rdf:about" />
				</xsl:call-template>
			</xsl:variable>
			<h2 id="{$local-name}">
				<code>
					<xsl:value-of select="$local-name" />
				</code>
			</h2>

			<p>
				<xsl:call-template name="write-as-link">
					<xsl:with-param name="uri" select="@rdf:about" />
				</xsl:call-template>
				<xsl:text> is an RDF </xsl:text>
				<xsl:choose>
					<xsl:when
						test="rdf:type/@rdf:resource='http://www.w3.org/2000/01/rdf-schema#Class'">
						<a href="#defined-Classes">class</a>
						<xsl:text>.</xsl:text>
					</xsl:when>
					<xsl:when
						test="rdf:type/@rdf:resource='http://www.w3.org/1999/02/22-rdf-syntax-ns#Property'">
						<a href="#defined-Properties">property</a>
						<xsl:text>.</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<a href="#defined-Individuals">individual</a>
						<xsl:text>.</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</p>
			<xsl:call-template name="description" />
			<xsl:call-template name="comment" />
			<xsl:call-template name="status" />
			<xsl:call-template name="labels" />
			<xsl:call-template name="values" />
			<xsl:call-template name="types" />
			<xsl:call-template name="is-subclass-of" />
			<xsl:call-template name="has-subclass" />
			<xsl:call-template name="is-subproperty-of" />
			<xsl:call-template name="has-subproperty" />
			<xsl:call-template name="is-domain-of" />
			<xsl:call-template name="has-domain" />
			<xsl:call-template name="is-range-of" />
			<xsl:call-template name="has-range" />
			<xsl:call-template name="seeAlso" />
		</div>
	</xsl:template>

	<xsl:template match="dcterms:description | rdfs:comment">
		<xsl:apply-templates />
	</xsl:template>

	<!-- Copies elements whose rdf:datatype is rdf:XMLLiteral without escaping 
		their content -->
	<xsl:template
		match="*[@rdf:datatype='http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral']">
		<xsl:value-of select="." disable-output-escaping="yes" />
	</xsl:template>

	<!-- Copies nodes verbatim. This is the default behavior. -->
	<xsl:template match="*|@*|text()">
		<xsl:copy>
			<xsl:apply-templates select="*|@*|text()" />
		</xsl:copy>
	</xsl:template>

	<!-- Writes the license and copyright statement. -->
	<xsl:template name="write-license">
		<xsl:variable name="license">
			<xsl:choose>
				<xsl:when test="dcterms:license/@rdf:resource">
					<xsl:value-of select="dcterms:license/@rdf:resource" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>License is not defined.</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="dateCopyrighted">
			<xsl:choose>
				<xsl:when test="dcterms:dateCopyrighted">
					<xsl:value-of select="dcterms:dateCopyrighted" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Date copyrighted is not defined.</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:call-template name="license">
			<xsl:with-param name="license" select="$license" />
			<xsl:with-param name="dateCopyrighted" select="$dateCopyrighted" />
		</xsl:call-template>

	</xsl:template>

	<!-- writes the dcterms:description of the term -->
	<xsl:template name="description">
		<xsl:if test="dcterms:description">
			<div class="description">
				<p>
					<xsl:apply-templates select="dcterms:description" />
				</p>
			</div>
		</xsl:if>
	</xsl:template>

	<!-- writes the rdfs:comment of the term -->
	<xsl:template name="comment">
		<xsl:if test="rdfs:comment">
			<div class="comment">
				<p>
					<xsl:apply-templates select="rdfs:comment" />
				</p>
			</div>
		</xsl:if>
	</xsl:template>

	<!-- Writes the rdf:type's of the term. -->
	<xsl:template name="types">
		<xsl:if test="rdf:type">
			<div class="types">
				<p>
					<strong>Type: </strong>
					<xsl:for-each select="rdf:type">
						<xsl:sort select="@rdf:resource" case-order="upper-first" />
						<xsl:if test="position()>1">
							<xsl:text>, </xsl:text>
						</xsl:if>
						<xsl:call-template name="write-as-link">
							<xsl:with-param name="uri" select="@rdf:resource" />
						</xsl:call-template>
					</xsl:for-each>
				</p>
			</div>
		</xsl:if>
	</xsl:template>

	<!-- Writes the rdf:value's of the term. -->
	<xsl:template name="values">
		<xsl:if test="rdf:value">
			<div class="values">
				<p>
					<strong>Value: </strong>
					<xsl:for-each select="rdf:value">
						<xsl:sort select="." case-order="upper-first" />
						<xsl:if test="position()>1">
							<xsl:text>, </xsl:text>
						</xsl:if>
						<xsl:value-of select="." />
					</xsl:for-each>
				</p>
			</div>
		</xsl:if>
	</xsl:template>

	<!-- Writes the vs:term_status of the term. -->
	<xsl:template name="status">
		<xsl:if test="vs:term_status">
			<div class="status">
				<p>
					<strong>Status: </strong>
					<a href="http://www.w3.org/2003/06/sw-vocab-status/note">
						<xsl:value-of select="vs:term_status" />
					</a>
				</p>
			</div>
		</xsl:if>
	</xsl:template>

	<!-- Writes the rdfs:label's of the term. -->
	<xsl:template name="labels">
		<xsl:if test="rdfs:label">
			<div class="labels">
				<p>
					<strong>Label: </strong>
					<xsl:for-each select="rdfs:label">
						<xsl:sort select="." case-order="upper-first" />
						<xsl:if test="position()>1">
							<xsl:text>, </xsl:text>
						</xsl:if>
						<xsl:value-of select="." />
					</xsl:for-each>
				</p>
			</div>
		</xsl:if>
	</xsl:template>

	<!-- Writes the "See Also" links. -->
	<xsl:template name="seeAlso">
		<xsl:if test="rdfs:seeAlso">
			<div class="seeAlso">
				<p>
					<strong>See Also:</strong>
				</p>
				<ul>
					<xsl:for-each select="rdfs:seeAlso">
						<xsl:sort select="@rdf:resource" case-order="upper-first" />
						<li>
							<xsl:call-template name="write-as-link">
								<xsl:with-param name="uri" select="@rdf:resource" />
							</xsl:call-template>
						</li>
					</xsl:for-each>
				</ul>
			</div>
		</xsl:if>
	</xsl:template>

	<!-- Write the subclassess -->
	<xsl:template name="has-subclass">
		<xsl:variable name="superclass" select="@rdf:about" />
		<xsl:variable name="subclasses"
			select="/rdf:RDF/rdf:Description[rdfs:subClassOf/@rdf:resource=$superclass]" />
		<xsl:if test="$subclasses">
			<div class="has-subclass">
				<p>
					<strong>Has subclass:</strong>
				</p>
				<ul>
					<xsl:for-each select="$subclasses">
						<xsl:sort select="@rdf:about" case-order="upper-first" />
						<li>
							<xsl:call-template name="write-as-link">
								<xsl:with-param name="uri" select="@rdf:about" />
							</xsl:call-template>
						</li>
					</xsl:for-each>
				</ul>
			</div>
		</xsl:if>
	</xsl:template>

	<!-- Write the superclasses -->
	<xsl:template name="is-subclass-of">
		<xsl:if test="rdfs:subClassOf">
			<div class="is-subclass-of">
				<p>
					<strong>Is subclass of:</strong>
				</p>
				<ul>
					<xsl:for-each select="rdfs:subClassOf">
						<xsl:sort select="@rdf:resource" case-order="upper-first" />
						<li>
							<xsl:call-template name="write-as-link">
								<xsl:with-param name="uri" select="@rdf:resource" />
							</xsl:call-template>
						</li>
					</xsl:for-each>
				</ul>
			</div>
		</xsl:if>
	</xsl:template>

	<!-- Write the superproperties -->
	<xsl:template name="is-subproperty-of">
		<xsl:if test="rdfs:subPropertyOf">
			<div class="is-subproperty-of">
				<p>
					<strong>Is subproperty of:</strong>
				</p>
				<ul>
					<xsl:for-each select="rdfs:subPropertyOf">
						<xsl:sort select="@rdf:resource" case-order="upper-first" />
						<li>
							<xsl:call-template name="write-as-link">
								<xsl:with-param name="uri" select="@rdf:resource" />
							</xsl:call-template>
						</li>
					</xsl:for-each>
				</ul>
			</div>
		</xsl:if>
	</xsl:template>

	<!-- Write the subproperties -->
	<xsl:template name="has-subproperty">
		<xsl:variable name="superproperty" select="@rdf:about" />
		<xsl:variable name="subproperties"
			select="/rdf:RDF/rdf:Description[rdfs:subPropertyOf/@rdf:resource=$superproperty]" />
		<xsl:if test="$subproperties">
			<div class="has-subproperty">
				<p>
					<strong>Has subproperty:</strong>
				</p>
				<ul>
					<xsl:for-each select="$subproperties">
						<xsl:sort select="@rdf:about" case-order="upper-first" />
						<li>
							<xsl:call-template name="write-as-link">
								<xsl:with-param name="uri" select="@rdf:about" />
							</xsl:call-template>
						</li>
					</xsl:for-each>
				</ul>
			</div>
		</xsl:if>
	</xsl:template>

	<!-- Write the domains -->
	<xsl:template name="has-domain">
		<xsl:if test="rdfs:domain">
			<div class="has-domain">
				<p>
					<strong>Has domain:</strong>
				</p>
				<ul>
					<xsl:for-each select="rdfs:domain">
						<xsl:sort select="@rdf:resource" case-order="upper-first" />
						<li>
							<xsl:call-template name="write-as-link">
								<xsl:with-param name="uri" select="@rdf:resource" />
							</xsl:call-template>
						</li>
					</xsl:for-each>
				</ul>
			</div>
		</xsl:if>
	</xsl:template>

	<!-- Write the properties that this class is a domain of -->
	<xsl:template name="is-domain-of">
		<xsl:variable name="class" select="@rdf:about" />
		<xsl:variable name="properties"
			select="/rdf:RDF/rdf:Description[rdfs:domain/@rdf:resource=$class]" />
		<xsl:if test="$properties">
			<div class="is-domain-of">
				<p>
					<strong>Is domain of:</strong>
				</p>
				<ul>
					<xsl:for-each select="$properties">
						<xsl:sort select="@rdf:about" case-order="upper-first" />
						<li>
							<xsl:call-template name="write-as-link">
								<xsl:with-param name="uri" select="@rdf:about" />
							</xsl:call-template>
						</li>
					</xsl:for-each>
				</ul>
			</div>
		</xsl:if>
	</xsl:template>

	<!-- Write the ranges -->
	<xsl:template name="has-range">
		<xsl:if test="rdfs:range">
			<div class="has-range">
				<p>
					<strong>Has range:</strong>
				</p>
				<ul>
					<xsl:for-each select="rdfs:range">
						<xsl:sort select="@rdf:resource" case-order="upper-first" />
						<li>
							<xsl:call-template name="write-as-link">
								<xsl:with-param name="uri" select="@rdf:resource" />
							</xsl:call-template>
						</li>
					</xsl:for-each>
				</ul>
			</div>
		</xsl:if>
	</xsl:template>

	<!-- Write the properties that this class is a range of -->
	<xsl:template name="is-range-of">
		<xsl:variable name="class" select="@rdf:about" />
		<xsl:variable name="properties"
			select="/rdf:RDF/rdf:Description[rdfs:range/@rdf:resource=$class]" />
		<xsl:if test="$properties">
			<div class="is-range-of">
				<p>
					<strong>Is range of:</strong>
				</p>
				<ul>
					<xsl:for-each select="$properties">
						<xsl:sort select="@rdf:about" case-order="upper-first" />
						<li>
							<xsl:call-template name="write-as-link">
								<xsl:with-param name="uri" select="@rdf:about" />
							</xsl:call-template>
						</li>
					</xsl:for-each>
				</ul>
			</div>
		</xsl:if>
	</xsl:template>

	<!-- Writes the local name of terms defined by the vocabulary. -->
	<xsl:template name="write-local-name">
		<xsl:param name="uri" />
		<xsl:variable name="isDefinedBy"
			select="/rdf:RDF/rdf:Description[@rdf:about=$uri]/rdfs:isDefinedBy/@rdf:resource" />
		<xsl:value-of select="substring-after($uri,$isDefinedBy)" />
	</xsl:template>

	<xsl:template name="write-as-link">
		<xsl:param name="uri" />
		<xsl:variable name="description"
			select="/rdf:RDF/rdf:Description[@rdf:about=$uri]" />
		<xsl:variable name="link">
			<xsl:choose>
				<xsl:when test="$description">
					<xsl:text>#</xsl:text>
					<xsl:call-template name="write-local-name">
						<xsl:with-param name="uri" select="$uri" />
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$uri" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<a href="{$link}">
			<code>
				<xsl:call-template name="write-as-prefixed-name">
					<xsl:with-param name="uri" select="$uri" />
				</xsl:call-template>
			</code>
		</a>
	</xsl:template>

	<!-- Write the URI as a prefixed name if possible -->
	<xsl:template name="write-as-prefixed-name">
		<xsl:param name="uri" />

		<!-- look for the prefix in the vocabulary -->
		<xsl:variable name="definedPrefixDefinition"
			select="/rdf:RDF/rdf:Description[rdf:type/@rdf:resource='http://open-services.net/ns/core#PrefixDefinition'][starts-with($uri,oslc:prefixBase/@rdf:resource)]" />

		<!-- look for the prefix in this stylesheet -->
		<xsl:variable name="builtInPrefixDefinition"
			select="document('')/*/rdf:Description[rdf:type/@rdf:resource='http://open-services.net/ns/core#PrefixDefinition'][starts-with($uri,oslc:prefixBase/@rdf:resource)]" />

		<xsl:choose>
			<xsl:when test="$definedPrefixDefinition">
				<!-- a prefix exists in the vocabulary so use it -->
				<xsl:value-of select="$definedPrefixDefinition/oslc:prefix" />
				<xsl:text>:</xsl:text>
				<xsl:value-of
					select="substring-after($uri,$definedPrefixDefinition/oslc:prefixBase/@rdf:resource)" />
			</xsl:when>
			<xsl:when test="$builtInPrefixDefinition">
				<!-- a prefix exists in the stylesheet so use it -->
				<xsl:value-of select="$builtInPrefixDefinition/oslc:prefix" />
				<xsl:text>:</xsl:text>
				<xsl:value-of
					select="substring-after($uri,$builtInPrefixDefinition/oslc:prefixBase/@rdf:resource)" />
			</xsl:when>
			<xsl:otherwise>
				<!-- there is no prefix so use the full URI -->
				<xsl:value-of select="$uri" />
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<!-- write the table of prefixes -->
	<xsl:template name="write-prefix-table">
		<div class="prefix-table">

			<!-- prefixes defined in the vocabulary -->
			<xsl:variable name="vocab"
				select="/rdf:RDF/rdf:Description[rdf:type/@rdf:resource='http://open-services.net/ns/core#PrefixDefinition']" />

			<p>
				<strong>Prefixes defined in this vocabulary:</strong>
			</p>

			<table>
				<tr>
					<th>Prefix</th>
					<th>URI</th>
				</tr>

				<xsl:for-each select="$vocab">
					<xsl:sort select="oslc:prefix" />
					<xsl:variable name="prefix" select="oslc:prefix" />
					<xsl:variable name="uri" select="oslc:prefixBase/@rdf:resource" />
					<tr>
						<td>
							<code>
								<xsl:value-of select="$prefix" />
								<xsl:text>:</xsl:text>
							</code>
						</td>
						<td>
							<a href="{$uri}">
								<code>
									<xsl:value-of select="$uri" />
								</code>
							</a>
						</td>
					</tr>
				</xsl:for-each>
			</table>

			<p>
				<strong>Pre-defined standard prefixes:</strong>
			</p>

			<table>
				<tr>
					<th>Prefix</th>
					<th>URI</th>
				</tr>

				<!-- prefixes built-in to this stylesheet -->
				<xsl:variable name="built-in"
					select="document('')/*/rdf:Description[rdf:type/@rdf:resource='http://open-services.net/ns/core#PrefixDefinition']" />

				<!-- list the built-ins that do not conflict with the vocabulary prefixes -->
				<xsl:for-each select="$built-in">
					<xsl:sort select="oslc:prefix" />
					<xsl:variable name="prefix" select="oslc:prefix" />
					<xsl:variable name="uri" select="oslc:prefixBase/@rdf:resource" />
					<xsl:if
						test="count($vocab[oslc:prefix=$prefix])=0 and count($vocab[oslc:prefixBase/@rdf:resource=$uri])=0">
						<tr>
							<td>
								<code>
									<xsl:value-of select="$prefix" />
									<xsl:text>:</xsl:text>
								</code>
							</td>
							<td>
								<a href="{$uri}">
									<code>
										<xsl:value-of select="$uri" />
									</code>
								</a>
							</td>
						</tr>
					</xsl:if>
				</xsl:for-each>

			</table>
		</div>
	</xsl:template>

	<!-- writes the list of classes defined in this vocabulary -->
	<xsl:template name="write-defined-classes">
		<xsl:call-template name="write-defined-terms">
			<xsl:with-param name="kind" select="'Classes'" />
			<xsl:with-param name="terms"
				select="rdf:Description[rdf:type/@rdf:resource='http://www.w3.org/2000/01/rdf-schema#Class']" />
		</xsl:call-template>
	</xsl:template>

	<!-- writes the list of properties defined in this vocabulary -->
	<xsl:template name="write-defined-properties">
		<xsl:call-template name="write-defined-terms">
			<xsl:with-param name="kind" select="'Properties'" />
			<xsl:with-param name="terms"
				select="rdf:Description[rdf:type/@rdf:resource='http://www.w3.org/1999/02/22-rdf-syntax-ns#Property']" />
		</xsl:call-template>
	</xsl:template>

	<!-- writes the list of individuals defined in this vocabulary -->
	<xsl:template name="write-defined-individuals">
		<xsl:call-template name="write-defined-terms">
			<xsl:with-param name="kind" select="'Individuals'" />
			<xsl:with-param name="terms"
				select="rdf:Description[rdfs:isDefinedBy][not(rdf:type/@rdf:resource='http://www.w3.org/1999/02/22-rdf-syntax-ns#Property')][not(rdf:type/@rdf:resource='http://www.w3.org/2000/01/rdf-schema#Class')]" />
		</xsl:call-template>
	</xsl:template>

	<!-- writes the list of terms of a given kind defined in this vocabulary -->
	<xsl:template name="write-defined-terms">
		<xsl:param name="terms" />
		<xsl:param name="kind" />
		<div id="defined-{$kind}">
			<p>
				<strong>
					<xsl:value-of select="$kind" />
					<xsl:text> defined by this vocabulary(</xsl:text>
					<xsl:value-of select="count($terms)" />
					<xsl:text>):</xsl:text>
				</strong>
			</p>
			<p>
				<xsl:choose>
					<xsl:when test="$terms">
						<xsl:for-each select="$terms">
							<xsl:sort select="@rdf:about" case-order="upper-first" />
							<xsl:if test="position()>1">
								<xsl:text>, </xsl:text>
							</xsl:if>
							<xsl:apply-templates select="." mode="toc" />
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>None.</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</p>
		</div>
	</xsl:template>

	<!-- The built-in prefix definitions. -->

	<rdf:Description rdf:about="#rdf">
		<oslc:prefixBase rdf:resource="http://www.w3.org/1999/02/22-rdf-syntax-ns#" />
		<oslc:prefix>rdf</oslc:prefix>
		<rdf:type rdf:resource="http://open-services.net/ns/core#PrefixDefinition" />
	</rdf:Description>

	<rdf:Description rdf:about="#rdfs">
		<oslc:prefixBase rdf:resource="http://www.w3.org/2000/01/rdf-schema#" />
		<oslc:prefix>rdfs</oslc:prefix>
		<rdf:type rdf:resource="http://open-services.net/ns/core#PrefixDefinition" />
	</rdf:Description>

	<rdf:Description rdf:about="#xsd">
		<oslc:prefixBase rdf:resource="http://www.w3.org/2001/XMLSchema#" />
		<oslc:prefix>xsd</oslc:prefix>
		<rdf:type rdf:resource="http://open-services.net/ns/core#PrefixDefinition" />
	</rdf:Description>

</xsl:stylesheet>