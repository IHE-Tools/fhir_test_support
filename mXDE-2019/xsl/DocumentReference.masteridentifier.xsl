<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:fhir="http://hl7.org/fhir" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0">
  <xsl:output method="text"/>
  <xsl:template match="/">
    <xsl:apply-templates select="/fhir:DocumentReference/fhir:masterIdentifier"/>
  </xsl:template>

  <xsl:template match="fhir:masterIdentifier">
    <xsl:value-of select="fhir:assigner/fhir:reference/@value"/>
    <xsl:text>/</xsl:text>
    <xsl:value-of select="fhir:value/@value"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

</xsl:stylesheet>
