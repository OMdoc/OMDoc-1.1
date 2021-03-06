<?xml version="1.0" encoding="utf-8"?>
<!-- An XSL style sheet for creating machine-oriented output from 
     OMDoc (Open Mathematical Documents). It forms the basis for 
     the style sheets transforming OMDoc into html, mathml, TeX, 
     and Mathematica notebooks.
     URL: http://www.mathweb.org/omdoc/xsl/omdoc2share.dtd
     send bug-reports, patches, suggestions to omdoc@mathweb.org

     Copyright (c) 2000 - 2002 Michael Kohlhase, 

     This library is free software; you can redistribute it and/or
     modify it under the terms of the GNU Lesser General Public
     License as published by the Free Software Foundation; either
     version 2.1 of the License, or (at your option) any later version.

     This library is distributed in the hope that it will be useful,
     but WITHOUT ANY WARRANTY; without even the implied warranty of
     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
     Lesser General Public License for more details.

     You should have received a copy of the GNU Lesser General Public
     License along with this library; if not, write to the Free Software
     Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:str="http://exslt.org/strings" 
 extension-element-prefixes="str"
 xmlns:om="http://www.openmath.org/OpenMath"
 xmlns:dc="http://purl.org/DC"
 xmlns:omdoc="http://www.mathweb.org/omdoc"
 version="1.0">

<xsl:import href="omdocutils.xsl"/>
<xsl:param name="report-errors" select="'no'"/> 

<xsl:strip-space elements = "*"/> 

<xsl:output method="text"/>

<xsl:variable name="crossref-format" select="'html'"/>

<xsl:template match="*">
  <xsl:message>Warning: element <xsl:value-of select="local-name()"/> not covered!</xsl:message>
  <xsl:message>It was <xsl:copy-of select="."/></xsl:message>
</xsl:template>

<xsl:template match="/">
  <xsl:if test="omdoc:omdoc/@version!='1.1'">
    <xsl:message>WARNING: applying an OMDoc 1.1 style sheet to an OMDoc <xsl:value-of select="omdoc:omdoc/@version"/> document!
    This need not be a problem, but can lead to unintened results.
    </xsl:message>
  </xsl:if>
  <xsl:call-template name="comment-lines">
    <xsl:with-param name="text" select="'This file is automatically generated, from an OMDoc document &#xA;by an XSL style sheet (omdoc2xxx.xsl)  do not edit&#xA;for information about OMDoc, see http://www.mathweb.org/omdoc'"/>
  </xsl:call-template>
  <xsl:text>&#xA;&#xA;</xsl:text>
  <xsl:apply-templates select="/omdoc:omdoc/omdoc:metadata" mode="toplevel"/>
  <xsl:apply-templates/>
  <xsl:text>&#xA;&#xA;</xsl:text>
</xsl:template>

<xsl:template name="commentline">
  <xsl:param name="comment"/>
  <xsl:call-template name="bcomment"/>
  <xsl:value-of select="$comment"/>
  <xsl:call-template name="ecomment"/>
</xsl:template>

<xsl:template name="ecomment"><xsl:text>&#xA;</xsl:text></xsl:template>

<xsl:template match="omdoc:omdoc"><xsl:apply-templates/></xsl:template>

<!-- normally do not output metadata -->
<xsl:template match="omdoc:metadata"/>

