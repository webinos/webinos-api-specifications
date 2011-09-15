<?xml version="1.0" encoding="utf-8"?>
<!--====================================================================
$Id: widlprocxmltohtml.xsl 407 2009-10-26 13:48:48Z tpr $
Copyright 2009 Aplix Corporation. All rights reserved.
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

XSLT stylesheet to convert widlprocxml into html documentation.
=====================================================================-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html" encoding="utf-8" indent="yes" doctype-public="html"/>

<xsl:param name="date" select="'error: missing date'"/>

<!--<xsl:variable name="title" select="concat('The Webinos ',/Definitions/*[1]/@name,' Module - Version ',/Definitions/Module/descriptive/version)"/>-->
<!--<xsl:variable name="title" select="concat('The Webinos ',/Definitions/*[1]/@name,' module - ',/Definitions/Module/descriptive/version)"/>-->
<xsl:variable name="title" select="concat('APIs: The ',/Definitions/*[1]/@name,' module')"/>

<xsl:variable name="exception-section-number" select="3 + (count(/Definitions/Module/Typedef) &gt; 0)"/>

<xsl:variable name="api-features-section-number" select="$exception-section-number + (count(/Definitions/Module/Exception) &gt; 0)" />

<xsl:variable name="full-webidl-section-number" select="$api-features-section-number + 1" />


<!--Root of document.-->
<xsl:template match="/">
    <html>
        <head>
            <link rel="stylesheet" type="text/css" href="webinos-apis.css" media="screen"/>
            <script type="text/javascript" src="webinos-apis.js"></script>
            <title>
                <xsl:value-of select="$title"/>
            </title>
        </head>
        <body id="content" onload='prettyPrint()'>
            <xsl:apply-templates/>
        </body>
    </html>
</xsl:template>

<!--Module: a whole API.-->
<xsl:template match="Module">
    <div class="api" id="{@id}">
      <div>
        <a href="http://webinos.org"><img src="http://webinos.org/wp-content/uploads/2011/press_releases/webinos_thumb_150x48.png" alt="Webinos Logo"/></a>
        <h1><xsl:value-of select="$title"/></h1>
        <h2 class="head">Webinos API Specifications</h2>
        <h3><xsl:value-of select="$date"/></h3>
      </div>

        <h2>Authors</h2>
        <ul class="authors">
          <xsl:apply-templates select="descriptive/author"/>
        </ul>

        <div><p class="copyright"><small>© 2011 webinos consortium, www.webinos.org.</small></p> </div>

        <hr/>

        <h2>Abstract</h2>

        <xsl:apply-templates select="descriptive/brief"/>

        <h2>Table of Contents</h2>
        <ul class="toc">
         <!--<li> <a href="#method-summary">Method Summary</a></li>-->

          <li>1. <a href="#intro">Introduction</a></li>
          <li>2. <a href="#interfaces">Interfaces</a>
          <ul class="toc">
          <xsl:for-each select="Interface[descriptive]">
            <li>2.<xsl:number value="position()"/>. <a href="#{@id}"><xsl:value-of select="@name"/></a></li>
          </xsl:for-each>
          </ul>
          </li>
          <xsl:if test="Typedef">
          <li>3. <a href="#typedefs">Type Definitions</a>
            <ul class="toc">
              <xsl:for-each select="Typedef[descriptive]">
                <li>3.<xsl:number value="position()"/>. <a href="#{@id}"><xsl:value-of select="@name"/></a></li>
              </xsl:for-each>
            </ul>
            </li>
          </xsl:if>
          <xsl:if test="Exception">
          <li><xsl:value-of select="$exception-section-number"/>. <a href="#exceptions">Exceptions</a>
            <ul class="toc">
              <xsl:for-each select="Exception">
                <li><xsl:value-of select="$exception-section-number"/>.<xsl:number value="position()"/>. <a href="#{@id}"><xsl:value-of select="@name"/></a></li>
              </xsl:for-each>
            </ul>
            </li>
          </xsl:if>

          <li><xsl:number value="$api-features-section-number"/>. <a href="#api-features">Features</a></li>
          <li><xsl:number value="$full-webidl-section-number"/>. <a href="#full-webidl">Full WebIDL</a></li>
        </ul>

        <hr/>

       
        <h2 id="method-summary">Summary of Methods</h2>
        <xsl:call-template name="summary"/>

       <h2 id="intro">1. Introduction</h2>
        <xsl:apply-templates select="descriptive/description"/>
        <xsl:apply-templates select="descriptive/Code"/>

        <h2 id="interfaces">2. Interfacesx</h2>
        <xsl:apply-templates select="Interface|Dictionary"/>

        <xsl:if test="Typedef">
            <div class="typedefs" id="typedefs">
                <h2>3. Type Definitions</h2>
                <xsl:apply-templates select="Typedef[descriptive]"/>
            </div>
        </xsl:if>

	<xsl:if test="Exception">
            <div class="exceptions" id="exceptions">
                <h2><xsl:value-of select="$exception-section-number"/>. Exceptions</h2>
                <xsl:apply-templates select="Exception"/>
            </div>

	</xsl:if>

        <h2 id="api-features"><xsl:value-of select="$api-features-section-number"/>. Features</h2>

        <xsl:if test="descriptive/def-api-feature">
            <div id="def-api-features" class="def-api-features">
                <xsl:apply-templates select="Interface/descriptive/def-instantiated"/>
                <p>This is the list of URIs used to declare this API's features, for use in the widget config.xml and as identifier for service type in service discovery functionality. For each URI, the list of functions covered is provided.</p>
                <xsl:apply-templates select="descriptive/def-api-feature"/>
            </div>
        </xsl:if>



        <h2 id="full-webidl"><xsl:value-of select="$full-webidl-section-number"/>. Full WebIDL</h2>
        <xsl:apply-templates select="/Definitions/Module/webidl"/>


    </div>
