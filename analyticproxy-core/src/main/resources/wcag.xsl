<?xml version="1.0" encoding="ISO-8859-1"?> 
<xsl:stylesheet
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xhtml="http://www.w3.org/1999/xhtml"
xmlns="http://www.w3.org/1999/xhtml"
xmlns:exsltstring="http://exslt.org/strings"
xmlns:saxon="http://icl.com/saxon"
version="1.1"> 
 
<!--
WAEX: Web Accessibility Evaluator in a single XSLT file
Available at http://www.it.uc3m.es/vlc/waex.html
Released under Creative commons licence
http://creativecommons.org/licenses/by-nc-sa/2.5/
 
Prio 1: 9
Prio 2: 16
Prio 3: 8
WCAG 1.0: 33
--> 
 
<xsl:output method="xml" indent="yes" encoding="iso-8859-1"
   doctype-public="-//W3C//DTD XHTML 1.1//EN" 
   doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"/> 
 
<xsl:template match="text()" /> 
 
<!-- <xsl:param name="level">a</xsl:param> --> 
<!-- <xsl:param name="level">aa</xsl:param> --> 
<!-- <xsl:param name="level">aaa</xsl:param> --> 
<xsl:param name="level">aaaplus</xsl:param> 
 
<xsl:param name="alt_max">100</xsl:param> 
<xsl:param name="title_max">40</xsl:param> 
<xsl:param name="th_max">40</xsl:param> 
<xsl:param name="ff_max">6</xsl:param> 
<xsl:param name="option_max">20</xsl:param> 
 
<xsl:param name="xmlfile"></xsl:param> 
<xsl:param name="mobileok">true</xsl:param> 
 
<xsl:variable name="url"> 
<xsl:choose> 
        <xsl:when test="starts-with($xmlfile, 'http://') or starts-with($xmlfile, 'https://')"> 
		<xsl:value-of select="$xmlfile" /> 
        </xsl:when> 
        <xsl:otherwise></xsl:otherwise> 
</xsl:choose> 
</xsl:variable> 
 
<xsl:variable name="headersdoc"> 
<xsl:choose> 
        <xsl:when test="$mobileok != '' and $url != ''"> 
        <xsl:copy-of select="document(concat('http://cgi.w3.org/cgi-bin/headers?url=',$url))//xhtml:pre" /> 
        </xsl:when> 
        <xsl:otherwise></xsl:otherwise> 
</xsl:choose> 
</xsl:variable> 
 
<xsl:param name="validated"> 
<xsl:choose> 
        <xsl:when test="$url != ''"> 
        <xsl:value-of select="document(concat('http://validator.w3.org/check?charset=%28detect+automatically%29&amp;uri=',$url))//xhtml:*[contains(., 'Congratulations')]" /> 
        </xsl:when> 
        <xsl:otherwise>Congratulations</xsl:otherwise> 
</xsl:choose> 
</xsl:param> 
 
<xsl:param name="validatedbasic11"> 
<xsl:choose> 
        <xsl:when test="$mobileok != '' and $url != ''"> 
        <xsl:value-of select="document(concat('http://validator.w3.org/check?charset=%28detect+automatically%29&amp;doctype=XHTML+Basic+1.1&amp;uri=',$url))//xhtml:*[contains(., 'Congratulations')]" /> 
        </xsl:when> 
        <xsl:otherwise>Congratulations</xsl:otherwise> 
</xsl:choose> 
</xsl:param> 
 
<xsl:param name="cssreport"> 
<xsl:choose> 
        <xsl:when test="$url != ''"> 
        <xsl:value-of select="document(concat('http://jigsaw.w3.org/css-validator/validator?uri=',$url))//xhtml:body" /> 
        </xsl:when> 
        <xsl:otherwise>Congratulations</xsl:otherwise> 
</xsl:choose> 
</xsl:param> 
 
<xsl:variable name="commentlength"> 
        <xsl:variable name="comments"> 
                <xsl:for-each select="//comment()"> 
                        <xsl:value-of select="string-length(.)" /><xsl:text> </xsl:text> 
                </xsl:for-each> 
        </xsl:variable> 
        <xsl:choose> 
        <xsl:when test="function-available('exsltstring:tokenize')"> 
                <xsl:value-of select="sum(exsltstring:tokenize($comments,' '))" /> 
        </xsl:when> 
        <xsl:otherwise><xsl:value-of select="string-length(//comment())" /></xsl:otherwise> 
		<!-- only the first, I am afraid --> 
        </xsl:choose> 
</xsl:variable> 
 
<xsl:variable name="whitespace"> 
        <xsl:value-of select="string-length(//xhtml:html) - string-length(normalize-space(//xhtml:html))" /> 
</xsl:variable> 
 
<xsl:param name="pagesize"> 
<xsl:choose> 
        <xsl:when test="$mobileok != '' and $url != ''"> 
        <xsl:value-of select="number(substring-before(substring-after($headersdoc, 'Content-Length: '), '&#x0A;'))" /> 
        </xsl:when> 
        <xsl:otherwise> 
        <xsl:value-of select="$commentlength + string-length(//xhtml:html)" /> 
		<!-- + the markup, only an estimation, I am afraid --> 
        </xsl:otherwise> 
</xsl:choose> 
</xsl:param> 
 
<xsl:param name="contenttype"><xsl:value-of select="substring-before(substring-after($headersdoc, 'Content-Type: '), '&#x0A;')" /></xsl:param> 
<xsl:param name="refreshheader"><xsl:value-of select="substring-before(substring-after($headersdoc, 'Refresh:'), '&#x0A;')" /></xsl:param> 
<xsl:param name="expires"><xsl:value-of select="substring-before(substring-after($headersdoc, 'Expires: '), '&#x0A;')" /></xsl:param> 
<xsl:param name="cachecontrol"><xsl:value-of select="substring-before(substring-after($headersdoc, 'Cache-Control: '), '&#x0A;')" /></xsl:param> 
<xsl:param name="pragma"><xsl:value-of select="substring-before(substring-after($headersdoc, 'Pragma: '), '&#x0A;')" /></xsl:param> 
<xsl:param name="totalsize">0</xsl:param> 
 
 
<xsl:template match="//xhtml:*" mode="print"> 
	<xsl:if test="function-available('saxon:line-number')"> 
                Line <xsl:value-of select="saxon:line-number()" />.
        </xsl:if> 
	<xsl:element name="samp"> 
	<!-- <xsl:element name="kbd"> --> 
	<!-- <xsl:attribute name="style">color:blue;background:transparent</xsl:attribute> --> 
	<!-- <xsl:attribute name="xml:lang1" select="name(ancestor-or-self::xhtml:*[@xml:lang][1])" /> --> 
	<xsl:if test="ancestor-or-self::xhtml:*[@xml:lang][1]"> 
	<xsl:attribute name="xml:lang"> <xsl:value-of select="ancestor-or-self::xhtml:*[@xml:lang][1]/@xml:lang" /> </xsl:attribute> 
	</xsl:if> 
	<!-- <xsl:value-of select="ancestor-or-self::xhtml:*[@xml:lang][1]/@xml:lang" /> idiom --> 
	<xsl:text>&lt;</xsl:text> 
	<xsl:variable name="printabletag" select="name()"/> 
	<xsl:value-of select="name()" /> 
	<xsl:for-each select="@*"> 
		<xsl:if test="$printabletag = 'area' or name() != 'shape'"> 
			<xsl:text> </xsl:text> 
			<xsl:value-of select="name()" /> 
			<xsl:text>="</xsl:text> 
			<xsl:value-of select="." /> 
			<xsl:text>"</xsl:text> 
		</xsl:if> 
	</xsl:for-each> 
	<xsl:choose> 
	<xsl:when test=".//xhtml:* or . != ''"> 
		<xsl:text>&gt;</xsl:text> 
		<xsl:choose> 
			<xsl:when test="string-length(normalize-space(.))&gt;80"> 
				<xsl:value-of select="substring(normalize-space(.),1,80)" /> 
				<em>... (truncated)</em> 
			</xsl:when> 
			<xsl:otherwise> 
				<xsl:value-of select="normalize-space(.)" /> 
			</xsl:otherwise> 
		</xsl:choose> 
		<xsl:text>&lt;/</xsl:text> 
		<xsl:value-of select="name()" /> 
		<xsl:text>&gt;</xsl:text> 
	</xsl:when> 
	<xsl:otherwise> 
		<xsl:text> /&gt;</xsl:text> 
	</xsl:otherwise> 
	</xsl:choose> 
	<!-- </xsl:element> --> 
	</xsl:element> 
</xsl:template> 
 
