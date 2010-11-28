<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns="http://www.w3.org/1999/xhtml">
  <xsl:output method="xml" indent="yes"/> 
 
  <xsl:template match="//h1">
    <heading>
      <xsl:apply-templates/> 
    </heading>
  </xsl:template>
 
</xsl:stylesheet>