</xsl:template>

<!--def-api-feature-->
<xsl:template match="def-api-feature">
      <dl class="def-api-feature">
          <dt><xsl:value-of select="@identifier"/></dt>
          <dd>
            <xsl:apply-templates select="descriptive/brief"/>
            <xsl:apply-templates select="descriptive"/>
            <xsl:apply-templates select="descriptive/Code"/>
            <xsl:if test="descriptive/device-cap">
              <div class="device-caps">
                <p>
                  Device capabilities:
                </p>
                <ul>
                  <xsl:for-each select="descriptive/device-cap">
                    <li><code><xsl:value-of select="@identifier"/></code></li>
                  </xsl:for-each>
                </ul>
              </div>
            </xsl:if>
          </dd>
      </dl>
</xsl:template>

<xsl:template match="Exception">
  <div class="exception" id="{@id}">
        <h3><xsl:value-of select="$exception-section-number" />.<xsl:number value="position()"/>. <xsl:value-of select="@name"/></h3>
        <xsl:apply-templates select="descriptive/brief"/>
        <xsl:apply-templates select="webidl"/>
        <xsl:apply-templates select="descriptive"/>
        <xsl:apply-templates select="descriptive/Code"/>
        <xsl:if test="ExceptionField/descriptive">
            <div class="fields">
                <h4>Field</h4>
                <dl>
                  <xsl:apply-templates select="ExceptionField"/>
                </dl>
            </div>
        </xsl:if>

  </div>

</xsl:template>

<!--ExceptionField-->
<xsl:template match="ExceptionField">
    <dt class="attribute" id="{concat(parent::*/@name,'_',@name)}">
        <code>
        <span class='attrName'><b>
            <xsl:apply-templates select="Type"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="@name"/>
        </b></span>
        </code></dt>
        <dd>
          <xsl:apply-templates select="descriptive/brief"/>
          <xsl:apply-templates select="descriptive"/>
          <xsl:apply-templates select="descriptive/Code"/>
        </dd>