<xsl:template match="//xhtml:html"> 
    <xsl:variable name="reportp1"> 
 
	<xsl:variable name="img_alt"> 
		<xsl:for-each select="//xhtml:img[not(@alt)]"> 
			<li> 
				<xsl:if test="starts-with(@src, 'http://') or starts-with(@src, 'https://')"> 
					<xsl:copy-of select="."/> 
				</xsl:if> 
			 <xsl:apply-templates select="." mode="print" /> </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($img_alt)!=''"> 
		<h3><a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-text-equivalent">Images with no alt attribute</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$img_alt" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="bad_alt"> 
		<xsl:for-each select="//xhtml:*[@alt and translate(normalize-space(@alt), 'abcdefghijklmnopqrstuvwxyzáéíóúñ', 'ABCDEFGHIJKLMNOPQRSTUVWXYZÁÉÍÓÚÑ') = translate(normalize-space(@src), 'abcdefghijklmnopqrstuvwxyzáéíóúñ', 'ABCDEFGHIJKLMNOPQRSTUVWXYZÁÉÍÓÚÑ')]"> 
			<li> 
				<xsl:if test="starts-with(@src, 'http://') or starts-with(@src, 'https://')"> 
					<xsl:copy-of select="."/> 
				</xsl:if> 
				<xsl:apply-templates select="." mode="print" /> </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($bad_alt)!=''"> 
		<h3><a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-text-equivalent">Bad alt attribute</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$bad_alt" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="area_alt"> 
		<xsl:for-each select="//xhtml:area[not(@alt)]"> 
			<li> <xsl:apply-templates select="." mode="print" /> </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($area_alt)!=''"> 
		<h3><a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-text-equivalent">Areas with no alt attribute</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$area_alt" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="input_image_alt"> 
		<xsl:for-each select="//xhtml:input[@type='image'][not(@alt)]"> 
			<li> 
				<xsl:if test="starts-with(@src, 'http://') or starts-with(@src, 'https://')"> 
					<img> 
					<xsl:attribute name="src"> <xsl:value-of select="@src" /> </xsl:attribute> 
					</img> 
				</xsl:if> 
			<xsl:apply-templates select="." mode="print" /> </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($input_image_alt)!=''"> 
		<h3><a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-text-equivalent">Image inputs with no alt attribute</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$input_image_alt" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="frame_title"> 
		<xsl:for-each select="(//xhtml:frame|//xhtml:iframe)[not(@title)]"> 
			<li> <xsl:apply-templates select="." mode="print" /> </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($frame_title)!=''"> 
		<h3><a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-frame-titles">Frames with no title attribute</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$frame_title" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="href_javascript"> 
		<xsl:for-each select="(//xhtml:a|//xhtml:area)[starts-with(@href,'javascript:') and not(@onclick)]"> 
			<li> <xsl:apply-templates select="." mode="print" /> uses <kbd>href</kbd> attribute for JavaScript. Use <kbd>onclick</kbd> instead. </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($href_javascript)!=''"> 
		<h3><a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-scripts">JavaScript-only activation</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$href_javascript" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="object"> 
		<xsl:for-each select="//xhtml:object[normalize-space(.)=''][not(xhtml:*[name()!='param'])]"> 
			<li> <xsl:apply-templates select="." mode="print" /> is empty. Place alternative contents inside. </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($object)!=''"> 
		<h3><a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-text-equivalent">Multimedia objects with no alternative</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$object" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="longdesc_valid"> 
		<xsl:for-each select="//xhtml:*[contains(@longdesc,' ')]"> 
			<li> 
				<xsl:apply-templates select="." mode="print" /> has an invalid <kbd>longdesc</kbd> attribute. It must be a valid URI.</li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($longdesc_valid)!=''"> 
		<h3><a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-text-equivalent">Invalid longdesc attribute</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$longdesc_valid" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="img_longdesc"> 
		<xsl:for-each select="//xhtml:img[string-length(@alt)&gt;$alt_max][not(@longdesc)]"> 
			<li> 
				<xsl:if test="starts-with(@src, 'http://') or starts-with(@src, 'https://')"> 
					<xsl:copy-of select="."/> 
				</xsl:if> 
				<xsl:apply-templates select="." mode="print" /> has a too long <kbd>alt</kbd> attribute. Use <kbd>longdesc</kbd> attribute instead.</li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($img_longdesc)!=''"> 
		<h3><a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-text-equivalent">Images with no longdesc attribute</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$img_longdesc" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="ismap"> 
		<xsl:for-each select="//xhtml:a//xhtml:img[@ismap]"> 
			<li> 
				<xsl:if test="starts-with(@src, 'http://') or starts-with(@src, 'https://')"> 
					<xsl:copy-of select="."/> 
				</xsl:if> 
				<xsl:apply-templates select="." mode="print" /> is a server side image map. Use client side image maps instead.</li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($ismap)!=''"> 
		<h3><a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-client-side-maps">Server side image maps</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$ismap" /> 
		</xsl:element> 
	</xsl:if> 
 
    </xsl:variable> 
 
    <xsl:variable name="reportp2"> 
	<xsl:variable name="html_title"> 
		<xsl:if test="//xhtml:html[count(./xhtml:head/xhtml:title)!=1]"> 
			<li>Document requires a title.</li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:if> 
	</xsl:variable> 
	<xsl:if test="normalize-space($html_title)!=''"> 
		<h3><a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-use-metadata">Document's title is absent</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$html_title" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="bgcolor"> 
		<xsl:for-each select="//xhtml:*[@bgcolor or @color or @text or @background or @alink or @vlink or @link]"> 
			<li> <xsl:apply-templates select="." mode="print" /> uses HTML markup for colour or background. Use CSS instead. </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($bgcolor)!=''"> 
		<h3>Forbidden attributes for <a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-color-convey">colour</a> or <a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-style-sheets">background</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$bgcolor" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="align"> 
		<xsl:for-each select="//xhtml:*[@align or @valign or @cellspacing or @cellpadding or @border or @shade or @clear or @nowrap or @hspace or @vspace or @compact or @face or @noshade or @marginheight or @marginwidth or @frame or @frameborder]"> 
			<li> <xsl:apply-templates select="." mode="print" /> uses HTML markup (not deprecated yet) for presentation. Use CSS instead. </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($align)!=''"> 
		<h3><a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-style-sheets">Presentational attributes translatable to CSS</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$align" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="b_i_s_u_strike_font"> 
		<xsl:for-each select="//xhtml:b|//xhtml:i|//xhtml:s|//xhtml:u|//xhtml:tt|//xhtml:strike|//xhtml:font|//xhtml:basefont|//xhtml:center|//xhtml:applet|//xhtml:layer|//xhtml:ilayer|//xhtml:embed|//xhtml:dir|//xhtml:isindex|//xhtml:menu"> 
			<li> <xsl:apply-templates select="." mode="print" />. The <kbd><xsl:value-of select="name()" /></kbd> element is deprecated. Use proper markup or CSS instead.</li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
                <xsl:if test="$validated = ''"> 
                        <li>Markup must be valid</li> 
                        <xsl:text>&#10;</xsl:text> 
                </xsl:if> 
	</xsl:variable> 
	<xsl:if test="normalize-space($b_i_s_u_strike_font)!=''"> 
		<h3><a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-avoid-deprecated">Deprecated elements</a> or <a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-style-sheets">presentation elements</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$b_i_s_u_strike_font" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="blink_marquee"> 
		<xsl:for-each select="//xhtml:blink|//xhtml:marquee"> 
			<li> <xsl:apply-templates select="." mode="print" /> </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($blink_marquee)!=''"> 
		<h3>Forbidden elements (<a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-avoid-blinking">blink</a>, <a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-avoid-movement">marquee</a>)</h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$blink_marquee" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="ul_type"> 
		<xsl:for-each select="(//xhtml:ul|//xhtml:ol)[@type]"> 
			<li> <xsl:apply-templates select="." mode="print" /> uses a deprecated attribute <kbd>type</kbd>. Use CSS instead. </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($ul_type)!=''"> 
		<h3><a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-avoid-deprecated">Deprecated attributes</a> for <a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-style-sheets">presentation</a>: <a href="http://www.w3.org/TR/WCAG10-HTML-TECHS/#list-bullets">list's type</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$ul_type" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="ondevice"> 
		<xsl:for-each select="//xhtml:*[@onmouseup or @onkeyup][not(@onmouseup=@onkeyup)] | //xhtml:*[@onmousedown or @onkeydown][not(@onmousedown=@onkeydown)] | //xhtml:*[@onclick or @onkeypress][not(@onclick=@onkeypress)] | //xhtml:*[@onmouseover][not(@onmouseover=@onfocus)] | //xhtml:*[@onmouseout][not(@onmouseout=@onblur)] | //xhtml:*[@ondblclick] | //xhtml:*[@onmousemove]"> 
			<li> <xsl:apply-templates select="." mode="print" /> is not device interoperable. Use proper event combinations to make it device interoperable. </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($ondevice)!=''"> 
		<h3><a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-keyboard-operable">Device dependant</a> or <a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-device-independent-events">device independent</a> events that provide no <a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-keyboard-operable-scripts">device interoperability</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$ondevice" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="refresh"> 
		<xsl:for-each select="//xhtml:meta[@http-equiv='refresh']"> 
			<li> <xsl:apply-templates select="." mode="print" /> </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($refresh)!=''"> 
		<h3><a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-no-periodic-refresh">Auto-refresh</a> or <a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-no-auto-forward">redirect</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$refresh" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="targetpop"> 
		<xsl:for-each select="//xhtml:*[@target = '_blank' or @target = '_new']"> 
			<li> <xsl:apply-templates select="." mode="print" /> opens the link in a new window. Limit <kbd>target</kbd> attribute usage for opening links in other frames. </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($targetpop)!=''"> 
		<h3><a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-avoid-pop-ups">Emerging windows</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$targetpop" /> 
		</xsl:element> 
	</xsl:if> 
 
	<!-- All h1 are OK --> 
	<xsl:variable name="headers"> 
		<xsl:for-each select=" 
