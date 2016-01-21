<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:import href="vocabulary-common.xsl" />

	<!-- Writes the license terms and date copyrighted for W3C vocabularies. -->
	<xsl:template name="license">
		<xsl:param name="license" />
		<xsl:param name="dateCopyrighted" />

		<p>
			<xsl:text>Licensed Materials (See </xsl:text>
			<a href="{$license}">
				<xsl:value-of select="$license" />
			</a>
			<xsl:text>) - Property of W3C.</xsl:text>
			<br />
			<xsl:text>&#169; Copyright W3C </xsl:text>
			<xsl:value-of select="$dateCopyrighted" />
			<xsl:text>. All Rights Reserved.</xsl:text>
		</p>

	</xsl:template>

	<!-- Writes information about how this document was generated. -->
	<xsl:template name="about-this-document">

		<p>
			<xsl:text>This document was automatically generated from the Turtle source file for the vocabulary.</xsl:text>
		</p>

	</xsl:template>

</xsl:stylesheet>