</xsl:template>


<!--Typedef.-->
<xsl:template match="Typedef[descriptive]">
    <div class="typedef" id="{@id}">
        <h3>3.<xsl:number value="position()"/>. <xsl:value-of select="@name"/></h3>
        <xsl:apply-templates select="descriptive/brief"/>
        <xsl:apply-templates select="webidl"/>
        <xsl:apply-templates select="descriptive"/>
        <xsl:apply-templates select="descriptive/Code"/>
    </div>
</xsl:template>

<!--Interface and Dictionary.-->
<xsl:template match="Interface[descriptive]|Dictionary[descriptive]">
    <xsl:variable name="name" select="@name"/>
    <div class="interface" id="{@id}">
        <h3><xsl:value-of select="concat('2.',1+count(preceding::Interface) + count(preceding::Dictionary))"/>. <xsl:value-of select="local-name()"/> <xsl:value-of select="@name"/><xsl:if test="@partial"> (partial interface)</xsl:if></h3>
        <xsl:apply-templates select="descriptive/brief"/>
        <xsl:apply-templates select="webidl"/>
        <xsl:apply-templates select="../Implements[@name2=$name]/webidl"/>
        <xsl:apply-templates select="descriptive"/>
        <xsl:apply-templates select="descriptive/Code"/>
        <xsl:apply-templates select="InterfaceInheritance"/>
        <xsl:if test="Const/descriptive">
            <div class="consts">
                <h4>Constants</h4>
                <dl>
                  <xsl:apply-templates select="Const"/>
                </dl>
            </div>
        </xsl:if>
        <xsl:if test="Attribute/descriptive">
            <div class="attributes">
                <h4>Attributes</h4>
                <dl>
                  <xsl:apply-templates select="Attribute"/>
                </dl>
            </div>
        </xsl:if>
        <xsl:if test="DictionaryMember/descriptive">
            <div class="attributes">
                <h4>Dictinary Members</h4>
                <dl>
                  <xsl:apply-templates select="DictionaryMember"/>
                </dl>
            </div>
        </xsl:if>

        <xsl:if test="Operation/descriptive">
            <div class="methods">
                <h4>Methods</h4>
                <dl>
                  <xsl:apply-templates select="Operation"/>
                </dl>
            </div>
        </xsl:if>
    </div>
</xsl:template>
<xsl:template match="Interface[not(descriptive)]">
</xsl:template>

<xsl:template match="InterfaceInheritance/ScopedNameList">
              <p>
                <xsl:text>This interface inherits from: </xsl:text>
                <xsl:for-each select="Name">
                  <code><xsl:value-of select="@name"/></code>
                  <xsl:if test="position!=last()">, </xsl:if>
                </xsl:for-each>
              </p>
</xsl:template>

<!--Attribute and DictionaryMember -->
<xsl:template match="Attribute|DictionaryMember">
    <dt class="attribute" id="{concat(parent::*/@name,'_',@name)}">
        <code>
        <span class='attrName'><b>
            <xsl:if test="@stringifier">
                stringifier
            </xsl:if>
            <xsl:if test="@readonly">
                readonly
            </xsl:if>
            <xsl:apply-templates select="Type"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="@name"/>
        </b></span>
        </code></dt>
        <dd>
          <xsl:apply-templates select="descriptive/brief"/>
          <xsl:apply-templates select="descriptive"/>
          <xsl:apply-templates select="GetRaises"/>
          <xsl:apply-templates select="SetRaises"/>
          <xsl:if test="@readonly">
                This attribute is readonly.
          </xsl:if>
          <xsl:apply-templates select="descriptive/Code"/>
        </dd>
</xsl:template>

<!--Const-->
<xsl:template match="Const">
  <dt class="const" id="{@id}">
    <code>
      <xsl:apply-templates select="Type"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="@name"/>
    </code>
  </dt>
  <dd>
    <xsl:apply-templates select="descriptive/brief"/>
    <xsl:apply-templates select="descriptive"/>
    <xsl:apply-templates select="descriptive/Code"/>
  </dd>
