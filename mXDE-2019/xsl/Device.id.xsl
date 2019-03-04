<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:fhir="http://hl7.org/fhir" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0">
  <xsl:output method="text"/>
  <xsl:template match="/">
    <xsl:apply-templates select="/fhir:Device"/>
  </xsl:template>

  <xsl:template match="fhir:Device">
    <xsl:value-of select="fhir:id/@value"/>
  </xsl:template>

</xsl:stylesheet>