//xhtml:h2[not(preceding::xhtml:*[self::xhtml:h1 or self::xhtml:h2 or self::xhtml:h3 or self::xhtml:h4 or self::xhtml:h5 or self::xhtml:h6][1])] |
//xhtml:h3[not(preceding::xhtml:*[self::xhtml:h1 or self::xhtml:h2 or self::xhtml:h3 or self::xhtml:h4 or self::xhtml:h5 or self::xhtml:h6][1][self::xhtml:h2 or self::xhtml:h3 or self::xhtml:h4 or self::xhtml:h5 or self::xhtml:h6])] |
//xhtml:h4[not(preceding::xhtml:*[self::xhtml:h1 or self::xhtml:h2 or self::xhtml:h3 or self::xhtml:h4 or self::xhtml:h5 or self::xhtml:h6][1][self::xhtml:h3 or self::xhtml:h4 or self::xhtml:h5 or self::xhtml:h6])] |
//xhtml:h5[not(preceding::xhtml:*[self::xhtml:h1 or self::xhtml:h2 or self::xhtml:h3 or self::xhtml:h4 or self::xhtml:h5 or self::xhtml:h6][1][self::xhtml:h4 or self::xhtml:h5 or self::xhtml:h6])] |
//xhtml:h6[not(preceding::xhtml:*[self::xhtml:h1 or self::xhtml:h2 or self::xhtml:h3 or self::xhtml:h4 or self::xhtml:h5 or self::xhtml:h6][1][self::xhtml:h5 or self::xhtml:h6])]"> 
			<li> <xsl:apply-templates select="." mode="print" /> </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($headers)!=''"> 
		<h3><a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-logical-headings">Headers placed in a bad hierarchy</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$headers" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="frameset_noframes"> 
		<!-- <xsl:for-each select="(//xhtml:frameset|//xhtml:iframe)[not(xhtml:noframes)]"> --> 
		<xsl:for-each select="(//xhtml:frameset)[not(xhtml:noframes)]"> 
			<li> <xsl:apply-templates select="." mode="print" /> </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($frameset_noframes)!=''"> 
		<h3><a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-fallback-page">Frameset or iframes with no noframes element</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$frameset_noframes" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="frame_longdesc"> 
		<xsl:for-each select="(//xhtml:frame|//xhtml:iframe)[string-length(@title)&gt;$title_max][not(@longdesc)]"> 
			<li> <xsl:apply-templates select="." mode="print" /> has a too long <kbd>title</kbd> attribute. Use <kbd>longdesc</kbd> attribute instead.</li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($frame_longdesc)!=''"> 
		<h3><a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-frame-longdesc">Frames with no longdesc attribute</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$frame_longdesc" /> 
		</xsl:element> 
	</xsl:if> 
 
 
	<xsl:variable name="fieldset"> 
		<xsl:for-each select="//xhtml:form[count(.//xhtml:input[not(@type='hidden')] | .//xhtml:select | .//xhtml:textarea)&gt;$ff_max][not(.//xhtml:fieldset)]"> 
			<li> <xsl:apply-templates select="." mode="print" /> </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($fieldset)!=''"> 
		<h3><a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-group-information">Forms with no fieldset elements</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$fieldset" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="optgroup"> 
		<xsl:for-each select="//xhtml:select[count(.//xhtml:option)&gt;$option_max][not(.//xhtml:optgroup)]"> 
			<li> <xsl:apply-templates select="." mode="print" /> </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($optgroup)!=''"> 
		<h3><a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-group-information">Select elements with no optgroup elements</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$optgroup" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="no_text"> 
		<xsl:for-each select="//xhtml:a[@href][normalize-space(concat(., .//@alt))=''] | (//xhtml:title|//xhtml:legend|//xhtml:label)[normalize-space(.)='']"> 
			<li> <xsl:apply-templates select="." mode="print" /> </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($no_text)!=''"> 
		<h3><a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-meaningful-links">Elements requiring a pronounceable text</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$no_text" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="a_a"> 
		<xsl:for-each select="//xhtml:a|//xhtml:area"> 
			<xsl:variable name="a" select="." /> 
		<!-- <xsl:value-of select="upper-case(normalize-space(concat(@title, .//@alt, .)))" /> --> 
		<!-- <xsl:value-of select="concat('*',normalize-space(concat(@title, .//@alt, .)), '*')" /> --> 
		<!-- <xsl:text>&#10;</xsl:text> --> 
			<xsl:for-each select="($a/following::xhtml:a|$a/following::xhtml:area)[@href != $a/@href and translate(normalize-space(concat(@title, .//@alt, .)), 'abcdefghijklmnopqrstuvwxyzáéíóúñ', 'ABCDEFGHIJKLMNOPQRSTUVWXYZÁÉÍÓÚÑ') = translate(normalize-space(concat($a/@title, $a//@alt, $a)), 'abcdefghijklmnopqrstuvwxyzáéíóúñ', 'ABCDEFGHIJKLMNOPQRSTUVWXYZÁÉÍÓÚÑ')]"> 
				<li><!-- <xsl:copy-of select="$a" /> --> 
				<xsl:apply-templates select="$a" mode="print" /> and<br /> 
				<!-- <xsl:copy-of select="." /> --> 
				<xsl:apply-templates select="." mode="print" /> 
				have different targets (<kbd><xsl:value-of select="$a/@href" /></kbd>, <kbd><xsl:value-of select="@href" /></kbd>) but same text (<kbd><xsl:value-of select="translate(normalize-space(concat(@title, .//@alt, .)), 'abcdefghijklmnopqrstuvwxyzáéíóúñ', 'ABCDEFGHIJKLMNOPQRSTUVWXYZÁÉÍÓÚÑ')" /></kbd>).</li> 
				<xsl:text>&#10;</xsl:text> 
			</xsl:for-each> 
		</xsl:for-each> 
	</xsl:variable> 
	<!-- <xsl:if test="$a_a"> --> 
	<xsl:if test="normalize-space($a_a)!=''"> 
		<!-- <h3><a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-meaningful-links">Different links with the same text</a></h3> --> 
		<h3><a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-meaningful-links">Links with unclear target</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$a_a" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="ff_label"> 
		<xsl:for-each select="//xhtml:select | //xhtml:textarea |
			//xhtml:input[@type='password' or
			    @type='text' or
			    @type='checkbox' or
			    @type='radio' or
			    @type='file' or not(@type)]"> 
			<xsl:variable name="ff" select="." /> 
			<xsl:variable name="labels" select="//xhtml:label[@for = $ff/@id]" /> 
			<xsl:if test="count($labels)&gt;1 or (count($labels)=0 and not(@title))"> 
				<li><xsl:apply-templates select="$ff" mode="print" /> has <strong><xsl:value-of select="count($labels)" /></strong> labels.</li> 
				<xsl:text>&#10;</xsl:text> 
			</xsl:if> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($ff_label)!=''"> 
		<h3><a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-associate-labels">Form fields that don't have a single description</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$ff_label" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="label_ff"> 
		<!-- This should be nowcag --> 
		<xsl:for-each select="//xhtml:label"> 
			<xsl:variable name="label" select="." /> 
			<xsl:if test="count(//xhtml:*[@id = $label/@for])!=1"> 
				<li><xsl:apply-templates select="$label" mode="print" /> has <strong><xsl:value-of select="count(//xhtml:*[@id = $label/@for])" /></strong> described form fields.</li> 
				<xsl:text>&#10;</xsl:text> 
			</xsl:if> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($label_ff)!=''"> 
		<h3><a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-unassociated-labels">Unassociatied labels</a> or <a href="http://www.w3.org/TR/xhtml1/">labels having not a unique described form field</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$label_ff" /> 
		</xsl:element> 
	</xsl:if> 
 
    </xsl:variable> 
 
    <xsl:variable name="reportp3"> 
	<xsl:variable name="html_lang"> 
		<xsl:for-each select="//xhtml:html[not(@xml:lang) and not(@lang)]"> 
			<!-- <li> <xsl:apply-templates select="." mode="print" /> </li> --> 
			<li>Document requires an idiom.</li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($html_lang)!=''"> 
		<h3><a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-identify-lang">Document's idiom is absent</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$html_lang" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="area_a"> 
		<xsl:for-each select="//xhtml:area"> 
			<xsl:variable name="area" select="." /> 
			<xsl:if test="not(//xhtml:a[@href = $area/@href])"> 
				<li><xsl:apply-templates select="$area" mode="print" /> requires a redundant link to <kbd><xsl:value-of select="$area/@href" /></kbd> somewhere else in the document.</li> 
				<xsl:text>&#10;</xsl:text> 
			</xsl:if> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($area_a)!=''"> 
		<h3><a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-redundant-client-links">Areas having no redundant link</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$area_a" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="acronym_abbr_notitle"> 
		<xsl:for-each select="(//xhtml:abbr|//xhtml:acronym)[not(@title)]"> 
			<xsl:variable name="a" select="." /> 
			<xsl:if test="not((preceding::xhtml:abbr|preceding::xhtml:acronym)[. = $a][@title])"> 
				<li><xsl:apply-templates select="." mode="print" /> has not been previously defined.</li> 
				<xsl:text>&#10;</xsl:text> 
			</xsl:if> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($acronym_abbr_notitle)!=''"> 
		<h3><a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-expand-abbr">Abbreviation or acronym not previously defined</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$acronym_abbr_notitle" /> 
		</xsl:element> 
	</xsl:if> 
 
 
	<xsl:variable name="table_summary"> 
		<xsl:for-each select="//xhtml:table[not(@summary)]"> 
			<li> <xsl:apply-templates select="." mode="print" /> </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($table_summary)!=''"> 
		<h3><a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-table-summaries">Tables with no summary attribute</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$table_summary" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="table_caption"> 
		<xsl:for-each select="//xhtml:table[not(./xhtml:caption) and (./xhtml:tr/xhtml:th | ./xhtml:*/xhtml:tr/xhtml:th)]"> 
			<li> <xsl:apply-templates select="." mode="print" /> </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($table_caption)!=''"> 
		<h3><a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-table-summaries">Tables with no caption element</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$table_caption" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="th_abbr"> 
		<xsl:for-each select="//xhtml:th[string-length(normalize-space(.))&gt;$th_max][not(@abbr)]"> 
			<li> <xsl:apply-templates select="." mode="print" /> has a too long text. Use <kbd>abbr</kbd> attribute.</li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($th_abbr)!=''"> 
		<h3><a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-abbreviate-labels">Table headers with no abbr attribute</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$th_abbr" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="tabindex"> 
		<xsl:for-each select="//xhtml:*[@tabindex]"> 
			<xsl:variable name="n" select="@tabindex" /> 
			<!-- <xsl:if test="number($n) = 'NaN' or count(//*[@tabindex=$n])!=1 or number($n)&lt;1 or number($n)&gt;count(//*[@tabindex])"> --> 
			<!-- <xsl:if test="not(number($n) != 'NaN' and count(//*[@tabindex=$n])=1 and number($n)&gt;0 and number($n)&lt;count(//*[@tabindex])+1)"> --> 
			<!-- de WroX: <xsl:if test="string($x)='NaN'"> --> 
			<xsl:if test="not(string(number($n)) != 'NaN' and count(//*[@tabindex=$n])=1 and number($n)&gt;0 and number($n)&lt;count(//*[@tabindex])+1)"> 
				<li><xsl:apply-templates select="." mode="print" /> has bad tabindex <kbd><xsl:value-of select="$n" /></kbd>.</li> 
				<xsl:text>&#10;</xsl:text> 
			</xsl:if> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($tabindex)!=''"> 
		<h3><a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-tab-order">Bad tabulation order</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$tabindex" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="accesskey"> 
		<xsl:for-each select="//xhtml:*[@accesskey]"> 
			<xsl:variable name="c" select="@accesskey" /> 
			<xsl:if test="not(string-length($c)=1 and count(//*[@accesskey=$c])=1)"> 
				<li><xsl:apply-templates select="." mode="print" /> has bad accesskey <kbd><xsl:value-of select="$c" /></kbd>.</li> 
				<xsl:text>&#10;</xsl:text> 
			</xsl:if> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($accesskey)!=''"> 
		<h3><a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-keyboard-shortcuts">Bad keyboard short-cut</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$accesskey" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="value"> 
		<!-- This should be nowcag --> 
		<xsl:for-each select="//xhtml:input[@type='text' or @type='password' or not(@type)][not(@value) or @value = ''][not(@inputmode)] | //xhtml:textarea[normalize-space(.) = ''][not(@inputmode)]"> 
			<li><xsl:apply-templates select="." mode="print" /> is missing placeholder text.</li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($value)!=''"> 
		<h3><a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-place-holders">Form fields without place holder text</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$value" /> 
		</xsl:element> 
	</xsl:if> 
 
 
    </xsl:variable> 
 
    <xsl:variable name="reportnowcag"> 
 
<!-- MobileOK Basic Test 3.1 AUTO_REFRESH (partial) and REDIRECTION ALREADY --> 
<!-- MobileOK Basic Test 3.2 CACHING OUTOFSCOPE --> 
<!-- MobileOK Basic Test 3.3 CHARACTER_ENCODING_SUPPORT and CHARACTER_ENCODING_USE OUTOFSCOPE --> 
<!-- MobileOK Basic Test 3.4 CONTENT_FORMAT_SUPPORT DISAGREE --> 
<!-- MobileOK Basic Test 3.5 DEFAULT_INPUT_MODE DISAGREE --> 
<!-- MobileOK Basic Test 3.6 EXTERNAL_RESOURCES DISAGREE --> 
<!-- MobileOK Basic Test 3.7 GRAPHICS_FOR_SPACING OUTOFSCOPE --> 
<!-- MobileOK Basic Test 3.8 IMAGE_MAPS --> 
	<xsl:variable name="map_exists"> 
		<xsl:for-each select="//xhtml:area | //xhtml:*[@usemap]"> 
			<li> <xsl:apply-templates select="." mode="print" /> </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($map_exists)!=''"> 
		<h3><a href="http://www.w3.org/TR/2006/WD-mobileOK-basic10-tests-20061113/#test_image_maps">Maps forbidden</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$map_exists" /> 
		</xsl:element> 
	</xsl:if> 
<!-- MobileOK Basic Test 3.9 IMAGES_RESIZING and IMAGES_SPECIFY_SIZE, DISAGREE? (COST?) --> 
<!-- MobileOK Basic Test 3.10 LINK_TARGET_FORMAT OUTOFSCOPE --> 
<!-- MobileOK Basic Test 3.11 MEASURES CSS? OUTOFSCOPE? --> 
<!-- MobileOK Basic Test 3.12 MINIMIZE DISAGREE, OUTOFSCOPE --> 
<!-- MobileOK Basic Test 3.13 NO_FRAMES --> 
	<xsl:variable name="frame_exists"> 
		<xsl:for-each select="//xhtml:frame | //xhtml:frameset | //xhtml:iframe"> 
			<li> <xsl:apply-templates select="." mode="print" /> </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($frame_exists)!=''"> 
		<h3><a href="http://www.w3.org/TR/2006/WD-mobileOK-basic10-tests-20061113/#test_no_frames">Frames forbidden</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$frame_exists" /> 
		</xsl:element> 
	</xsl:if> 
<!-- MobileOK Basic Test 3.14 NON-TEXT_ALTERNATIVES ALREADY at MANY --> 
<!-- MobileOK Basic Test 3.15 OBJECTS_OR_SCRIPT (partial) ALREADY at validation, href_javascript --> 
	<xsl:variable name="applet_exists"> 
		<xsl:for-each select="//xhtml:applet"> 
			<li> <xsl:apply-templates select="." mode="print" /> </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($applet_exists)!=''"> 
		<h3><a href="http://www.w3.org/TR/2006/WD-mobileOK-basic10-tests-20061113/#test_objects_or_script">Applets forbidden (use object instead)</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$applet_exists" /> 
		</xsl:element> 
	</xsl:if> 
<!-- MobileOK Basic Test 3.16 PAGE_SIZE_LIMIT DISAGREE, OUTOFSCOPE --> 
<!-- MobileOK Basic Test 3.17 PAGE_TITLE ALREADY at html_title --> 
<!-- MobileOK Basic Test 3.18 POP_UPS --> 
	<xsl:variable name="targetframe"> 
		<xsl:for-each select="//xhtml:*[@target][@target != '_self' and @target != '_parent' and @target != '_top']"> 
			<li> <xsl:apply-templates select="." mode="print" /> opens the link in a new window or another frame. Limit <kbd>target</kbd> attribute usage for opening links in current frames. </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($targetframe)!=''"> 
		<h3><a href="http://www.w3.org/TR/2006/WD-mobileOK-basic10-tests-20061113/#test_pop_ups">Link's target</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$targetframe" /> 
		</xsl:element> 
	</xsl:if> 
