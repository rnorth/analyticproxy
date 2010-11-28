<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns="http://www.example.org">
  <xsl:output method="xml" indent="yes"/> 
 
  <xsl:template match="//H1">
    <heading xmlns="http://www.example.org">
      <xsl:apply-templates/> 
    </heading>
  </xsl:template>
 
</xsl:stylesheet>