<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:cda="urn:hl7-org:v3"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs"
  version="2.0">
  <xsl:output method="text"/>
  <xsl:template match="/cda:ClinicalDocument">
    <xsl:apply-templates select="//cda:encounter" />
  </xsl:template>
  
  <xsl:template match="cda:encounter">
    <xsl:text>Encounter,</xsl:text>
    <xsl:value-of select="//cda:recordTarget/cda:patientRole/cda:id/@extension" />
    <xsl:text>,</xsl:text>
    <xsl:value-of select="//cda:recordTarget/cda:patientRole/cda:id/@root" />
    <xsl:text>,</xsl:text>
    <xsl:value-of select="child::cda:effectiveTime/@value" />
    <xsl:text>,</xsl:text>

    <xsl:value-of select="child::cda:code/@code" />
    <xsl:text>,</xsl:text>
    <xsl:value-of select="child::cda:code/@codeSystem" />
    <xsl:text>,</xsl:text>
    <xsl:value-of select="child::cda:code/@displayName" />
    <xsl:text>,</xsl:text>
<!--
    <xsl:value-of select="descendant::cda:statusCode/@code" />
    <xsl:text>,</xsl:text>
    <xsl:value-of select="descendant::cda:code/@codeSystem" />
    <xsl:text>,</xsl:text>
    <xsl:value-of select="descendant::cda:code/@displayName" />
    <xsl:text>,</xsl:text>
    <xsl:value-of select="descendant::cda:value/@value" />
    <xsl:text>,</xsl:text>
    <xsl:value-of select="descendant::cda:value/@unit" />
-->
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

</xsl:stylesheet>