</xsl:template>

<!--Operation-->
<xsl:template match="Operation">
    <dt class="method" id="{concat(@name,generate-id(.))}">
        <code><b><span class='methodName'><xsl:value-of select="@name"/></span></b></code>
    </dt>
    <dd>
        <xsl:apply-templates select="descriptive/brief"/>
        <div class="synopsis">
            <h5>Signature</h5>
            <pre class="signature prettyprint">
                <xsl:if test="@static">
                    <xsl:value-of select="concat(@static, ' ')"/>
                </xsl:if>
                <xsl:if test="@stringifier">
                    <xsl:value-of select="concat(@stringifier, ' ')"/>
                </xsl:if>
                <xsl:if test="@omittable">
                    <xsl:value-of select="concat(@omittable, ' ')"/>
                </xsl:if>
                <xsl:if test="@getter">
                    <xsl:value-of select="concat(@getter, ' ')"/>
                </xsl:if>
                <xsl:if test="@setter">
                    <xsl:value-of select="concat(@setter, ' ')"/>
                </xsl:if>
                <xsl:if test="@creator">
                    <xsl:value-of select="concat(@creator, ' ')"/>
                </xsl:if>
                <xsl:if test="@deleter">
                    <xsl:value-of select="concat(@deleter, ' ')"/>
                </xsl:if>
                <xsl:if test="@caller">
                    <xsl:value-of select="concat(@caller, ' ')"/>
                </xsl:if>
                <xsl:apply-templates select="Type"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="@name"/>
                <xsl:text>(</xsl:text>
                <xsl:apply-templates select="ArgumentList">
                    <xsl:with-param name="nodesc" select="1"/>
                </xsl:apply-templates>
                <xsl:text>);
</xsl:text></pre>
        </div>
        <xsl:apply-templates select="descriptive"/>
        <xsl:apply-templates select="ArgumentList"/>
        <xsl:if test="Type/descriptive">
          <div class="returntype">
            <h5>Return value</h5>
            <xsl:apply-templates select="Type/descriptive"/>
          </div>
        </xsl:if>
        <xsl:apply-templates select="Raises"/>
        <xsl:if test="descriptive/api-feature">
            <div class="api-features">
                <h5>API features</h5>
                <dl>
                    <xsl:apply-templates select="descriptive/api-feature"/>
                </dl>
            </div>
        </xsl:if>
        <xsl:apply-templates select="descriptive/Code"/>
    </dd>
</xsl:template>

<!--ArgumentList. This is passed $nodesc=true to output just the argument
    types and names, and not any documentation for them.-->
<xsl:template match="ArgumentList">
    <xsl:param name="nodesc"/>
    <xsl:choose>
        <xsl:when test="$nodesc">
            <!--$nodesc is true: just output the types and names-->
            <xsl:apply-templates select="Argument[1]">
                <xsl:with-param name="nodesc" select="'nocomma'"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="Argument[position() != 1]">
                <xsl:with-param name="nodesc" select="'comma'"/>
            </xsl:apply-templates>
        </xsl:when>
        <xsl:when test="Argument">
            <!--$nodesc is false: output the documentation-->
            <div class="parameters">
                <h5>Parameters</h5>
                <ul>
                    <xsl:apply-templates/>
                </ul>
            </div>
        </xsl:when>
    </xsl:choose>
</xsl:template>

<!--Argument. This is passed $nodesc=false to output the documentation,
    or $nodesc="nocomma" to output the type and name, or $nodesc="comma"
    to output a comma then the type and name. -->
