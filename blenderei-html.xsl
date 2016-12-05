<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xpath-default-namespace="http://www.w3.org/1999/xhtml"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="#all"
  version="2.0">
  
  <xsl:param name="navdepth" select="2"/>
  
  <xsl:output method="xhtml" indent="no"/>

  <xsl:variable name="root" select="/" as="document-node(element(html))"/>

  <xsl:variable name="lang" as="xs:string" select="replace(base-uri(), '^.+\.(\p{Ll}{2})\.html$', '$1')"/>

  <xsl:variable name="supported-langs" as="xs:string+" select="('de', 'en')"/>

  <xsl:template match="/">
    <xsl:variable name="other-lang-docs" as="document-node(element(html:html))*" 
      select="for $other-lang in $supported-langs[not(. = $lang)]
              return if (doc-available(resolve-uri(concat('index.', $other-lang, '.html'), base-uri())))
                      then doc(resolve-uri(concat('index.', $other-lang, '.html'), base-uri()))
                      else ()"/>
    <xsl:result-document href="htdocs/{$lang}/index.html">
      <xsl:apply-templates select="/" mode="export">
        <xsl:with-param name="other-lang-docs" select="$other-lang-docs" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:result-document>
    <xsl:result-document href="images.txt" method="text">
      <xsl:sequence select="string-join(//img/@src[not(matches(., 'https?:'))], '&#xa;')"/>
    </xsl:result-document>
    <xsl:apply-templates select="html/body//section[@id]">
      <xsl:with-param name="other-lang-docs" select="$other-lang-docs" tunnel="yes"/>
    </xsl:apply-templates>    
  </xsl:template>
  
  <xsl:template match="section[@id]">
    <xsl:param name="section" as="element(section)?" tunnel="yes"/>
    <xsl:result-document href="htdocs/{$lang}/{@id}.html">
      <xsl:apply-templates select="/" mode="export">
        <xsl:with-param name="section" select="." tunnel="yes" as="element(section)"/>
      </xsl:apply-templates>
    </xsl:result-document>
  </xsl:template>
  
  <xsl:template match="* | @*" mode="export replicate nav-headings">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="head/title" mode="export">
    <xsl:next-match/>
    <xsl:variable name="libs" as="element(*)*">
      <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"/>
      <script type="text/javascript" src="htdocs/light-gallery/js/lightGallery.js"/>
      <link rel="stylesheet" type="text/css" href="htdocs/light-gallery/css/lightGallery.css"/>
    </xsl:variable>
    <xsl:apply-templates select="$libs" mode="#current"/>
  </xsl:template>

  <xsl:template match="section[@id]" mode="export">
    <xsl:param name="section" as="element(section)?" tunnel="yes"/>
    <xsl:choose>
      <xsl:when test="not($section) and . is ancestor::body/section[1]">
        <!-- writing the index page -->
        <xsl:comment>orig A</xsl:comment>
        <nav>
          <ul>
            <xsl:apply-templates select="ancestor::body/section" mode="nav"/>
          </ul>
        </nav>
      </xsl:when>
      <xsl:when test="not(. is $section) and count(ancestor::section) &gt;= 1">
        <!-- in the reference subcategory pages, creating links to the subsections -->
        <xsl:comment>orig B</xsl:comment>
        <p class="link">
          <a href="{@id}.html">
            <xsl:apply-templates select="*[1]/node()" mode="#current"/>
            <!--<xsl:apply-templates select="(.//img)[1]" mode="replicate"/>-->
          </a>
        </p>
      </xsl:when>
      <xsl:when test=". is $section 
                      and 
                      (
                        count(ancestor::section) &gt;= $navdepth - 1
                        or
                        $section/../@id = 'exhibitions'
                      )">
        <!-- below first level -->
        <xsl:comment>orig C</xsl:comment>
        <xsl:copy>
          <xsl:apply-templates select="@* except @id" mode="export"/>
          <xsl:for-each-group select="*" group-adjacent="exists(self::section[not(@id)])">
            <xsl:choose>
              <xsl:when test="current-grouping-key()">
                <div class="cols">
                  <xsl:apply-templates select="current-group()" mode="#current"/>
                </div>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="current-group()" mode="#current"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each-group>
        </xsl:copy>
      </xsl:when>
      <!--<xsl:when test="some $s in descendant::section satisfies ($s is $section)
                      and count(ancestor::section) = 0">
        <!-\- Suppress "Referenzen" -\->
        <xsl:comment>orig D.2 not rendered: <xsl:value-of select="*[1]"/></xsl:comment>
        <xsl:apply-templates select="section[exists(. intersect $section/ancestor-or-self::section)]" mode="#current"/>
      </xsl:when>-->
      <xsl:when test="some $s in descendant::section satisfies ($s is $section)">
        <!-- This result page’s $section comes below the currently transformed section.
        Only render the heading and process the sections that are between the current and
        $section.
        If there were leaf sections that don’t get their own result pages, we’d just 
        do an apply-templates in #current mode here and be done with it. -->
        <xsl:comment>orig D</xsl:comment>
        <xsl:apply-templates select="*[1], section[exists(. intersect $section/ancestor-or-self::section)]" mode="#current"/>
      </xsl:when>
      <xsl:when test=". is $section">
        <!-- writing $section -->
        <xsl:comment>orig E</xsl:comment>
        <nav>
          <ul>
            <xsl:apply-templates select="ancestor::body/section" mode="nav"/>
          </ul>
        </nav>
        <xsl:choose>
          <xsl:when test="count($section/ancestor::section) &gt; $navdepth">
            <xsl:comment>orig E.1</xsl:comment>
            <xsl:apply-templates mode="#current"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:comment>orig E.2</xsl:comment>
            <main>
              <div>
                <xsl:apply-templates mode="#current"/>
              </div>
              <p class="home" title="close box">
                <a href="index.html">✘</a>
              </p>
            </main>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="section" mode="nav">
    <li>
      <xsl:apply-templates select="*[1]" mode="#current"/>
        <!--<xsl:if test="section and count(ancestor::section) &lt; $navdepth - 1">
          <ul>
            <xsl:apply-templates select="section" mode="#current"/>
          </ul>
        </xsl:if>-->
    </li>
  </xsl:template>
  
  <xsl:template match="span[html:contains-token(@class, 'subtitle')]" mode="nav-headings"/>
  
  <xsl:template match="*" mode="nav"><!-- Supposed to match headings only -->
    <xsl:param name="section" as="element(section)?" tunnel="yes"/>
    <xsl:choose>
      <xsl:when test=".. is $section">
        <xsl:apply-templates mode="nav-headings"/>
      </xsl:when>
      <!--<xsl:when test="..[section[count(ancestor::section) &lt;= $navdepth]]
                      and (every $item in (../* except current()) satisfies ($item/self::section))">
        <!-\- There are subsections with their own nav links; no other content to display -\->
        <xsl:apply-templates/>
      </xsl:when>-->
      <xsl:otherwise>
        <a href="{../@id}.html">
          <xsl:apply-templates mode="nav-headings"/>
        </a>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:key name="pagelink" match="section[@id]" use="concat('#', @id)"/>
  
  <xsl:template match="body" mode="export">
    <xsl:param name="section" as="element(section)?" tunnel="yes"/>
    <xsl:param name="other-lang-docs" as="document-node(element(html:html))*" tunnel="yes"/>
    <xsl:copy>
      <xsl:apply-templates select="@*, $section/@id" mode="#current"/>
      <xsl:choose>
        <xsl:when test="exists($section/ancestor::section)">
          <xsl:attribute name="class" select="'detail'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="class" select="'general'"/>
        </xsl:otherwise>
      </xsl:choose>
      <div class="bg">
        <div class="langselect">
          <p>
            <xsl:attribute name="title">
              <xsl:choose>
                <xsl:when test="$lang = 'de'">
                  <xsl:sequence select="'aktuelle Sprache'"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:sequence select="'current language'"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <xsl:value-of select="$lang"/>
            <xsl:for-each select="if ($section) then $other-lang-docs//@id[. = $section/@id] else $other-lang-docs/html:html/@lang">
              <xsl:variable name="other-lang" as="xs:string" select="root(.)/html:html/@lang"/>
              <xsl:text>&#x2003;</xsl:text>
              <a href="../{$other-lang}/{if ($section) then string(.) else 'index'}.html">
                <xsl:attribute name="title">
                  <xsl:choose>
                    <xsl:when test="$lang = 'de'">
                      <xsl:sequence select="'Sprache umschalten'"></xsl:sequence>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:sequence select="'switch language'"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:attribute>
                <xsl:value-of select="$other-lang"/>
              </a>
            </xsl:for-each>
          </p>
        </div>
        <xsl:apply-templates mode="#current"/>  
      </div>
      <script type="text/javascript">
      $(document).ready(function() {
        $(".lightbox").lightGallery({
          <!--pagination : {
            add        : true,
            type       : "thumbnails"
          }-->
        });
      });
    </script>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="img[html:contains-token(@class, 'bg')]" mode="export">
    <xsl:param name="section" as="element(section)?" tunnel="yes"/>
    <xsl:if test="not($section/@id = 'ellikurush')">
      <xsl:next-match/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="h1" mode="export">
    <xsl:param name="section" as="element(section)?" tunnel="yes"/>
    <xsl:choose>
      <xsl:when test="$section">
        <h1>
          <a href="{($section/ancestor::section[last()]/@id, 'index')[1]}.html">
            <xsl:attribute name="title">
              <xsl:choose>
                <xsl:when test="$lang = 'de'">
                  <xsl:sequence select="'zur Startseite gehen'"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:sequence select="'go to home page'"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates/>
          </a>
        </h1>        
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="a/@href[key('pagelink', ., $root)]" mode="export">
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
    
  <xsl:template match="@src | @href | @data-src" mode="export replicate">
    <xsl:attribute name="{name()}" select="replace(., '^htdocs/', '../')"/>
  </xsl:template>
  
  <xsl:template match="title" mode="export">
    <xsl:param name="section" as="element(section)?" tunnel="yes"/>
    <xsl:variable name="heading" as="element(*)?" 
      select="$section/*[1][matches(name(), '^h\d$')][normalize-space()]"/>
    <xsl:choose>
      <xsl:when test="$heading">
        <xsl:copy>
          <xsl:value-of select="string-join(
                                  (
                                    replace(
                                      $heading, 
                                      '[\p{Zs}\s]+', 
                                      ' '
                                    ),
                                    .
                                  ),
                                  ' – '
                                )"/>
        </xsl:copy>    
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="div[html:contains-token(@class, 'lightbox')]" mode="export">
    <xsl:next-match>
      <xsl:with-param name="preview-image" as="element(img)" tunnel="yes"
        select="(*[html:contains-token(@class, 'featured')], figure[1])[1]//img"/>
      <xsl:with-param name="rendered" as="element(*)*" tunnel="yes"
        select="figure[1]"/>
    </xsl:next-match>
  </xsl:template>

  <xsl:template match="div[html:contains-token(@class, 'lightbox')]/figure" mode="export">
    <xsl:param name="rendered" as="element(figure)*" tunnel="yes"/>
    <xsl:variable name="class" as="xs:string" 
      select="string-join((@class, 'hidden'[every $r in $rendered satisfies not($r is current())]), ' ')"/>
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:if test="$class">
        <xsl:attribute name="class" select="$class"/>
      </xsl:if>
      <xsl:attribute name="data-src">
        <xsl:apply-templates select="(.//img | .//video)[1]/@src" mode="#current"/>
      </xsl:attribute>
      <xsl:attribute name="data-sub-html" select="'.caption'"/>
      <xsl:attribute name="title" select="normalize-space(figcaption)"/>
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="pos" as="xs:integer" select="html:index-of(../figure, .)" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="figure/footer" mode="export"/>

  <xsl:template match="div[html:contains-token(@class, 'lightbox')]/figure//video" mode="export"/>

  <xsl:template match="div[html:contains-token(@class, 'lightbox')]/figure//img" mode="export">
    <xsl:param name="pos" as="xs:integer" tunnel="yes"/>
    <xsl:param name="preview-image" as="element(img)" tunnel="yes"/>
    <xsl:choose>
      <xsl:when test="$pos = 1">
        <xsl:for-each select="$preview-image">
          <xsl:call-template name="img"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="img"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="img">
    <a href="#">
      <xsl:copy>
        <xsl:apply-templates select="@* except @style" mode="#current"/>
        <xsl:attribute name="alt" select="normalize-space(ancestor::figure/figcaption)"/>
      </xsl:copy>
    </a>
  </xsl:template>

  <xsl:template match="div[html:contains-token(@class, 'lightbox')]/figure/figcaption" mode="export">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:attribute name="onclick" select="'this.style.display=''none'''"></xsl:attribute>
      <xsl:attribute name="class" select="string-join((@class, 'caption'), ' ')"/>
      <xsl:apply-templates mode="#current"/>
      <xsl:apply-templates select="../footer/small" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="img" mode="replicate">
    <xsl:copy>
      <xsl:apply-templates select="@* except @style" mode="#current"/>
      <xsl:attribute name="class" select="string-join((@class, 'preview'), ' ')"/>  
    </xsl:copy>
  </xsl:template>

  <xsl:function name="html:contains-token" as="xs:boolean">
    <xsl:param name="tokens" as="xs:string?"/>
    <xsl:param name="token" as="xs:string?"/>
    <xsl:sequence select="tokenize($tokens, '\s+') = $token"/>
  </xsl:function>
  
  <xsl:function name="html:index-of" as="xs:integer*">
    <xsl:param name="nodes" as="node()*"/>
    <xsl:param name="node" as="node()"/>
    <xsl:sequence select="index-of(for $n in $nodes return generate-id($n), generate-id($node))"/>
  </xsl:function>
  
</xsl:stylesheet>