<!-- MobileOK Basic Test 3.19 PROVIDE_DEFAULTS (partial) DISAGREE --> 
<!-- MobileOK Basic Test 3.20 SCROLLING (partial) DISAGREE? OUTOFSCOPE? --> 
<!-- MobileOK Basic Test 3.21 STYLE_SHEETS_SUPPORT OUTOFSCOPE? --> 
<!-- MobileOK Basic Test 3.22 STYLE_SHEETS_USE ALREADY at validation --> 
<!-- MobileOK Basic Test 3.23 TABLES_ALTERNATIVES OUTOFSCOPE? --> 
<!-- MobileOK Basic Test 3.24 TABLES_LAYOUT DISAGREE --> 
<!-- MobileOK Basic Test 3.25 TABLES_NESTED SHARED with XHTML Basic --> 
	<xsl:variable name="nested_table"> 
		<xsl:for-each select="//xhtml:table[.//xhtml:table]"> 
			<li> <xsl:apply-templates select="." mode="print" /></li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($nested_table)!=''"> 
		<h3><a href="http://www.w3.org/TR/WCAG10-HTML-TECHS/#tables-layout">Nested tables</a> (not recommended, and forbidden in <a href="http://www.w3.org/TR/xhtml-basic/">XHTML Basic</a>)</h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$nested_table" /> 
		</xsl:element> 
	</xsl:if> 
<!-- MobileOK Basic Test 3.26 VALID_MARKUP ALREADY at validation --> 
 
<!-- #################################################### --> 
 
	<xsl:variable name="applet_code"> 
		<xsl:for-each select="//xhtml:applet[not(@code) and not(@object)]"> 
			<li> <xsl:apply-templates select="." mode="print" /> </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($applet_code)!=''"> 
		<h3><a href="http://www.w3.org/TR/xhtml1/">Applets with no code</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$applet_code" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="legend"> 
		<xsl:for-each select="//xhtml:legend[count(preceding-sibling::xhtml:*) &gt; 0 or normalize-space(substring-before(.., .)) != '']"> 
			<li> <xsl:apply-templates select="." mode="print" /> </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($legend)!=''"> 
		<h3><a href="http://www.w3.org/TR/xhtml1/">Badly placed legend elements</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$legend" /> 
		</xsl:element> 
	</xsl:if> 
 
 
	<xsl:variable name="param"> 
		<!-- <xsl:for-each select="//xhtml:param[count(preceding-sibling::xhtml:*[not(self::xhtml:param)]) &gt; 0 or normalize-space(substring-before(.., .)) != '']"> --> 
		<xsl:for-each select="//xhtml:param[count(preceding-sibling::xhtml:*[not(self::xhtml:param)]) &gt; 0]"> 
			<li> <xsl:apply-templates select="." mode="print" />. <kbd>param</kbd> elements should precede other content.</li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($param)!=''"> 
		<h3><a href="http://www.w3.org/TR/xhtml1/">Badly placed param elements</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$param" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="ffnames"> 
		<xsl:for-each select="(//xhtml:textarea|//xhtml:select|//xhtml:input[not(@type='image' or @type='reset' or @type='submit' or @type='button')])[not(@name)]"> 
			<li> <xsl:apply-templates select="." mode="print" /> </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($ffnames)!=''"> 
		<h3><a href="http://www.w3.org/TR/xhtml1/">Form fields with no name attribute</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$ffnames" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="input_noimage_alt"> 
		<xsl:for-each select="//xhtml:input[not(@type='image')][@alt]"> 
			<li> <xsl:apply-templates select="." mode="print" /> </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($input_noimage_alt)!=''"> 
		<h3><a href="http://www.w3.org/TR/xhtml1/">Non image input with alt attribute</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$input_noimage_alt" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="forbidden_in_pre"> 
		<xsl:for-each select="(//xhtml:img|//xhtml:object|//xhtml:big|//xhtml:small|//xhtml:sub|//xhtml:sup)[ancestor::xhtml:pre]"> 
			<li> <xsl:apply-templates select="." mode="print" /> </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($forbidden_in_pre)!=''"> 
		<h3><a href="http://www.w3.org/TR/xhtml1/#prohibitions">Forbidden elements in pre</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$forbidden_in_pre" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="nested_focusable"> 
		<xsl:variable name="a" select="//xhtml:a|//xhtml:area|//xhtml:label|//xhtml:input|//xhtml:select|//xhtml:textarea|//xhtml:button" /> 
		<xsl:for-each select="$a//xhtml:a|$a//xhtml:area|$a//xhtml:label|$a//xhtml:input|$a//xhtml:select|$a//xhtml:textarea|$a//xhtml:button|$a//xhtml:iframe"> 
			<li> <xsl:apply-templates select="." mode="print" /> is inside a focusable element <xsl:apply-templates select="ancestor::xhtml:a|ancestor::xhtml:area|ancestor::xhtml:label|ancestor::xhtml:input|ancestor::xhtml:select|ancestor::xhtml:textarea|ancestor::xhtml:button" mode="print" /> </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($nested_focusable)!=''"> 
		<h3><a href="http://www.w3.org/TR/xhtml1/#prohibitions">Nested focusable elements</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$nested_focusable" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="nested_form"> 
		<xsl:for-each select="//xhtml:form[.//xhtml:form]"> 
			<li> <xsl:apply-templates select="." mode="print" /></li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($nested_form)!=''"> 
		<h3><a href="http://www.w3.org/TR/xhtml1/#prohibitions">Nested forms</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$nested_form" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="radio"> 
		<xsl:for-each select="//xhtml:input[@type='radio']"> 
			<xsl:variable name="r" select="." /> 
			<xsl:variable name="others" select="./ancestor::xhtml:form//xhtml:input[@type = 'radio' and @name = $r/@name and @checked]" /> 
			<xsl:if test="count($others)&gt;1"> 
				<li><xsl:apply-templates select="$r" mode="print" /> has <strong><xsl:value-of select="count($others)-1" /></strong> other checked radio button.</li> 
				<xsl:text>&#10;</xsl:text> 
			</xsl:if> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($radio)!=''"> 
		<h3><a href="http://www.w3.org/TR/xhtml1/">Multiple checked radio buttons</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$radio" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="select"> 
		<xsl:for-each select="//xhtml:select[not(@multiple)][count(.//xhtml:option[@selected])&gt;1]"> 
			<li> <xsl:apply-templates select="." mode="print" /> is not multiple but it has <strong><xsl:value-of select="count(.//xhtml:option[@selected])" /></strong> selected options.</li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($select)!=''"> 
		<h3><a href="http://www.w3.org/TR/xhtml1/">Multiple selected options</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$select" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="id_name"> 
		<xsl:for-each select="(//xhtml:a | //xhtml:applet | //xhtml:object | //xhtml:form | //xhtml:frame | //xhtml:iframe | //xhtml:img | //xhtml:map)[@name and @id][@name != @id]"> 
			<li> <xsl:apply-templates select="." mode="print" /> has a name <kbd><xsl:value-of select="@name" /></kbd> different that its id <kbd><xsl:value-of select="@id" /></kbd>.</li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($id_name)!=''"> 
		<h3><a href="http://www.w3.org/TR/xhtml1/">Names different that ids</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$id_name" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="labeltwoff"> 
		<!-- I think there should be no form field inside a label, so the condition should be as follows --> 
		<!-- <xsl:for-each select="//xhtml:label[count(.//xhtml:textarea|.//xhtml:select|.//xhtml:input)&gt;0]"> --> 
		<xsl:for-each select="//xhtml:label[count(.//xhtml:textarea|.//xhtml:select|.//xhtml:input)&gt;1]"> 
			<li> <xsl:apply-templates select="." mode="print" /> </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($labeltwoff)!=''"> 
		<h3><a href="http://www.w3.org/TR/xhtml1/">Labels with too many form fields inside</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$labeltwoff" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="label_ffnext"> 
		<xsl:for-each select="//xhtml:label"> 
			<xsl:variable name="label" select="." /> 
			<xsl:if test="not(following::xhtml:*[@id = $label/@for])"> 
				<li><xsl:apply-templates select="$label" mode="print" /> is not preceding its described form field <xsl:apply-templates select="//xhtml:*[@id = $label/@for][1]" mode="print" />.</li> 
				<xsl:text>&#10;</xsl:text> 
			</xsl:if> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($label_ffnext)!=''"> 
		<h3><a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-unassociated-labels">Labels not immediately preceding their described form field</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$label_ffnext" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="ins"> 
		<xsl:for-each select="//xhtml:ins[(.//xhtml:p or .//xhtml:h1 or .//xhtml:h2 or .//xhtml:h3 or .//xhtml:h4 or .//xhtml:h5 or .//xhtml:h6 or .//xhtml:div or .//xhtml:ul or .//xhtml:ol or .//xhtml:dl or .//xhtml:menu or .//xhtml:dir or .//xhtml:pre or .//xhtml:hr or .//xhtml:blockquote or .//xhtml:address or .//xhtml:center or .//xhtml:noframes or .//xhtml:isindex or .//xhtml:fieldset or .//xhtml:table or .//xhtml:form) and (parent::xhtml:a or parent::xhtml:br or parent::xhtml:span or parent::xhtml:bdo or parent::xhtml:object or parent::xhtml:applet or parent::xhtml:img or parent::xhtml:map or parent::xhtml:iframe or parent::xhtml:tt or parent::xhtml:i or parent::xhtml:b or parent::xhtml:u or parent::xhtml:s or parent::xhtml:strike or parent::xhtml:big or parent::xhtml:small or parent::xhtml:font or parent::xhtml:basefont or parent::xhtml:em or parent::xhtml:strong or parent::xhtml:dfn or parent::xhtml:code or parent::xhtml:q or parent::xhtml:samp or parent::xhtml:kbd or parent::xhtml:var or parent::xhtml:cite or parent::xhtml:abbr or parent::xhtml:acronym or parent::xhtml:sub or parent::xhtml:sup or parent::xhtml:input or parent::xhtml:select or parent::xhtml:textarea or parent::xhtml:label or parent::xhtml:button)]"> 
 
			<li> <xsl:apply-templates select="." mode="print" /> </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($ins)!=''"> 
		<h3><a href="http://www.w3.org/TR/xhtml1/">Block content within an ins element occurring in inline content</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$ins" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="acronym_abbr"> 
		<!-- URL: Enter url for A ; URL: Enter url for B --> 
		<!-- <xsl:for-each select="//xhtml:abbr|//xhtml:acronym"> --> 
		<xsl:for-each select="//xhtml:acronym"> 
			<xsl:variable name="a" select="." /> 
			<!-- <xsl:for-each select="($a/following::xhtml:abbr|$a/following::xhtml:acronym)[@title != $a/@title and translate(normalize-space(concat(.//@alt, .)), 'abcdefghijklmnopqrstuvwxyzáéíóúñ', 'ABCDEFGHIJKLMNOPQRSTUVWXYZÁÉÍÓÚÑ') = translate(normalize-space(concat($a//@alt, $a)), 'abcdefghijklmnopqrstuvwxyzáéíóúñ', 'ABCDEFGHIJKLMNOPQRSTUVWXYZÁÉÍÓÚÑ')]"> --> 
			<xsl:for-each select="$a/following::xhtml:acronym[@title != $a/@title and translate(normalize-space(concat(.//@alt, .)), 'abcdefghijklmnopqrstuvwxyzáéíóúñ', 'ABCDEFGHIJKLMNOPQRSTUVWXYZÁÉÍÓÚÑ') = translate(normalize-space(concat($a//@alt, $a)), 'abcdefghijklmnopqrstuvwxyzáéíóúñ', 'ABCDEFGHIJKLMNOPQRSTUVWXYZÁÉÍÓÚÑ')]"> 
				<li><!-- <xsl:copy-of select="$a" /> --> 
				<xsl:apply-templates select="$a" mode="print" /> and<br /> 
				<!-- <xsl:copy-of select="." /> --> 
				<xsl:apply-templates select="." mode="print" /> 
				have different definitions (<kbd><xsl:value-of select="$a/@title" /></kbd>, <kbd><xsl:value-of select="@title" /></kbd>) but same text (<kbd><xsl:value-of select="translate(normalize-space(concat(.//@alt, .)), 'abcdefghijklmnopqrstuvwxyzáéíóúñ', 'ABCDEFGHIJKLMNOPQRSTUVWXYZÁÉÍÓÚÑ')" /></kbd>).</li> 
				<xsl:text>&#10;</xsl:text> 
			</xsl:for-each> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($acronym_abbr)!=''"> 
		<h3><a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-expand-abbr">Different definitions for the same text</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$acronym_abbr" /> 
		</xsl:element> 
	</xsl:if> 
 
	<xsl:variable name="style"> 
		<xsl:for-each select="//xhtml:*[@style]"> 
			<li> <xsl:apply-templates select="." mode="print" /> uses embedded style. Use external CSS instead.</li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
	<xsl:if test="normalize-space($style)!=''"> 
		<h3><a href="http://www.w3.org/TR/xhtml11/doctype.html#s_doctype">Deprecated style attribute</a> avoiding <a href="http://www.w3.org/TR/WCAG10/wai-pageauth.html#tech-consistent-style">consistent style</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$style" /> 
		</xsl:element> 
	</xsl:if> 
 
    </xsl:variable> 
 