<xsl:template match="Argument">
    <xsl:param name="nodesc"/>
    <xsl:choose>
        <xsl:when test="$nodesc">
            <!--$nodesc is true: just output the types and names-->
            <xsl:if test="$nodesc = 'comma'">
                <!--Need a comma first.-->
                <xsl:text>, </xsl:text>
            </xsl:if>
            <xsl:if test="@in"><xsl:value-of select="concat(@in, ' ')"/></xsl:if>
            <xsl:if test="@optional"><xsl:value-of select="concat(@optional, ' ')"/></xsl:if>
            <xsl:apply-templates select="Type"/>
            <xsl:if test="@ellipsis"><xsl:text>...</xsl:text></xsl:if>
            <xsl:text> </xsl:text>
            <xsl:value-of select="@name"/>
        </xsl:when>
        <xsl:otherwise>
            <!--$nodesc is false: output the documentation-->
            <li class="param">
                <b><xsl:value-of select="@name"/></b>
                <ul>
                <li><b>Optional: </b>
                <xsl:choose>
                <xsl:when test="@optional">Yes.</xsl:when>
                <xsl:otherwise>No.</xsl:otherwise>
                </xsl:choose>
                </li>
		<li><b>Nullable</b>: <xsl:choose><xsl:when test="Type/@nullable">Yes</xsl:when><xsl:otherwise>No</xsl:otherwise></xsl:choose></li>
                <li><b>Type: </b>
<!--<xsl:value-of select="Type/@name"/><xsl:value-of select="Type/@type"/>-->
                <xsl:call-template name="refToLink">
		  <xsl:with-param name="reference-name" select="concat(Type/@name, Type/@type)"/>
		</xsl:call-template>
                </li>
                <li><b>Description: </b>
                <xsl:apply-templates select="descriptive"/>
                </li></ul>
            </li>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>



<!--Raises (for an Operation). It is already known that the list
    is not empty.-->
<xsl:template match="Raises">
    <div class="exceptionlist">
        <h5>Exceptions</h5>
        <ul>
            <xsl:apply-templates/>
        </ul>
    </div>
</xsl:template>

<!--RaiseException, the name of an exception in a Raises.-->
<xsl:template match="RaiseException">
    <li class="exception">
        <xsl:value-of select="@name"/>:
        <xsl:apply-templates select="descriptive"/>
    </li>
</xsl:template>

<!--Type.-->
<xsl:template match="Type">
    <xsl:choose>
        <xsl:when test="@type='sequence'">
            <xsl:text>sequence &lt;</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>></xsl:text>
        </xsl:when>
        <xsl:when test="@type='array'">
            <xsl:apply-templates/>
            <xsl:text>[]</xsl:text>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="@name"/>
            <xsl:value-of select="@type"/>
            <xsl:if test="@nullable">
                <xsl:text>?</xsl:text>
            </xsl:if>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="descriptive[not(author)]">
  <xsl:apply-templates select="version"/>
  <xsl:if test="author">
  </xsl:if>
  <xsl:apply-templates select="description"/>
</xsl:template>

<!--brief-->
<xsl:template match="brief">
    <div class="brief">
        <p>
            <xsl:apply-templates/>
        </p>
    </div>
</xsl:template>

<!--description in ReturnType or Argument or ScopedName-->
<xsl:template match="Type/descriptive/description|Argument/descriptive/description|Name/descriptive/description">
    <!--If the description contains just a single <p> then we omit
        the <p> and just do its contents.-->
    <xsl:choose>
        <xsl:when test="p and count(*) = 1">
            <xsl:apply-templates select="p/*|p/text()"/>
        </xsl:when>
        <xsl:otherwise>
            <div class="description">
                <xsl:apply-templates/>
            </div>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!--Other description-->
<xsl:template match="description">
    <div class="description">
        <xsl:apply-templates/>
    </div>
</xsl:template>

<!--Code-->
<xsl:template match="Code">
    <div class="example">
        <h5>Code example</h5>
        <pre name='code' class="examplecode prettyprint"><xsl:apply-templates/></pre>
    </div>
</xsl:template>

