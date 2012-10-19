<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" 
  omit-xml-declaration="yes" 
  encoding="utf-8"   />
  <xsl:param name="basename"/>
  <xsl:template match="/">
  <tr><td><a href="{$basename}.html"><xsl:value-of select="/html/head/title"/></a></td>
  <td><xsl:copy-of select="/html/body/div/div[@class='description'][1]/p[1]"/></td></tr>
  </xsl:template>
</xsl:stylesheet>