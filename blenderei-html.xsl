<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xpath-default-namespace="http://www.w3.org/1999/xhtml"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <xsl:output method="xhtml" indent="no"/>
  
  <xsl:template match="/">
    <xsl:result-document href="htdocs/index.html">
      <xsl:apply-templates select="/" mode="export"/>
    </xsl:result-document>
    <xsl:apply-templates select="html/body/section[@id]"/>    
  </xsl:template>
  
  <xsl:template match="body/section[@id]">
    <xsl:result-document href="htdocs/{@id}.html">
      <xsl:apply-templates select="/" mode="export">
        <xsl:with-param name="section" select="." tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:result-document>
  </xsl:template>
  
  <xsl:template match="* | @*" mode="export">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="body/section[@id]" mode="export">
    <xsl:param name="section" as="element(section)?" tunnel="yes"/>
    <xsl:if test=". is $section">
      <main>
        <xsl:apply-templates mode="#current"/>
        <p class="home" title="Home"><a href="index.html">⌂</a></p>
      </main>
    </xsl:if>
  </xsl:template>
  
  <xsl:key name="pagelink" match="body/section[@id]" use="concat('#', @id)"/>
  
  <xsl:template match="a/@href[key('pagelink', .)]" mode="export">
    <xsl:attribute name="{name()}" select="replace(., '^#(.+)', '$1.html')"/>
  </xsl:template>
  
  <xsl:template match="a[key('pagelink', @href)]" mode="export">
    <xsl:param name="section" as="element(section)?" tunnel="yes"/>
    <xsl:choose>
      <xsl:when test="key('pagelink', @href) is $section">
        <xsl:apply-templates mode="#current"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  <xsl:template match="@src | @href" mode="export">
    <xsl:attribute name="{name()}" select="replace(., '^htdocs/', '')"/>
  </xsl:template>
  
</xsl:stylesheet>