<!--webidl : literal Web IDL from input-->
<xsl:template match="webidl">
    <pre class="webidl prettyprint"><xsl:apply-templates/></pre>
</xsl:template>

<!--author-->
<xsl:template match="author">
    <li class="author"><xsl:apply-templates/></li>
</xsl:template>

<!--version-->
<xsl:template match="version">
    <div class="version">
        <h2>
            Version: <xsl:apply-templates/>
        </h2>
    </div>
</xsl:template>

<!--api-feature-->
<xsl:template match="api-feature">
    <dt>
        <xsl:value-of select="@identifier"/>
    </dt>
    <dd>
        <xsl:apply-templates/>
    </dd>
</xsl:template>

<!--param-->
<xsl:template match="param">
    <li>
        <code><xsl:value-of select="@identifier"/></code>:
        <xsl:apply-templates/>
    </li>
</xsl:template>

<!--def-instantiated (called from Module).
    This assumes that only one interface in the module has a def-instantiated,
    and that interface contains just one attribute.-->
<xsl:template match="def-instantiated">
    <xsl:variable name="ifacename" select="../../@name"/>
    <p>
        <xsl:choose>
            <xsl:when test="count(descriptive/api-feature)=1">
                When the feature
            </xsl:when>
            <xsl:otherwise>
                When any of the features
            </xsl:otherwise>
        </xsl:choose>
    </p>
    <ul>
        <xsl:for-each select="descriptive/api-feature">
            <li><code>
                <xsl:value-of select="@identifier"/>
            </code></li>
        </xsl:for-each>
    </ul>
    <p>
        or any of the features hierarchically under that feature is successfully requested, the interface
        <code><xsl:apply-templates select="../../Attribute/Type"/></code>
        is instantiated, and the resulting object appears in the global
        namespace as
        <!--<code><xsl:value-of select="../../../Implements[@name2=$ifacename]/@name1"/>.<xsl:value-of select="../../Attribute/@name"/></code>.-->
        <code><xsl:value-of select="translate(../../../Implements[@name2=$ifacename]/@name1, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>.<xsl:value-of select="../../Attribute/@name"/></code>.
    </p>
</xsl:template>



<!--html elements-->
<xsl:template match="a|b|br|dd|dl|dt|em|li|p|table|td|th|tr|ul|img">
    <xsl:element name="{name()}"><xsl:for-each select="@*"><xsl:attribute name="{name()}"><xsl:value-of select="."/></xsl:attribute></xsl:for-each><xsl:apply-templates/></xsl:element>
</xsl:template>

<xsl:template name="summary">
  <table class="informaltable">
    <thead>
      <tr><th>Interface</th><th>Method</th></tr>
    </thead>
    <tbody>
      <xsl:for-each select="Interface[descriptive]">
        <tr><td><a href="#{@id}"><xsl:value-of select="@name"/></a></td>
        <td>
          <xsl:for-each select="Operation">

            <xsl:apply-templates select="Type"/>
            <xsl:text> </xsl:text>
            <a href="#{concat(@name,generate-id(.))}"><xsl:value-of select="@name"/></a>
            <xsl:text>(</xsl:text>
            <xsl:for-each select="ArgumentList/Argument">
              <xsl:variable name="type"><xsl:apply-templates select="Type"/></xsl:variable>
              <xsl:value-of select="concat(normalize-space($type),' ',@name)"/>
              <xsl:if test="position() != last()">, </xsl:if>
            </xsl:for-each>
            <xsl:text>)</xsl:text>
            <xsl:if test="position()!=last()"><br/></xsl:if>
          </xsl:for-each>
        </td>
        </tr>
      </xsl:for-each>
    </tbody>
  </table>
</xsl:template>

<!--<ref> element in literal Web IDL.-->
<!-- start Kevin Smith insert 20 Oct 2010
    Adds a link to the specification text for every inline reference
 -->
<xsl:key name="reference-link-key" match="Interface | Typedef | Exception" use="@name"/>