<!-- except at the top level -->
<xsl:template match="omdoc:metadata" mode="toplevel">
  <xsl:if test="*">
    <xsl:variable name="text">
      <xsl:value-of select="concat('The original ',local-name(..),' with identifier')"/>
      <xsl:choose>
        <xsl:when test="dc:Identifier">
          <xsl:if test="count(dc:Identifier) &gt; 1"><xsl:value-of select="'s '"/></xsl:if>
          <xsl:for-each select="dc:Identifier">
            <xsl:value-of select="normalize-space(.)"/>
            <xsl:if test="dc:Identifier/@scheme"><xsl:value-of select="concat(' (',@scheme,')')"/></xsl:if>
            <xsl:if test="position()!=last()"><xsl:value-of select="', '"/></xsl:if>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="concat(' `',../@id,'`')"/></xsl:otherwise>
      </xsl:choose>
      <xsl:value-of select="'&#xA;'"/>
      <xsl:if test="dc:Title">
        <xsl:value-of select="concat('titled: ',normalize-space(dc:Title),'&#xA;')"/>
      </xsl:if>
      <xsl:if test="dc:Creator">
        <xsl:value-of select="'was created by: '"/>
        <xsl:for-each select="dc:Creator">
          <xsl:variable name="role"><xsl:call-template name="get-role"/></xsl:variable>
          <xsl:value-of select="concat(normalize-space(.),' (',$role,')')"/>
          <xsl:if test="position()!=last()"><xsl:value-of select="', '"/></xsl:if>
        </xsl:for-each>
        <xsl:value-of select="'&#xA;'"/>
      </xsl:if>
      <xsl:if test="dc:Contributor">
        <xsl:value-of select="'with contributions of: '"/>
        <xsl:for-each select="dc:Contributor">
          <xsl:variable name="role"><xsl:call-template name="get-role"/></xsl:variable>
          <xsl:value-of select="concat(normalize-space(.),' (',$role,')')"/>
          <xsl:if test="position()!=last()"><xsl:value-of select="', '"/></xsl:if>
        </xsl:for-each>
        <xsl:value-of select="'&#xA;'"/>
      </xsl:if>
      <xsl:if test="dc:Date">
        <xsl:choose>
          <xsl:when test="dc:Creator or dc:Collaborator"><xsl:value-of select="'on: '"/></xsl:when>
          <xsl:otherwise><xsl:value-of select="'was created on: '"/></xsl:otherwise>
       </xsl:choose>
        <xsl:for-each select="dc:Date">
          <xsl:value-of select="concat(normalize-space(.),' (',@action,')')"/>
          <xsl:if test="position()!=last()"><xsl:value-of select="', '"/></xsl:if>
        </xsl:for-each>
        <xsl:value-of select="'&#xA;'"/>
      </xsl:if>
      <xsl:if test="dc:Rights">
        <xsl:value-of select="concat('Rights: ',normalize-space(dc:Rights),'&#xA;')"/>
      </xsl:if>
    </xsl:variable>
    <xsl:call-template name="comment-lines">
      <xsl:with-param name="text" select="$text"/>
    </xsl:call-template>
    <xsl:text>&#xA;</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template name="get-role">
  <xsl:choose>
    <xsl:when test="@role='aut'">author</xsl:when>
    <xsl:when test="@role='aqt'">quoted</xsl:when>
    <xsl:when test="@role='aft'">afterword</xsl:when>
    <xsl:when test="@role='aui'">introduction</xsl:when>
    <xsl:when test="@role='clb'">collaborator</xsl:when>
    <xsl:when test="@role='edt'">editor</xsl:when>
    <xsl:when test="@role='ths'">advisor</xsl:when>
    <xsl:when test="@role='trc'">transcriber</xsl:when>
    <xsl:when test="@role='trl'">translator</xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template match="omdoc:theory">
  <xsl:call-template name="ecomment"/>
  <xsl:text>The following records belong to the theory </xsl:text>
  <xsl:value-of select="@id"/>
  <xsl:call-template name="ecomment"/>
  <xsl:text>&#xA;</xsl:text>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="omdoc:omtext">
  <xsl:call-template name="comment-lines">
    <xsl:with-param name="text" select="omdoc:CMP[@xml:lang='en']"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="comment-lines">
  <xsl:param name="text"/>
  <xsl:for-each select="str:tokenize($text,'&#x09;&#x0A;&#x0D;')">
    <xsl:call-template name="commentline">
      <xsl:with-param name="comment" select="."/>
    </xsl:call-template>
  </xsl:for-each>
</xsl:template>

<!-- some structures that we do not want to use in system output -->
<xsl:template match="omdoc:omgroup"><xsl:apply-templates/></xsl:template>
<!-- some elements we do not want to look at in output systems. -->
<xsl:template match="omdoc:presentation"/>

<!-- the following templates are needed since the xsl generated 
     for the specific symbols by expres.xsl calls them --> 


<xsl:template name="print-symbol">
  <xsl:param name="print-form"/>
  <xsl:value-of disable-output-escaping="yes" select="$print-form"/>
</xsl:template>

<xsl:template name="print-fence">
  <xsl:param name="fence"/>
  <xsl:value-of disable-output-escaping="yes" select="$fence"/>
 </xsl:template>

<xsl:template name="print-separator">
  <xsl:param name="separator"/>
  <xsl:value-of disable-output-escaping="yes" select="$separator"/>
</xsl:template>

<!-- these templates take care of format-specific argument grouping -->
<xsl:template name="barg-group"/>
<xsl:template name="earg-group"/>


</xsl:stylesheet>