<!--
<xsl:text disable-output-escaping="yes">
&lt;!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
    "DTD/xhtml11.dtd"&gt;
</xsl:text>
--> 
<!-- <xsl:copy select="." /> --> 
	<xsl:element name="html"> 
	<xsl:attribute name="xml:lang"><xsl:text>en</xsl:text></xsl:attribute> 
	<head><title>Accessibility report
	<xsl:if test="$xmlfile != ''">
                for <xsl:value-of select="$xmlfile" />
                </xsl:if></title> 
	<meta name="generator" content="http://www.it.uc3m.es/vlc/waex.html" /> 
	<meta name="author" content="Vicente Luque Centeno" /> 
	<meta name="company" content="Carlos III University of Madrid" /> 
 
	<style type="text/css"> 
		td, th {border-bottom: dotted ; border-top: hidden; border-right: dotted; border-width:thin ; margin: 0px 0px 0px 0px; padding: 0px 1em 0px 1em;}
		th, caption { color: black; background-color: #BED5EB; font-weight: bold}
		tr, td {color: black; background-color: rgb(240,240,240)}
		body {color:black;background:white}
		em {color:black;background:transparent}
		samp,kbd {color:blue;background:transparent}
		.red {color:red;background:transparent}
		.green {color:green;background:transparent}
		.yellow {color:orange;background:transparent}
                .gray {color:gray;background:transparent}
		.border {border-style: solid}
		.prio1 {border-color: red; background-color: #FFDDDD;}
		.prio2 {border-color: yellow; background-color: #FFFF99;}
		.prio3 {border-color: green; background-color: #DDFFDD;}
		.nowcag {border-color: blue; background-color: #DDDDFF;}
		.fail {border-color: red; background-color: #FFDDDD;}
                .warning {border-color: yellow; background-color: #FFFF99;}
                .smaller {font-size: smaller}
	</style></head> 
	<body> 
	<h1>Accessibility report
	<xsl:if test="$xmlfile != ''"> 
                for <a href="{$xmlfile}"><xsl:value-of select="$xmlfile" /></a> 
                </xsl:if></h1> 
 
	<table summary="Report summary"> 
	<caption>Report summary</caption> 
	<tr><th>Automated tests</th> <th>Result</th> <th>Level</th> </tr> 
	<tr><th><acronym title="Web Content Accessibility Guidelines">WCAG</acronym> Checkpoints priority 1</th> <td class="border prio1"> <xsl:call-template name="result"> 
		<xsl:with-param name="res" select="$reportp1" /> 
	</xsl:call-template></td> <td class="border prio1"> 
	
	<xsl:if test="normalize-space($reportp1) = ''"> 
		<img src="http://www.w3.org/WAI/wcag1A" alt="A Level" /> if manual tests pass.
	</xsl:if><xsl:text> </xsl:text> 
	</td></tr> 
		
	<xsl:if test="$level = 'aa' or $level = 'aaa' or $level = 'aaaplus'"> 
	<tr><th>WCAG Checkpoints priority 2</th> <td class="border prio2"> <xsl:call-template name="result"> 
		<xsl:with-param name="res" select="$reportp2" /> 
	</xsl:call-template></td> <td class="border prio2"> 
	<xsl:if test="normalize-space($reportp2) = '' and concat($reportp1, $reportp1) = ''"> 
		<img src="http://www.w3.org/WAI/wcag1AA" alt="AA Level" /> if manual tests pass.
	</xsl:if><xsl:text> </xsl:text> 
	</td> </tr> 
	</xsl:if> 
 
	<xsl:if test="$level = 'aaa' or $level = 'aaaplus'"> 
	<tr><th>WCAG Checkpoints priority 3</th> <td class="border prio3"> <xsl:call-template name="result"> 
		<xsl:with-param name="res" select="$reportp3" /> 
	</xsl:call-template></td> <td class="border prio3"> 
	<xsl:if test="normalize-space($reportp3) = '' and concat($reportp1, $reportp2) = ''"> 
		<img src="http://www.w3.org/WAI/wcag1AAA" alt="AAA Level" /> if manual tests pass.
	</xsl:if><xsl:text> </xsl:text> 
	</td></tr> 
	</xsl:if> 
 
	<xsl:if test="$level = 'aaaplus'"> 
	<tr><th>Checkpoints not in WCAG</th> <td class="border nowcag"><xsl:call-template name="result"> 
		<xsl:with-param name="res" select="$reportnowcag" /> 
	</xsl:call-template></td> <td class="border nowcag"> 
	<xsl:if test="normalize-space($reportnowcag) = '' and concat($reportp1, $reportp2, $reportp3) = ''"> 
		<img src="http://www.it.uc3m.es/vlc/icons/wcag1AAA+.png" alt="AAA+ Level (AAA level + others)" /> if manual tests pass.
	</xsl:if><xsl:text> </xsl:text> 
 
	</td></tr> 
	</xsl:if> 
 
	</table> 
<!--
	<xsl:if test="normalize-space(concat($reportp1,$reportp2,$reportp3,$reportnowcag))=''">
		<p>OK: Document has no detectable barriers.</p>
	</xsl:if>
--> 
	<xsl:if test="normalize-space($reportp1)!=''"> 
		<h2>WCAG Checkpoints priority 1</h2> 
		<div class="border prio1"> 
		<xsl:copy-of select="$reportp1" /> 
		</div> 
	</xsl:if> 
	<xsl:if test="normalize-space($reportp2)!='' and ($level = 'aa' or $level = 'aaa' or $level = 'aaaplus')"> 
		<h2>WCAG Checkpoints priority 2</h2> 
		<div class="border prio2"> 
		<xsl:copy-of select="$reportp2" /> 
		</div> 
	</xsl:if> 
	<xsl:if test="normalize-space($reportp3)!='' and ($level = 'aaa' or $level = 'aaaplus')"> 
		<h2>WCAG Checkpoints priority 3</h2> 
		<div class="border prio3"> 
		<xsl:copy-of select="$reportp3" /> 
		</div> 
	</xsl:if> 
	<xsl:if test="normalize-space($reportnowcag)!='' and ($level = 'aaaplus')"> 
		<h2>Checkpoints not in WCAG</h2> 
		<div class="border nowcag"> 
		<xsl:copy-of select="$reportnowcag" /> 
		</div> 
	</xsl:if> 
	<xsl:if test="$mobileok!=''"> 
		<h2>Mobile OK tests</h2> 
		<xsl:call-template name="mobileoktem" /> 
	</xsl:if> 
	
    </body></xsl:element> 
</xsl:template> 
 
<xsl:template name="mobileoktem"> 
 
<!-- MobileOK Basic Test 3.1 AUTO_REFRESH (partial) and REDIRECTION ALREADY --> 
        <xsl:variable name="refresh"> 
                <xsl:if test="$url != '' and $refreshheader != '' and not(contains($refreshheader, $url))"> 
                        <li class="fail">Failure: Refresh HTTP header not allowed <strong><xsl:value-of select="$refreshheader" /></strong> </li> 
                        <xsl:text>&#10;</xsl:text> 
                </xsl:if> 
                <xsl:for-each select="//xhtml:meta[@http-equiv='refresh' and not(contains(@content, $url))]"> 
                        <li class="fail">Failure: <xsl:apply-templates select="." mode="print" /> </li> 
                        <xsl:text>&#10;</xsl:text> 
                </xsl:for-each> 
                <xsl:if test="$url != '' and $refreshheader != '' and contains($refreshheader, $url)"> 
                        <li class="warning">Warning: Refresh HTTP header not recommended <strong><xsl:value-of select="$refreshheader" /></strong> </li> 
                        <xsl:text>&#10;</xsl:text> 
                </xsl:if> 
                <xsl:for-each select="//xhtml:meta[@http-equiv='refresh' and contains(@content, $url)]"> 
                        <li class="warning">Warning: <xsl:apply-templates select="." mode="print" /> </li> 
                        <xsl:text>&#10;</xsl:text> 
                </xsl:for-each> 
        </xsl:variable> 
        <xsl:variable name="refresh_report"> 
        <xsl:if test="normalize-space($refresh)!=''"> 
                <h3><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_auto_refresh">AUTO_REFRESH (partial) and REDIRECTION</a></h3> 
                <xsl:element name="ul"> 
                        <xsl:copy-of select="$refresh" /> 
                </xsl:element> 
        </xsl:if> 
        </xsl:variable> 
 
<!-- MobileOK Basic Test 3.2 CACHING OUTOFSCOPE --> 
        <xsl:variable name="caching"> 
                        <!-- <li class="unimplemented">Not implemented</li> --> 
                        <!-- <xsl:text>&#10;</xsl:text> --> 
                <xsl:if test="$url != '' and $expires = '' and $cachecontrol = '' and not(//xhtml:meta[@http-equiv='Expires' or @http-equiv='Cache-Control'])"> 
                        <li class="fail">Failure: Caching not enabled</li> 
                        <xsl:text>&#10;</xsl:text> 
                </xsl:if> 
                <xsl:if test="$url != '' and contains($cachecontrol, 'no-cache') or contains($cachecontrol, 'max-age=0') or contains($pragma, 'no-cache')"> 
                        <li class="warning">Warning: Caching not enabled</li> 
                        <xsl:text>&#10;</xsl:text> 
                </xsl:if> 
        </xsl:variable> 
        <xsl:variable name="caching_report"> 
        <xsl:if test="normalize-space($caching)!=''"> 
                <h3><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_caching">CACHING</a></h3> 
                <xsl:element name="ul"> 
                        <xsl:copy-of select="$caching" /> 
                </xsl:element> 
        </xsl:if> 
        </xsl:variable> 
<!-- MobileOK Basic Test 3.3 CHARACTER_ENCODING_SUPPORT and CHARACTER_ENCODING_USE OUTOFSCOPE --> 
        <xsl:variable name="encoding"> 
                        <!-- <li class="unimplemented">Not implemented</li> --> 
                        <!-- <xsl:text>&#10;</xsl:text> --> 
                <xsl:if test="contains($contenttype, 'charset=') and not(contains(translate($contenttype, 'abcdefghijklmnopqrstuvwxyzáéíóúñ', 'ABCDEFGHIJKLMNOPQRSTUVWXYZÁÉÍÓÚÑ'), 'UTF-8')) or not(contains($contenttype, 'charset=')) and contains($contenttype, 'text/') and not(//xhtml:meta[@http-equiv='Content-Type'][contains(translate(@contents, 'abcdefghijklmnopqrstuvwxyzáéíóúñ', 'ABCDEFGHIJKLMNOPQRSTUVWXYZÁÉÍÓÚÑ'), 'UTF-8')])"> 
                        <li class="fail">Failure: Content type is specified and UTF-8 is missing</li> 
                        <xsl:text>&#10;</xsl:text> 
                </xsl:if> 
		
        </xsl:variable> 
        <xsl:variable name="encoding_report"> 
        <xsl:if test="normalize-space($encoding)!=''"> 
                <h3><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_character_encoding_support">CHARACTER_ENCODING_SUPPORT and CHARACTER_ENCODING_USE</a></h3> 
                <xsl:element name="ul"> 
                        <xsl:copy-of select="$encoding" /> 
                </xsl:element> 
        </xsl:if> 
        </xsl:variable> 
<!-- MobileOK Basic Test 3.4 CONTENT_FORMAT_SUPPORT DISAGREE --> 
        <xsl:variable name="contentformat"> 
                <xsl:if test="$url != '' and not(starts-with($contenttype, 'text/html')) and not(starts-with($contenttype, 'application/vnd.wap.xhtml+xml')) and not(starts-with($contenttype, 'application/xhtml+xml'))"> 
                        <li class="fail">Failure: <xsl:value-of select="$contenttype" /> is a wrong Content-Type</li> 
                        <xsl:text>&#10;</xsl:text> 
                </xsl:if> 
<!--
<xsl:message>
Validated: <xsl:value-of select="$validatedbasic11" />
</xsl:message>
--> 
 
                <xsl:if test="$validatedbasic11 = ''"> 
                        <li class="fail">Failure: Document must validate against the XHTML Basic 1.1 DTD</li> 
                        <xsl:text>&#10;</xsl:text> 
                </xsl:if> 
                <xsl:if test="not(contains($cssreport, 'Congratulations'))"> 
                        <li class="fail">Failure: CSS must be valid</li> 
                        <xsl:text>&#10;</xsl:text> 
                </xsl:if> 
        </xsl:variable> 
        <xsl:variable name="contentformat_report"> 
        <xsl:if test="normalize-space($contentformat)!=''"> 
                <h3><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_content_format_support">CONTENT_FORMAT_SUPPORT  and VALID_MARKUP</a></h3> 
                <xsl:element name="ul"> 
                        <xsl:copy-of select="$contentformat" /> 
                </xsl:element> 
        </xsl:if> 
        </xsl:variable> 
 
<!-- MobileOK Basic Test 3.5 DEFAULT_INPUT_MODE DISAGREE --> 
	<xsl:variable name="inputmode"> 
		<xsl:for-each select="//xhtml:input[@type='text' or @type='password' or not(@type)][not(@value) or @value = ''][not(@inputmode)] | //xhtml:textarea[normalize-space(.) = ''][not(@inputmode)]"> 
			<li class="warning">Warning: <xsl:apply-templates select="." mode="print" /> </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
        <xsl:variable name="inputmode_report"> 
	<xsl:if test="normalize-space($inputmode)!=''"> 
		<h3><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_default_input_mode">DEFAULT_INPUT_MODE</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$inputmode" /> 
		</xsl:element> 
	</xsl:if> 
        </xsl:variable> 
 
<!-- MobileOK Basic Test 3.6 EXTERNAL_RESOURCES DISAGREE --> 
        <xsl:variable name="externalresources"> 
		<xsl:variable name="numexternalresources"><xsl:value-of select="count(//xhtml:style|//xhtml:img|//xhtml:link|//xhtml:object)" /></xsl:variable> 
		<xsl:choose> 
                <xsl:when test="$numexternalresources &gt; 20"> 
                        <li class="fail">Failure: Too many external resources (<strong><xsl:value-of select="$numexternalresources" /> </strong>) </li> 
                        <xsl:text>&#10;</xsl:text> 
                </xsl:when> 
                <xsl:when test="$numexternalresources &gt; 10"> 
                        <li class="warning">Warning: Too many external resources (<strong><xsl:value-of select="$numexternalresources" /> </strong>) </li> 
                        <xsl:text>&#10;</xsl:text> 
                </xsl:when> 
		</xsl:choose> 
        </xsl:variable> 
        <xsl:variable name="externalresources_report"> 
        <xsl:if test="normalize-space($externalresources)!=''"> 
                <h3><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_external_resources">EXTERNAL_RESOURCES</a></h3> 
                <xsl:element name="ul"> 
                        <xsl:copy-of select="$externalresources" /> 
                </xsl:element> 
        </xsl:if> 
	</xsl:variable> 
 
<!-- MobileOK Basic Test 3.7 GRAPHICS_FOR_SPACING OUTOFSCOPE --> 
        <xsl:variable name="graphicsspacing"> 
                        <li class="unimplemented">Not implemented</li> 
                        <xsl:text>&#10;</xsl:text> 
        </xsl:variable> 
        <xsl:variable name="graphicsspacing_report"> 
	<!--
        <xsl:if test="normalize-space($graphicsspacing)!=''">
                <h3><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_graphics_for_spacing">GRAPHICS_FOR_SPACING</a></h3>
                <xsl:element name="ul">
                        <xsl:copy-of select="$graphicsspacing" />
                </xsl:element>
        </xsl:if>
	--> 
        </xsl:variable> 
<!-- MobileOK Basic Test 3.8 IMAGE_MAPS --> 
	<xsl:variable name="map_exists"> 
		<xsl:for-each select="//xhtml:*[@usemap] | //xhtml:*[@ismap] | //xhtml:input[@type='image']"> 
			<li class="fail"> Failure: <xsl:apply-templates select="." mode="print" /> </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
        <xsl:variable name="map_exists_report"> 
	<xsl:if test="normalize-space($map_exists)!=''"> 
		<h3><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_image_maps">IMAGE_MAPS</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$map_exists" /> 
		</xsl:element> 
	</xsl:if> 
        </xsl:variable> 
 
<!-- MobileOK Basic Test 3.9 IMAGES_RESIZING and IMAGES_SPECIFY_SIZE, DISAGREE? (COST?) --> 
	<xsl:variable name="img_size"> 
		<xsl:for-each select="(//xhtml:img | //xhtml:object[starts-with(@type, 'image/')])[not(@height and string(number(@height)) != 'NaN') or not(@width and string(number(@width)) != 'NaN')]"> 
			<li class="fail">Failure:  
				<xsl:apply-templates select="." mode="print" /> </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
        <xsl:variable name="img_size_report"> 
	<xsl:if test="normalize-space($img_size)!=''"> 
		<h3><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_images_specify_size">IMAGES_RESIZING and IMAGES_SPECIFY_SIZE</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$img_size" /> 
		</xsl:element> 
	</xsl:if> 
	</xsl:variable> 
 
<!-- MobileOK Basic Test 3.10 LINK_TARGET_FORMAT OUTOFSCOPE --> 
        <xsl:variable name="link_target_format"> 
                        <li class="unimplemented">Not implemented</li> 
                        <xsl:text>&#10;</xsl:text> 
        </xsl:variable> 
        <xsl:variable name="link_target_format_report"> 
	<!--
        <xsl:if test="normalize-space($link_target_format)!=''">
                <h3><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_link_target_format">LINK_TARGET_FORMAT</a></h3>
                <xsl:element name="ul">
                        <xsl:copy-of select="$link_target_format" />
                </xsl:element>
        </xsl:if>
	--> 
	</xsl:variable> 
<!-- MobileOK Basic Test 3.11 MEASURES CSS? OUTOFSCOPE? --> 
        <xsl:variable name="css_measures"> 
                        <!-- <li class="unimplemented">Not implemented</li> --> 
                        <!-- <xsl:text>&#10;</xsl:text> --> 
		<xsl:variable name="cssmodif"> 
			<xsl:value-of select="translate($cssreport, '0123456789', 'XXXXXXXXXX')" /> 
		</xsl:variable> 
		
                <xsl:if test="contains($cssmodif, 'Xcm') or contains($cssmodif, 'Xmm') or contains($cssmodif, 'Xpt') or contains($cssmodif, 'Xin') or contains($cssmodif, 'Xpc')"> 
                        <li class="fail">Failure: Absolute measure length being used at CSS (cm, mm, pt, in or pc)</li> 
                        <xsl:text>&#10;</xsl:text> 
                </xsl:if> 
        </xsl:variable> 
        <xsl:variable name="css_measures_report"> 
        <xsl:if test="normalize-space($css_measures)!=''"> 
                <h3><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_measures">MEASURES</a></h3> 
                <xsl:element name="ul"> 
                        <xsl:copy-of select="$css_measures" /> 
                </xsl:element> 
        </xsl:if> 
        </xsl:variable> 
 
<!-- MobileOK Basic Test 3.12 MINIMIZE DISAGREE, OUTOFSCOPE --> 
        <xsl:variable name="minimize"> 
                        <!-- <li class="unimplemented">Not implemented</li> --> 
                        <!-- <xsl:text>&#10;</xsl:text> --> 
		<xsl:choose> 
                <xsl:when test="$commentlength + $whitespace &gt; $pagesize div 4"> 
                        <li class="fail">Failure: The number of extraneous characters (comments=<strong><xsl:value-of select="$commentlength" /></strong> + extra white spaces=<strong><xsl:value-of select="$whitespace" /></strong>) exceeds 25% of the count of characters in the document (<strong><xsl:value-of select="$pagesize" /></strong>)</li> 
                        <xsl:text>&#10;</xsl:text> 
                </xsl:when> 
                <xsl:when test="$commentlength + $whitespace &gt; $pagesize div 10"> 
                        <li class="warning">Warning: The number of extraneous characters (comments=<strong><xsl:value-of select="$commentlength" /></strong> + extra white spaces=<strong><xsl:value-of select="$whitespace" /></strong>) exceeds 10% of the count of characters in the document (<strong><xsl:value-of select="$pagesize" /></strong>)</li> 
                </xsl:when> 
                </xsl:choose> 
 
        </xsl:variable> 
        <xsl:variable name="minimize_report"> 
        <xsl:if test="normalize-space($minimize)!=''"> 
                <h3><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_minimize">MINIMIZE</a></h3> 
                <xsl:element name="ul"> 
                        <xsl:copy-of select="$minimize" /> 
                </xsl:element> 
        </xsl:if> 
        </xsl:variable> 
 
<!-- MobileOK Basic Test 3.13 NO_FRAMES --> 
	<xsl:variable name="frame_exists"> 
		<xsl:for-each select="//xhtml:frame | //xhtml:frameset | //xhtml:iframe | //xhtml:object[starts-with(@type, 'text/') or starts-with(@type, 'application/xhtml+xml') or starts-with(@type, 'application/vnd.wap.xhtml+xml')]"> 
			<li class="fail"> Failure: <xsl:apply-templates select="." mode="print" /> </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
        <xsl:variable name="frame_exists_report"> 
	<xsl:if test="normalize-space($frame_exists)!=''"> 
		<h3><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_no_frames">NO_FRAMES</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$frame_exists" /> 
		</xsl:element> 
	</xsl:if> 
        </xsl:variable> 
 
<!-- MobileOK Basic Test 3.14 NON-TEXT_ALTERNATIVES ALREADY at MANY --> 
	<xsl:variable name="img_alt"> 
		<!-- <xsl:for-each select="//xhtml:img[not(@alt) or normalize-space(@alt) = '']"> --> 
		<xsl:for-each select="//xhtml:img[not(@alt)]"> 
			<li class="fail">Failure: 
				<xsl:if test="starts-with(@src, 'http://') or starts-with(@src, 'https://')"> 
					<xsl:copy-of select="."/> 
				</xsl:if> 
				<!--
				<xsl:choose>
				<xsl:when test="starts-with(@src, 'http://') or starts-with(@src, 'http://')">
					<xsl:copy-of select=".">
						<xsl:attribute name="alt"></xsl:attribute>
					</xsl:copy-of>
				</xsl:when>
				<xsl:when test="starts-with($url, 'http://' or starts-with(@src, 'http://'))">
					<xsl:copy-of select=".">
						<xsl:attribute name="alt"></xsl:attribute>
						<xsl:attribute name="src"><xsl:value-of select="concat($url, @src)" /></xsl:attribute>
					</xsl:copy-of>
				</xsl:when>
				</xsl:choose>
				--> 
			 <xsl:apply-templates select="." mode="print" /> </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
		<!-- <xsl:apply-templates select="." mode="img_alt" /> --> 
	</xsl:variable> 
        <xsl:variable name="img_alt_report"> 
	<xsl:if test="normalize-space($img_alt)!=''"> 
		<h3><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_non_text_alternatives_1">NON-TEXT_ALTERNATIVES</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$img_alt" /> 
		</xsl:element> 
	</xsl:if> 
	</xsl:variable> 
 
<!-- MobileOK Basic Test 3.15 OBJECTS_OR_SCRIPT (partial) ALREADY at validation, href_javascript --> 
	<xsl:variable name="applet_exists"> 
		<xsl:for-each select="//xhtml:applet | (//xhtml:a | //xhtml:link)[starts-with(@href,'javascript:')] | //xhtml:object[not(./*) and normalize-space(.) = '']"> 
			<li class="fail"> Failure: <xsl:apply-templates select="." mode="print" /> </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
		<xsl:for-each select="//xhtml:script | //xhtml:*[@onload or @onunload or @onclick or @ondblclick or @onmousedown or @onmouseup or @onmouseover or @onmousemove or @onmouseout or @onfocus or @onblur or @onkeypress or @onkeydown or @onkeyup or @onsubmit or @onreset or @onselect or @onchange]"> 
			<li class="warning">Warning: <xsl:apply-templates select="." mode="print" /> </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
        <xsl:variable name="applet_exists_report"> 
	<xsl:if test="normalize-space($applet_exists)!=''"> 
		<h3><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_objects_or_script">OBJECTS_OR_SCRIPT (partial)</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$applet_exists" /> 
		</xsl:element> 
	</xsl:if> 
	</xsl:variable> 
 
<!-- MobileOK Basic Test 3.16 PAGE_SIZE_LIMIT DISAGREE, OUTOFSCOPE --> 
        <xsl:variable name="pagelimit"> 
                <xsl:if test="$pagesize &gt; 10420"> 
                        <li class="fail">Failure: Document's markup exceeds 10420 (<strong><xsl:value-of select="$pagesize" /> </strong> bytes)</li> 
                        <xsl:text>&#10;</xsl:text> 
                </xsl:if> 
                <xsl:if test="$totalsize &gt; 20840"> 
                        <li class="fail">Failure: Document's resources exceed 20840 (<strong><xsl:value-of select="$totalsize" /> </strong> bytes)</li> 
                        <xsl:text>&#10;</xsl:text> 
                </xsl:if> 
        </xsl:variable> 
        <xsl:variable name="pagelimit_report"> 
        <xsl:if test="normalize-space($pagelimit)!=''"> 
                <h3><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_page_size_limit">PAGE_SIZE_LIMIT</a></h3> 
                <xsl:element name="ul"> 
                        <xsl:copy-of select="$pagelimit" /> 
                </xsl:element> 
        </xsl:if> 
	</xsl:variable> 
 
<!-- MobileOK Basic Test 3.17 PAGE_TITLE ALREADY at html_title --> 
	<xsl:variable name="html_title"> 
                <xsl:if test="//xhtml:html[count(./xhtml:head/xhtml:title)!=1] or normalize-space(//xhtml:title) = ''"> 
                        <li class="fail">Failure: Document requires a non empty title.</li> 
                        <xsl:text>&#10;</xsl:text> 
                </xsl:if> 
        </xsl:variable> 
        <xsl:variable name="html_title_report"> 
        <xsl:if test="normalize-space($html_title)!=''"> 
                <h3><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_page_title">PAGE_TITLE</a></h3> 
                <xsl:element name="ul"> 
                        <xsl:copy-of select="$html_title" /> 
                </xsl:element> 
        </xsl:if> 
        </xsl:variable> 
 
<!-- MobileOK Basic Test 3.18 POP_UPS --> 
	<xsl:variable name="targetframe"> 
		<xsl:for-each select="//xhtml:*[@target][@target != '_self' and @target != '_parent' and @target != '_top']"> 
			<li class="fail"> Failure: <xsl:apply-templates select="." mode="print" /> opens the link in a new window or another frame. Limit <kbd>target</kbd> attribute usage for opening links in current frames. </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
        <xsl:variable name="targetframe_report"> 
	<xsl:if test="normalize-space($targetframe)!=''"> 
		<h3><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_pop_ups">POP_UPS</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$targetframe" /> 
		</xsl:element> 
	</xsl:if> 
        </xsl:variable> 
 
<!-- MobileOK Basic Test 3.19 PROVIDE_DEFAULTS (partial) DISAGREE --> 
	<xsl:variable name="providedefaults"> 
		<xsl:for-each select="//xhtml:select[not(@multiple)][count(.//xhtml:option[@selected]) != 1]"> 
			<li class="warning">Warning: <xsl:apply-templates select="." mode="print" /> . </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
                <xsl:for-each select="//xhtml:input[@type='radio']"> 
                        <xsl:variable name="r" select="." /> 
                        <xsl:variable name="others" select="./ancestor::xhtml:form//xhtml:input[@type = 'radio' and @name = $r/@name and @checked]" /> 
                        <xsl:if test="count($others)!= 1"> 
                                <li class="warning">Warning: <xsl:apply-templates select="$r" mode="print" /> has no unique checked radio button.</li> 
                                <xsl:text>&#10;</xsl:text> 
                        </xsl:if> 
                </xsl:for-each> 
        </xsl:variable> 
        <xsl:variable name="providedefaults_report"> 
	<xsl:if test="normalize-space($providedefaults)!=''"> 
		<h3><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_provide_defaults">PROVIDE_DEFAULTS</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$providedefaults" /> 
		</xsl:element> 
	</xsl:if> 
	</xsl:variable> 
<!-- MobileOK Basic Test 3.20 STYLE_SHEETS_SUPPORT OUTOFSCOPE --> 
        <xsl:variable name="style_sheet_support"> 
                <xsl:if test="contains($cssreport, ' position : ') or contains($cssreport, ' display : ') or contains($cssreport, ' float : ')"> 
                        <li class="warning">Warning: page should be readable without a stylesheet. Warning because of a position, display or float property. <!-- <xsl:value-of select="substring-before(substring-after($cssreport, 'float :'), '&#10;')" /> --></li> 
                        <xsl:text>&#10;</xsl:text> 
                </xsl:if> 
        </xsl:variable> 
        <xsl:variable name="style_sheet_support_report"> 
        <xsl:if test="normalize-space($style_sheet_support)!=''"> 
                <h3><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_style_sheets_support">STYLE_SHEETS_SUPPORT (partial)</a></h3> 
                <xsl:element name="ul"> 
                        <xsl:copy-of select="$style_sheet_support" /> 
                </xsl:element> 
        </xsl:if> 
        </xsl:variable> 
<!-- MobileOK Basic Test 3.21 STYLE_SHEETS_USE ALREADY at validation --> 
	<xsl:variable name="stylesheetuse"> 
		<xsl:for-each select="//xhtml:basefont | //xhtml:bdo | //xhtml:center | //xhtml:del | //xhtml:dir | //xhtml:font | //xhtml:ins | //xhtml:menu | //xhtml:s | //xhtml:strike | //xhtml:u"> 
			<li class="fail"> Failure: <xsl:apply-templates select="." mode="print" /> . </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
		<xsl:for-each select="//xhtml:b | //xhtml:big | //xhtml:i | //xhtml:small | //xhtml:sub | //xhtml:sup | //xhtml:tt | //xhtml:*[@style]"> 
			<li class="warning"> Warning: <xsl:apply-templates select="." mode="print" /> . </li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
		<xsl:if test="count(//xhtml:style | //xhtml:link[@type='stylesheet']) &gt; 0 and count((//xhtml:style | //xhtml:link[@type='stylesheet'])[@media != 'all' and @media != 'handheld']) = count(//xhtml:style | //xhtml:link[@type='stylesheet'])"> 
			<li class="warning">Warning: All styles are for non handheld devices.</li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:if> 
        </xsl:variable> 
        <xsl:variable name="stylesheetuse_report"> 
	<xsl:if test="normalize-space($stylesheetuse)!=''"> 
		<h3><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_style_sheets_use">STYLE_SHEETS_USE</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$stylesheetuse" /> 
		</xsl:element> 
	</xsl:if> 
        </xsl:variable> 
 
<!-- MobileOK Basic Test 3.22 TABLES_ALTERNATIVES DISAGREE --> 
	<xsl:variable name="tablesexist"> 
		<xsl:for-each select="//xhtml:table"> 
			<li class="warning">Warning:  <xsl:apply-templates select="." mode="print" /></li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
        <xsl:variable name="tablesexist_report"> 
	<xsl:if test="normalize-space($tablesexist)!=''"> 
		<h3><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_tables_alternatives">TABLES_ALTERNATIVES</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$tablesexist" /> 
		</xsl:element> 
	</xsl:if> 
        </xsl:variable> 
 
<!-- MobileOK Basic Test 3.23 TABLES_LAYOUT DISAGREE --> 
	<xsl:variable name="tableslayout"> 
		<xsl:for-each select="//xhtml:table[count(.//xhtml:tr) &lt; 2 or not(.//xhtml:tr[count(.//xhtml:td) &gt; 1])]"> 
			<li class="fail"> Failure: <xsl:apply-templates select="." mode="print" /></li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
        <xsl:variable name="tableslayout_report"> 
	<xsl:if test="normalize-space($tableslayout)!=''"> 
		<h3><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_tables_layout">TABLES_LAYOUT</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$tableslayout" /> 
		</xsl:element> 
	</xsl:if> 
	</xsl:variable> 
 
<!-- MobileOK Basic Test 3.24 TABLES_NESTED SHARED with XHTML Basic --> 
	<xsl:variable name="nested_table"> 
		<xsl:for-each select="//xhtml:table[.//xhtml:table]"> 
			<li class="fail"> Failure: <xsl:apply-templates select="." mode="print" /></li> 
			<xsl:text>&#10;</xsl:text> 
		</xsl:for-each> 
	</xsl:variable> 
        <xsl:variable name="nested_table_report"> 
	<xsl:if test="normalize-space($nested_table)!=''"> 
		<h3><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_tables_nested">TABLES_NESTED</a></h3> 
		<xsl:element name="ul"> 
			<xsl:copy-of select="$nested_table" /> 
		</xsl:element> 
	</xsl:if> 
	</xsl:variable> 
 
	<table summary="Report summary"> 
	<caption>Report summary</caption> 
	<tr><th>Automated tests</th> <th>Result</th> </tr> 
	<tr><th class="smaller"><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_auto_refresh">AUTO_REFRESH (partial) and REDIRECTION</a></th> <td class="border"> <xsl:call-template name="resultm"> <xsl:with-param name="res" select="$refresh" /> </xsl:call-template></td> </tr> 
	<tr><th class="smaller"><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_caching">CACHING</a></th> <td class="border"> <xsl:call-template name="resultm"> <xsl:with-param name="res" select="$caching" /> </xsl:call-template></td> </tr> 
	<tr><th class="smaller"><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_character_encoding_support">CHARACTER_ENCODING_SUPPORT and CHARACTER_ENCODING_USE</a></th> <td class="border"> <xsl:call-template name="resultm"> <xsl:with-param name="res" select="$encoding" /> </xsl:call-template></td> </tr> 
	<tr><th class="smaller"><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_content_format_support">CONTENT_FORMAT_SUPPORT  and VALID_MARKUP</a></th> <td class="border"> <xsl:call-template name="resultm"> <xsl:with-param name="res" select="$contentformat" /> </xsl:call-template></td> </tr> 
	<tr><th class="smaller"><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_default_input_mode">DEFAULT_INPUT_MODE</a></th> <td class="border"> <xsl:call-template name="resultm"> <xsl:with-param name="res" select="$inputmode" /> </xsl:call-template></td> </tr> 
	<tr><th class="smaller"><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_external_resources">EXTERNAL_RESOURCES</a></th> <td class="border"> <xsl:call-template name="resultm"> <xsl:with-param name="res" select="$externalresources" /> </xsl:call-template></td> </tr> 
	<tr><th class="smaller"><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_graphics_for_spacing">GRAPHICS_FOR_SPACING</a></th> <td class="border"> <xsl:call-template name="resultm"> <xsl:with-param name="res" select="$graphicsspacing" /> </xsl:call-template></td> </tr> 
	<tr><th class="smaller"><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_image_maps">IMAGE_MAPS</a></th> <td class="border"> <xsl:call-template name="resultm"> <xsl:with-param name="res" select="$map_exists" /> </xsl:call-template></td> </tr> 
	<tr><th class="smaller"><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_images_specify_size">IMAGES_RESIZING and IMAGES_SPECIFY_SIZE</a></th> <td class="border"> <xsl:call-template name="resultm"> <xsl:with-param name="res" select="$img_size" /> </xsl:call-template></td> </tr> 
	<tr><th class="smaller"><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_link_target_format">LINK_TARGET_FORMAT</a></th> <td class="border"> <xsl:call-template name="resultm"> <xsl:with-param name="res" select="$link_target_format" /> </xsl:call-template></td> </tr> 
	<tr><th class="smaller"><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_measures">MEASURES</a></th> <td class="border"> <xsl:call-template name="resultm"> <xsl:with-param name="res" select="$css_measures" /> </xsl:call-template></td> </tr> 
	<tr><th class="smaller"><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_minimize">MINIMIZE</a></th> <td class="border"> <xsl:call-template name="resultm"> <xsl:with-param name="res" select="$minimize" /> </xsl:call-template></td> </tr> 
	<tr><th class="smaller"><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_no_frames">NO_FRAMES</a></th> <td class="border"> <xsl:call-template name="resultm"> <xsl:with-param name="res" select="$frame_exists" /> </xsl:call-template></td> </tr> 
	<tr><th class="smaller"><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_non_text_alternatives_1">NON-TEXT_ALTERNATIVES</a></th> <td class="border"> <xsl:call-template name="resultm"> <xsl:with-param name="res" select="$img_alt" /> </xsl:call-template></td> </tr> 
	<tr><th class="smaller"><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_objects_or_script">OBJECTS_OR_SCRIPT (partial)</a></th> <td class="border"> <xsl:call-template name="resultm"> <xsl:with-param name="res" select="$applet_exists" /> </xsl:call-template></td> </tr> 
	<tr><th class="smaller"><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_page_size_limit">PAGE_SIZE_LIMIT</a></th> <td class="border"> <xsl:call-template name="resultm"> <xsl:with-param name="res" select="$pagelimit" /> </xsl:call-template></td> </tr> 
	<tr><th class="smaller"><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_page_title">PAGE_TITLE</a></th> <td class="border"> <xsl:call-template name="resultm"> <xsl:with-param name="res" select="$html_title" /> </xsl:call-template></td> </tr> 
	<tr><th class="smaller"><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_pop_ups">POP_UPS</a></th> <td class="border"> <xsl:call-template name="resultm"> <xsl:with-param name="res" select="$targetframe" /> </xsl:call-template></td> </tr> 
	<tr><th class="smaller"><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_provide_defaults">PROVIDE_DEFAULTS</a></th> <td class="border"> <xsl:call-template name="resultm"> <xsl:with-param name="res" select="$providedefaults" /> </xsl:call-template></td> </tr> 
	<tr><th class="smaller"><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_style_sheets_support">STYLE_SHEETS_SUPPORT (partial)</a></th> <td class="border"> <xsl:call-template name="resultm"> <xsl:with-param name="res" select="$style_sheet_support" /> </xsl:call-template></td> </tr> 
	<tr><th class="smaller"><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_style_sheets_use">STYLE_SHEETS_USE</a></th> <td class="border"> <xsl:call-template name="resultm"> <xsl:with-param name="res" select="$stylesheetuse" /> </xsl:call-template></td> </tr> 
	<tr><th class="smaller"><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_tables_alternatives">TABLES_ALTERNATIVES</a></th> <td class="border"> <xsl:call-template name="resultm"> <xsl:with-param name="res" select="$tablesexist" /> </xsl:call-template></td> </tr> 
	<tr><th class="smaller"><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_tables_layout">TABLES_LAYOUT</a></th> <td class="border"> <xsl:call-template name="resultm"> <xsl:with-param name="res" select="$tableslayout" /> </xsl:call-template></td> </tr> 
	<tr><th class="smaller"><a href="http://www.w3.org/TR/mobileOK-basic10-tests/#test_tables_nested">TABLES_NESTED</a></th> <td class="border"> <xsl:call-template name="resultm"> <xsl:with-param name="res" select="$nested_table" /> </xsl:call-template></td> </tr> 
		
	</table> 
	<xsl:variable name="reportmobile"> 
		<xsl:copy-of select="$refresh_report" /> 
		<xsl:copy-of select="$caching_report" /> 
		<xsl:copy-of select="$encoding_report" /> 
		<xsl:copy-of select="$contentformat_report" /> 
		<xsl:copy-of select="$inputmode_report" /> 
		<xsl:copy-of select="$externalresources_report" /> 
		<xsl:copy-of select="$graphicsspacing_report" /> 
		<xsl:copy-of select="$map_exists_report" /> 
		<xsl:copy-of select="$img_size_report" /> 
		<xsl:copy-of select="$link_target_format_report" /> 
		<xsl:copy-of select="$css_measures_report" /> 
		<xsl:copy-of select="$minimize_report" /> 
		<xsl:copy-of select="$frame_exists_report" /> 
		<xsl:copy-of select="$img_alt_report" /> 
		<xsl:copy-of select="$applet_exists_report" /> 
		<xsl:copy-of select="$pagelimit_report" /> 
		<xsl:copy-of select="$html_title_report" /> 
		<xsl:copy-of select="$targetframe_report" /> 
		<xsl:copy-of select="$providedefaults_report" /> 
		<xsl:copy-of select="$style_sheet_support_report" /> 
		<xsl:copy-of select="$stylesheetuse_report" /> 
		<xsl:copy-of select="$tablesexist_report" /> 
		<xsl:copy-of select="$tableslayout_report" /> 
		<xsl:copy-of select="$nested_table_report" /> 
	</xsl:variable> 
	<xsl:if test="normalize-space($reportmobile)!=''"> 
		<h2>Mobile OK test's details</h2> 
		<!-- <div class="border prio1"> --> 
		<xsl:copy-of select="$reportmobile" /> 
		<!-- </div> --> 
	</xsl:if> 
	
</xsl:template> 
 
<!--
    <xsl:variable name="img_alt">
	<lista>
	    <xsl:for-each select="//xhtml:img[not(@alt)]">
		    <xsl:variable name="img" select="." />
		    <xsl:copy-of select="$img" />
	    </xsl:for-each>
	</lista>
    </xsl:variable>
    <xsl:value-of select="count($img_alt)" />Imágenes1
    <xsl:value-of select="$img_alt" />Imágenes2
    <xsl:copy-of select="$img_alt" />Imágenes3
    <xsl:copy select="$img_alt" />Imágenes4
    <xsl:if test="count($img_alt) != 0">
	<ul>
	    <xsl:for-each select="$img_alt">
		    <li><xsl:copy-of select="." /></li>
		    <li><xsl:value-of select="@src" /></li>
	    </xsl:for-each>
	    <xsl:for-each select="$img_alt//*">
		    <li><xsl:copy-of select="." /></li>
		    <li><xsl:value-of select="@src" /></li>
	    </xsl:for-each>
	</ul>
    </xsl:if>
--> 
		<!--
			<xsl:variable name="altig">
			<xsl:call-template name="compara">
				<xsl:with-param name="op1" select="@alt" />
				<xsl:with-param name="op2" select="$a/@alt" />
			</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="textig">
			<xsl:call-template name="compara">
				<xsl:with-param name="op1" select="concat(@title, @alt, ., .//@alt)" />
				<xsl:with-param name="op2" select="concat($a/@title, $a/@alt, $a, $a//@alt)" />
			</xsl:call-template>
			</xsl:variable>
		--> 
			
		<!-- <li><xsl:copy-of select="$a" /> con <xsl:copy-of select="." /> <xsl:value-of select="count($altig)" />,<xsl:value-of select="count($textig)" /> </li> --> 
		<!-- <xsl:value-of select="concat('(',$textig,')')" /> --> 
		<!-- <xsl:if test="@href != $a/@href and $textig = 'true'"> --> 
 
<xsl:template name="result"> 
	<xsl:param name="res" /> 
	<xsl:choose> 
	<xsl:when test="normalize-space($res)=''"> 
		<strong class="green">PASSED</strong> 
	</xsl:when> 
	<xsl:otherwise> 
		<strong class="red">FAILED</strong> 
	</xsl:otherwise> 
	</xsl:choose> 
</xsl:template> 
 
<xsl:template name="resultm"> 
        <xsl:param name="res" /> 
        <xsl:choose> 
        <xsl:when test="normalize-space($res)=''"> 
                <strong class="green">PASSED</strong> 
        </xsl:when> 
        <xsl:when test="contains(string($res), 'Failure: ')"> 
                <strong class="red">FAILED</strong> 
        </xsl:when> 
        <xsl:when test="contains(string($res), 'Warning: ')"> 
                <strong class="yellow">WARNINGS</strong> 
        </xsl:when> 
        <xsl:otherwise> 
                <strong class="gray">UNTESTED</strong> 
        </xsl:otherwise> 
        </xsl:choose> 
</xsl:template> 
 
 
 
<xsl:template name="compara"> 
	<xsl:param name="op1" /> 
	<xsl:param name="op2" /> 
	<xsl:choose> 
	<xsl:when test="not($op1) and not($op2)"> 
		<xsl:value-of select="'true'" /> 
	</xsl:when> 
	<xsl:when test="not($op1) or not($op2)"> 
		<xsl:value-of select="'false'" /> 
	</xsl:when> 
	<xsl:when test="$op1 = $op2"> 
		<xsl:value-of select="'true'" /> 
<!--
<xsl:message>
	<xsl:value-of select="$op1" /> comparado con <xsl:value-of select="$op2" /> es <xsl:value-of select="$op1 = $op2" />
</xsl:message>
		<xsl:value-of select="$op1 = $op2" />
		<xsl:value-of select="false()" />
--> 
	</xsl:when> 
	<xsl:otherwise> 
		<xsl:value-of select="'false'" /> 
	</xsl:otherwise> 
	</xsl:choose> 
	
</xsl:template> 
 
</xsl:stylesheet> 