<xsl:template match="ref">
  <xsl:call-template name="refToLink">
    <xsl:with-param name="reference-name" select="."/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="refToLink">
    <xsl:param name="reference-name"/>

    <xsl:variable name="reference-clean">
      <xsl:choose>
        <xsl:when test="substring($reference-name, (string-length($reference-name) - string-length('DOMString?'))+1) = 'DOMString?'">
          <xsl:value-of select="$reference-name"/>
        </xsl:when>
        <xsl:when test="substring($reference-name, (string-length($reference-name) - string-length('?'))+1) = '?'">
          <xsl:value-of select="substring($reference-name,1,(string-length($reference-name)-1))"/>
        </xsl:when>
        <xsl:otherwise> 
          <xsl:value-of select="$reference-name"/> 
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
    <xsl:when test="$reference-clean='DOMString?'">
                    <xsl:value-of select="$reference-name"/>
    </xsl:when>
    <xsl:when test="$reference-clean='DeviceAPIError'">
                  <a href="deviceapis.html#::deviceapis::DeviceAPIError">
                    <xsl:value-of select="$reference-name"/>
                  </a>
    </xsl:when>
    <xsl:when test="$reference-clean='Date'">
                  <!--<a href="deviceapis.html#::deviceapis::DeviceAPIError">-->
                    <xsl:value-of select="$reference-clean"/>
                  <!--</a>-->
    </xsl:when>
    <xsl:when test="$reference-clean='HTMLElement'">
                    <xsl:value-of select="$reference-clean"/>
    </xsl:when>
    <xsl:when test="$reference-clean='Event'">
      <a href="http://www.w3.org/TR/DOM-Level-3-Events/#events-Event">
                    <xsl:value-of select="$reference-clean"/>
      </a>
    </xsl:when>
    <xsl:when test="$reference-clean='EventListener'">
      <a href="http://www.w3.org/TR/DOM-Level-3-Events/#interface-EventListener">
                    <xsl:value-of select="$reference-clean"/>
      </a>
    </xsl:when>
    <xsl:when test="$reference-clean='EventTarget'">
      <a href="http://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html#eventtarget">
                    <xsl:value-of select="$reference-clean"/>
      </a>
    </xsl:when>

    <xsl:when test="$reference-clean='Window'">
                    <xsl:value-of select="$reference-clean"/>
    </xsl:when>
    <xsl:when test="$reference-clean='Object'">
                    <xsl:value-of select="$reference-clean"/>
    </xsl:when>
    <xsl:when test="key('reference-link-key',$reference-clean)">
                  <a href="#{key('reference-link-key',$reference-clean)[1]/@id}">
                    <xsl:value-of select="$reference-name"/>
                  </a>
    </xsl:when>
    <xsl:otherwise> 
      <xsl:variable name="link">
      <xsl:for-each select="document('widlprocxmlsources.xml')/widlprocxml/file">
        <xsl:variable name="widlprocfile" select="substring-before(.,'.widlprocxml')"/>
        <xsl:for-each select="document(.)[key('reference-link-key',$reference-clean)]">
            <xsl:for-each select="key('reference-link-key',$reference-clean)">
                  <a href="{concat($widlprocfile,'.html#',@id)}">
                    <xsl:value-of select="$reference-name"/>
                  </a>
            </xsl:for-each>
        </xsl:for-each>
      </xsl:for-each>
      </xsl:variable>
      <xsl:choose>
	<xsl:when test="not(normalize-space($link))">
	  <xsl:value-of select="$reference-name"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:copy-of select="$link"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise> 
    </xsl:choose>

</xsl:template>

<!-- end Kevin Smith insert-->
<!-- Note the following template is redundant as the DTD does not specify a @ref attribute on the ref element-->
<!--<xsl:template match="ref[@ref]">
    <a href="{@ref}">
        <xsl:apply-templates/>
    </a>
</xsl:template>-->

</xsl:stylesheet>

